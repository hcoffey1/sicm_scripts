#!/bin/bash

################################################################################
#                        offline_mbi_guided_percent                           #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the size of the MBI sampling to use
# Fourth argument is the packing strategy
# Fifth argument is the percentage of the peak RSS that should be available on the node
# Sixth argument is the node to pack onto
function offline_mbi_guided {
  BASEDIR="$1"
  COMMAND="$2"
  MBI_SIZE="$3"
  PACK_ALGO="$4"
  RATIO=$(echo "${5}/100" | bc -l)
  NODE=${6}
  CANARY_CFG="firsttouch_all_exclusive_device_0_0"
  CANARY_STDOUT="${BASEDIR}/../${CANARY_CFG}/i0/stdout.txt"
  MBI_DIR="${BASEDIR}/../../${MBI_SIZE}/mbi"
  PEBS_STDOUT="${BASEDIR}/../pebs_128/i0/stdout.txt"

  # This file is used for the profiling information
  if [ ! -r "${MBI_DIR}" ]; then
    echo "ERROR: The file '${MBI_DIR}' doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r "${CANARY_STDOUT}" ]; then
    echo "ERROR: The file '${CANARY_STDOUT}' doesn't exist yet. Aborting."
    exit
  fi

  # This is in kilobytes
  PEAK_RSS=$(${SCRIPTS_DIR}/stat.sh ${CANARY_STDOUT} rss_kbytes)
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  # How many pages we need to be free on MCDRAM
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  # User output
  echo "Running experiment:"
  echo "  Config: 'offline_mbi_guided'"
  echo "  Profiling size: '${MBI_SIZE}'"
  echo "  Packing algorithm: '${PACK_ALGO}'"
  echo "  Packing into bytes: '${NUM_BYTES}'"
  echo "  Scaling down to peak RSS: '${PEAK_RSS}'"

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="0"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"
  export OMP_NUM_THREADS="272"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"
  
  # Generate the hotset/knapsack/thermos
  cat ${MBI_DIR}/* ${PEBS_STDOUT} | \
    sicm_hotset mbi ${PACK_ALGO} constant ${NUM_BYTES} 1 ${PEAK_RSS_BYTES} > \
      ${BASEDIR}/guidance.txt
  for i in {0..0}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    memreserve ${DIR} ${NUM_PAGES} ${NODE}
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "env time -v " "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
    memreserve_kill
  done
}

################################################################################
#                        offline_mbi_guided                                   #
################################################################################
# First argument is results directory
# Second argument is the command to run
# Third argument is the frequency of MBI sampling to use
# Fourth argument is the size of MBI profiling run to use
# Fifth argument is the packing strategy
function offline_all_mbi_guided {
  BASEDIR="$1"
  COMMAND="$2"
  MBI_FREQ="$3"
  MBI_SIZE="$4"
  PACK_ALGO="$5"
  PEAK_RSS_FILE="${BASEDIR}/../firsttouch_all_exclusive_device_0_0/i0/stdout.txt"
  MBI_FILE="${BASEDIR}/../../${MBI_SIZE}/mbi_${MBI_FREQ}/i0/stdout.txt"

  # This file is used for the profiling information
  if [ ! -r "${MBI_FILE}" ]; then
    echo "ERROR: The file '${MBI_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r "${PEAK_RSS_FILE}" ]; then
    echo "ERROR: The file '${PEAK_RSS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  MCDRAM_SIZE="$(numastat -m | awk '/MemFree/ {printf "%d * 1024 * 1024\n", $3}' | bc)"
  PEAK_RSS_KBYTES=$(${SCRIPTS_DIR}/stat.sh ${PEAK_RSS_FILE} rss_kbytes)
  PEAK_RSS=$(echo "${PEAK_RSS_KBYTES} * 1024" | bc)

  # User output
  echo "Running experiment:"
  echo "  Config: 'offline_all_mbi_guided'"
  echo "  Profiling frequency: '${MBI_FREQ}'"
  echo "  Profiling size: '${MBI_SIZE}'"
  echo "  Packing algorithm: '${PACK_ALGO}'"
  echo "  Packing into MCDRAM: '${MCDRAM_SIZE}'"
  
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="0"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"
  export OMP_NUM_THREADS="272"
  export JE_MALLOC_CONF="oversize_threshold:0"

  eval "${PRERUN}"
  
  cat "${MBI_FILE}" | \
    sicm_hotset mbi ${PACK_ALGO} constant ${MCDRAM_SIZE} 1 ${PEAK_RSS} > \
    ${BASEDIR}/guidance.txt
  for i in {0..0}; do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "env time -v " "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
  done
}