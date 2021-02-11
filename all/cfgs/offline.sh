#!/bin/bash

DO_MEMRESERVE=false
CAPACITY_PROF_TYPE=""

function guided_compress {
  MEM_HIGH="$1"
  MEM_MAX=$(echo "${MEM_HIGH}" | bc)

  SRC_COMPRESS_GUIDANCE_FILE="${PROFILE}"
  if [ ! -f "${SRC_COMPRESS_GUIDANCE_FILE}" ]; then
    echo "ERROR: The file '${SRC_COMPRESS_GUIDANCE_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  cp "${SRC_COMPRESS_GUIDANCE_FILE}" "${BASEDIR}/compress_guidance.txt"
  export SH_COMPRESS_GUIDANCE_FILE="${BASEDIR}/compress_guidance.txt"
  export SH_ARENA_LAYOUT="EXCLUSIVE_COMPRESS_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"
  export SH_PROFILE_COMPRESS_STATS="1"
  export SH_PROFILE_RATE_NSECONDS=$(echo "1000 * 1000000" | bc)
    
  echo Arguments $#
  if [ $# -eq 1 ]
  then
      export SH_CGROUP_MEM_HIGH=$(echo "2^${MEM_HIGH}" | bc)
      export SH_CGROUP_MEM_MAX=$(echo "2^${MEM_MAX}" | bc)
  else
      export SH_CGROUP_MEM_HIGH=$(echo "${MEM_HIGH}" | bc)
      export SH_CGROUP_MEM_MAX=$(echo "${MEM_MAX}" | bc)
  fi
    
  #echo "running compress config"
  eval "${PRERUN}"
  unsetup_compress

  # Run the iterations
  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}

    export SH_COMPRESS_STATS_FILE=${DIR}/compress_stats.txt

    drop_caches
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    setup_compress

    #Set up bpftrace probes
    bpftrace /home/hcoffey1/bpft/lz4.bt > ${DIR}/bpftrace.log &
    bpft_pid=$!

    eval "${COMMAND}" &>> ${DIR}/run_sh_stdout.txt

    #Terminate bpftrace probes
    kill -2 $bpft_pid

    unsetup_compress
    numastat_kill
    pcm_kill
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi

    COMMAND_VAR="${SIZE}_COMMANDS[@]"
    BENCH_COMMANDS=("${!COMMAND_VAR}")
    for RUN in $(seq 0 $(( ${#BENCH_COMMANDS[@]} - 1 )) ); do
      cp "${BENCH_DIR}/${BENCH}/run/stdout${RUN}.txt" ${DIR}/
      cp "${BENCH_DIR}/${BENCH}/run/stderr${RUN}.txt" ${DIR}/
    done
  done
}

function guided_offline {
  SRC_GUIDANCE_FILE="${PROFILE}"
  if [ ! -f "${SRC_GUIDANCE_FILE}" ]; then
    echo "ERROR: The file '${SRC_GUIDANCE_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  cp "${SRC_GUIDANCE_FILE}" "${BASEDIR}/guidance.txt"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"
  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"

  eval "${PRERUN}"

  # Run the iterations
  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi
  done
}

function offline_base {
  PACK_ALGO="$1"

  CANARY_CFG="firsttouch_exclusive_device:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"
  PEBS_DIR="${PROFILE}/"
  PEBS_FILE="${PEBS_DIR}/profile.txt"

  # This file is used for the profiling information
  if [ ! -f "${PEBS_FILE}" ]; then
    echo "ERROR: The file '${PEBS_FILE}' doesn't exist yet. Aborting."
    exit
  fi

  # This file is used to get the peak RSS
  if [ ! -r "${CANARY_DIR}" ]; then
    echo "ERROR: The file '${CANARY_DIR}' doesn't exist yet. Aborting."
    exit
  fi

  # Get the peak RSS of the canary run
  PEAK_RSS_CANARY=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${CANARY_DIR}`
  PEAK_RSS_CANARY_BYTES=$(echo "${PEAK_RSS_CANARY} * 1024" | bc)

  # Get the peak RSS of the profiling run
  PEAK_RSS_PROFILING=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${PEBS_DIR}`
  PEAK_RSS_PROFILING_BYTES=$(echo "${PEAK_RSS_PROFILING} * 1024" | bc)

  # Now get the ratio that we should scale the sites' weights down by
  SCALE=$(echo "${PEAK_RSS_CANARY_BYTES} / ${PEAK_RSS_PROFILING_BYTES}" | bc -l)

  export SH_ARENA_LAYOUT="EXCLUSIVE_DEVICE_ARENAS"
  export SH_MAX_SITES_PER_ARENA="4096"
  export SH_DEFAULT_NODE="${SH_LOWER_NODE}"
  export SH_GUIDANCE_FILE="${BASEDIR}/guidance.txt"

  eval "${PRERUN}"

  # Generate the guidance file
  HOTSET_ARGS="--capacity=${NUM_BYTES} --scale=${SCALE} --event=MEM_LOAD_UOPS_LLC_MISS_RETIRED:LOCAL_DRAM --event=MEM_LOAD_UOPS_RETIRED:LOCAL_PMM --node=${SH_UPPER_NODE} --verbose"
  if [[ ! -z ${CAPACITY_PROF_TYPE} ]]; then
    HOTSET_ARGS="${HOTSET_ARGS} --weight=${CAPACITY_PROF_TYPE}"
  fi
  HOTSET_ARGS="${HOTSET_ARGS} --multiplier=1 --multiplier=5"
  cat "${PEBS_FILE}" | \
    sicm_hotset ${HOTSET_ARGS} \
    > ${BASEDIR}/guidance.txt

  # Run the iterations
  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}
    drop_caches
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve ${DIR} ${NUM_PAGES} ${SH_UPPER_NODE}
    fi
    numastat -m &>> ${DIR}/numastat_before.txt
    numastat_background "${DIR}"
    pcm_background "${DIR}"
    eval "${COMMAND}" &>> ${DIR}/stdout.txt
    numastat_kill
    pcm_kill
    if [ "$DO_MEMRESERVE" = true ]; then
      memreserve_kill
    fi
  done
}

function offline {
  # Get the amount of free memory in the upper tier right now
  COLUMN_NUMBER=$(echo ${SH_UPPER_NODE} + 2 | bc)
  UPPER_SIZE="$(numastat -m | awk -v column_number=${COLUMN_NUMBER} '/MemFree/ {printf "%d * 1024 * 1024\n", $column_number}' | bc)"
  NUM_BYTES=${UPPER_SIZE}

  offline_base $@
}

function offline_memreserve {
  RATIO=$(echo "${2}/100" | bc -l)
  CANARY_CFG="firsttouch_exclusive_device:"
  CANARY_DIR="${BASEDIR}/../${CANARY_CFG}/i0/"

  # This is in kilobytes
  PEAK_RSS=`${SCRIPTS_DIR}/all/stat --metric=peak_rss_kbytes ${CANARY_DIR}`
  PEAK_RSS_BYTES=$(echo "${PEAK_RSS} * 1024" | bc)

  # How many pages we need to be free on upper tier
  NUM_PAGES=$(echo "${PEAK_RSS} * ${RATIO} / 4" | bc)
  NUM_BYTES_FLOAT=$(echo "${PEAK_RSS} * ${RATIO} * 1024" | bc)
  NUM_BYTES=${NUM_BYTES_FLOAT%.*}

  DO_MEMRESERVE=true
  offline_base "$@"
}

function offline_memreserve_extent_size {
  CAPACITY_PROF_TYPE="profile_extent_size"
  offline_memreserve $@
}

function offline_memreserve_extent_size_onlineprofiling {
  CAPACITY_PROF_TYPE="profile_extent_size"
  offline_memreserve $@
}

function offline_memreserve_rss {
  CAPACITY_PROF_TYPE="profile_rss"
  offline_memreserve $@
}

function offline_memreserve_allocs {
  CAPACITY_PROF_TYPE="profile_allocs"
  offline_memreserve $@
}
