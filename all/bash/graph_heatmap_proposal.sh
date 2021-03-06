#!/usr/bin/env bash

### INPUT FORMAT #######################################################
#
# Header: Allocation site IDs.
# Each column: One allocation site.
# Each line:   Space separated floats indicating the hotness of
#              each allocation site on one interval.
#
# Example:
#              3    5   9
#              0.1  0.3 7.5
#              0.0  4.1 1.24
#              12.4 4.4 9.3
#              3.3  0.0 5.5
#
#              Site 5 had heat value 4.4 on interval 3.
#              Site 9 had heat value 5.5 on interval 4.
#
# First argument: name of the heatmap file.
# Second argument: name of the weight ratio file.
# Third argument: title of the graph.
# Fourth argument: If "relative", the redness of a particular cell is based on
#                  only that interval's max and min hotness. Otherwise, use
#                  hotness from the whole run.
#
########################################################################

heatmap_f="$1"
weight_ratios_f="$2"
title="$3"

if [[ "$heatmap_f" == "" ]]; then
    echo "usage: graph_heatmap.sh FILE"
    exit 1
fi

if ! [ -f "$heatmap_f" ]; then
    echo "No such file '${f}'"
    exit 1
fi

N_INTERVALS=$(wc "$heatmap_f" | awk ' { print $1 - 1; } ')
LAST_INTERVAL=$(echo "$N_INTERVALS - 1" | bc)
N_SITES=$(head -n 1 "$heatmap_f" | awk '{ print NF; }')
SITES=$(head -n 1 "$heatmap_f")
>&2 echo "N_SITES: ${N_SITES}"
>&2 echo "N_INTERVALS: ${N_INTERVALS}"
>&2 echo "SITES: ${SITES}"

# Figure out the number of intervals per inch
INTERVALS_PER_INCH=$(echo "$N_INTERVALS / 5" | bc)
INTERVALS_TO_SKIP_PRINTING=$(echo "50" | bc)
MIN_INTERVAL_DISTANCE=$(echo "$INTERVALS_TO_SKIP_PRINTING / 2" | bc)
>&2 echo "INTERVALS_PER_INCH: ${INTERVALS_PER_INCH}"
>&2 echo "INTERVALS_TO_SKIP_PRINTING: ${INTERVALS_TO_SKIP_PRINTING}"
>&2 echo "MIN_INTERVAL_DISTANCE: ${MIN_INTERVAL_DISTANCE}"

echo "newgraph"

# X axis
echo "xaxis label fontsize 16 : Profile Intervals (1 Interval = 1 second)"
echo "    min 0 max ${N_INTERVALS}"
echo "    size 5"
echo "    no_auto_hash_marks"
echo "    no_auto_hash_labels"
echo "    hash_scale -0.5"
echo "    hash_labels fontsize 12"
i=0
last_interval_printed=0
for interval in $(seq 0 ${LAST_INTERVAL}); do
  if [ "$i" -eq "${INTERVALS_TO_SKIP_PRINTING}" ] || \
     [ "$interval" -eq "0" ] || \
     ([ "$interval" -eq "${LAST_INTERVAL}" ] && [ $(echo "$interval - $last_interval_printed" | bc) -gt "${MIN_INTERVAL_DISTANCE}" ]); then
    i=0
    last_interval_printed=$interval
    echo "    hash_at ${interval}"
    echo "    hash_label at ${interval} : ${interval}"
    >&2 echo "    hash_at ${interval}"
  fi
  i=$(echo "$i + 1" | bc)
done

echo "yaxis label fontsize 16 : Allocation Sites"
echo "    min 0 max 100"
echo "    size 5"
echo "    no_auto_hash_marks"
echo "    no_auto_hash_labels"
i=1
total_height=0
for site in $(head -n 1 "$heatmap_f"); do
  cur_weight_ratio=$(tail -n +2 "$weight_ratios_f" | awk '{ print $'$i'; }')
  cur_half_height=$(echo "$cur_weight_ratio / 2" | bc -l)
  cur_midpoint=$(echo "$total_height + $cur_half_height" | bc -l)
  total_height=$(echo "$total_height + $cur_weight_ratio" | bc -l)
  >&2 echo "    hash_at ${cur_midpoint}"
  echo "    hash_at ${cur_midpoint}"
  i=$(echo "$i + 1" | bc)
done
echo "    hash_labels fontsize 8"

echo "title : ${title}"

i=1
total_height=0
for site in $(head -n 1 "$heatmap_f"); do
  cur_weight_ratio=$(tail -n +2 "$weight_ratios_f" | awk '{ print $'$i'; }')
  cur_half_height=$(echo "$cur_weight_ratio / 2" | bc -l)
  cur_midpoint=$(echo "$total_height + $cur_half_height" | bc -l)
  total_height=$(echo "$total_height + $cur_weight_ratio" | bc -l)
  >&2 echo "$site, $cur_half_height"
  awk_prg="{
    max=0;
    min=100000000000000;
    for (j=1; j<=NF; j++) {
        if (\$j > max) {
            max=\$j;
        }
        if (\$j < min) {
            min=\$j;
        }
    }
    ratio = 1.0
    if (max > 0.0) {
        ratio -= (\$$i-min)/(max-min);
    }
    printf(\"newline linethickness 0.0 poly color 1.0 %f %f pcfill 1.0 %f %f pts %d %f %d %f %d %f %d %f\n\", ratio, ratio, ratio, ratio, NR-1, $cur_midpoint-$cur_half_height, NR, $cur_midpoint-$cur_half_height, NR, $cur_midpoint+$cur_half_height, NR-1, $cur_midpoint+$cur_half_height);
  }"

  tail -n +2 "$heatmap_f" | awk "${awk_prg}"
  echo ""
  i=$(echo "$i + 1" | bc)
done
