#!/bin/bash

# First argument is the PEBS frequency
# Second is the sampling rate
# Third is skip intervals for capacity profiling
function profile_all_and_cap {
  FREQ="$1"
  RATE="$2"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  # Enable profiling
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_RATE_NSECONDS=$(echo "$RATE * 1000000" | bc)
  #export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_RETIRED:LLC_MISS"
  #export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_RETIRED:L3_MISS"
  #export SH_PROFILE_ALL_NODES="1"
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM"
  #export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM,MEM_LOAD_UOPS_RETIRED:LOCAL_PMM"
  #export SH_MAX_SAMPLE_PAGES="512"
  export SH_MAX_SAMPLE_PAGES="4096"
  export SH_SAMPLE_FREQ="${FREQ}"

  #export SH_TRACK_PAGES="1"
  #export SH_TRACK_CACHE_BLOCKS="1"
  #export SH_PAGE_PROFILE_INTERVALS="1"
  #export SH_CACHE_BLOCK_PROFILE_INTERVALS="1"

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    export SH_DIRTY_PROFILE_OUTPUT_FILE="${DIR}/dirty.txt"
    #export SH_PAGE_PROFILE_OUTPUT_FILE="${DIR}/pagemap.txt"
    #export SH_CACHE_PROFILE_OUTPUT_FILE="${DIR}/cachemap.txt"
    mkdir ${DIR}
    echo "-1" | sudo tee /proc/sys/kernel/perf_event_paranoid
    drop_caches
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
  done
}

function profile_all_and_allocs {
  export SH_PROFILE_ALLOCS="1"
  export SH_PROFILE_ALLOCS_SKIP_INTERVALS="$3"
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 3`
  profile_all_and_cap $@
}

function profile_all_and_extent_size {
  export SH_PROFILE_EXTENT_SIZE="1"
  export SH_PROFILE_EXTENT_SIZE_SKIP_INTERVALS="$3"
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`
  profile_all_and_cap $@
}

function profile_all_and_extent_size_intervals {
  export SH_PROFILE_INTERVALS="1"
  profile_all_and_extent_size $@
}

function profile_all_and_rss {
  export SH_PROFILE_RSS="1"
  export SH_PROFILE_RSS_SKIP_INTERVALS="$3"
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`
  profile_all_and_cap $@
}

function profile_all_and_dirty {
  FREQ="$1"
  RATE="$2"

  export SH_PROFILE_DIRTY="1"
  export SH_PROFILE_DIRTY_SKIP_INTERVALS="$3"
  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  # Enable profiling
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_RATE_NSECONDS=$(echo "$RATE * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM,MEM_LOAD_UOPS_RETIRED:LOCAL_PMM"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_SAMPLE_FREQ="${FREQ}"

  #export SH_TRACK_PAGES="1"
  #export SH_TRACK_CACHE_BLOCKS="1"
  #export SH_PAGE_PROFILE_INTERVALS="1"
  #export SH_CACHE_BLOCK_PROFILE_INTERVALS="1"

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    export SH_DIRTY_PROFILE_OUTPUT_FILE="${DIR}/dirty.txt"
    #export SH_PAGE_PROFILE_OUTPUT_FILE="${DIR}/pagemap.txt"
    #export SH_CACHE_PROFILE_OUTPUT_FILE="${DIR}/cachemap.txt"
    mkdir ${DIR}
    echo "-1" | sudo tee /proc/sys/kernel/perf_event_paranoid
    drop_caches
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
  done
}

function profile_all_exclusive_device {
  FREQ="$1"
  RATE="$2"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  # Enable profiling
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_OBJECTS="1"
  export SH_PROFILE_RATE_NSECONDS=$(echo "$RATE * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_SAMPLE_FREQ="${FREQ}"

  export SH_TRACK_PAGES="1"
  #export SH_PROFILE_RSS="1"

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    export SH_PAGE_PROFILE_OUTPUT_FILE="${DIR}/pagemap.txt"
    export SH_SITE_PROFILE_OUTPUT_FILE="${DIR}/sites.txt"
    mkdir ${DIR}
    echo "-1" | sudo tee /proc/sys/kernel/perf_event_paranoid
    drop_caches

    eval "${COMMAND}" &>> ${DIR}/run_sh_stdout.txt
    COMMAND_VAR="${SIZE}_COMMANDS[@]"
    BENCH_COMMANDS=("${!COMMAND_VAR}")
    for RUN in $(seq 0 $(( ${#BENCH_COMMANDS[@]} - 1 )) ); do
      cp "${BENCH_DIR}/${BENCH}/run/stdout${RUN}.txt" ${DIR}/
      cp "${BENCH_DIR}/${BENCH}/run/stderr${RUN}.txt" ${DIR}/
    done
  done
}

function profile_all_and_pagemap {
  FREQ="$1"
  RATE="$2"

  export OMP_NUM_THREADS=`expr $OMP_NUM_THREADS - 1`

  #export SH_ARENA_LAYOUT="BIG_SMALL_ARENAS"
  #export SH_BIG_SMALL_THRESHOLD="4194304"
  export SH_PROFILE_OBJMAP="1"
  export SH_PROFILE_OBJMAP_SKIP_INTERVALS="$3"
  export SH_PRINT_PROFILE_INTERVALS="1"

  export SH_ARENA_LAYOUT="SHARED_SITE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="5000"
  #export SH_MAX_SITES="30000"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  # Enable profiling
  export SH_PROFILE_ALL="1"
  export SH_PROFILE_RATE_NSECONDS=$(echo "$RATE * 1000000" | bc)
  export SH_PROFILE_ALL_EVENTS="MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM"
  export SH_MAX_SAMPLE_PAGES="512"
  export SH_SAMPLE_FREQ="${FREQ}"

  export SH_TRACK_PAGES="1"
  export SH_PROFILE_RSS="1"

  eval "${PRERUN}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    export SH_PROFILE_OUTPUT_FILE="${DIR}/profile.txt"
    export SH_PAGE_PROFILE_OUTPUT_FILE="${DIR}/pagemap.txt"
    export SH_SITE_PROFILE_OUTPUT_FILE="${DIR}/sites.txt"
    mkdir ${DIR}
    echo "-1" | sudo tee /proc/sys/kernel/perf_event_paranoid
    drop_caches

    eval "${COMMAND}" &>> ${DIR}/run_sh_stdout.txt
    COMMAND_VAR="${SIZE}_COMMANDS[@]"
    BENCH_COMMANDS=("${!COMMAND_VAR}")
    for RUN in $(seq 0 $(( ${#BENCH_COMMANDS[@]} - 1 )) ); do
      cp "${BENCH_DIR}/${BENCH}/run/stdout${RUN}.txt" ${DIR}/
      cp "${BENCH_DIR}/${BENCH}/run/stderr${RUN}.txt" ${DIR}/
    done
  done
}
