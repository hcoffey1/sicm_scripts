#!/bin/bash -l

source ./all/vars.sh

export PATH="${SICM_PREFIX}/bin:${PATH}"

# Set all per-platform options, based on the hostname
if [[ "$(hostname)" = "JF1121-080209T" ]]; then
  # Old CLX machine
  export OMP_NUM_THREADS="48"
elif [[ "$(hostname)" = "cce-clx-9.jf.intel.com" ]]; then
  # New CLX machine
  export OMP_NUM_THREADS="40"
elif [[ "$(hostname)" = "canata" ]]; then
  # LANL's Canata machine
  export OMP_NUM_THREADS="48"
elif [[ "$(hostname)" = "SystemID-817" ]]; then
  # Intel's SDP machine with CLX and AEP
  export OMP_NUM_THREADS="40"
elif [[ "$(hostname)" = "brazil.eecs.utk.edu" ]]; then
  # Intel's SDP machine with CLX and AEP
  export OMP_NUM_THREADS="12"
else
  # KNL
  export OMP_NUM_THREADS="256"
fi
export SH_MAX_THREADS=`expr ${OMP_NUM_THREADS} + 1`

source $SCRIPTS_DIR/all/args.sh
source $SCRIPTS_DIR/all/tools.sh
source $SCRIPTS_DIR/all/cfgs/firsttouch.sh
source $SCRIPTS_DIR/all/cfgs/sim.sh
source $SCRIPTS_DIR/all/cfgs/profile.sh
#source $SCRIPTS_DIR/all/cfgs/profile_latency.sh
source $SCRIPTS_DIR/all/cfgs/profile_cache_miss.sh
source $SCRIPTS_DIR/all/cfgs/offline.sh
source $SCRIPTS_DIR/all/cfgs/online.sh
source $SCRIPTS_DIR/all/cfgs/multi_iter.sh
#source $SCRIPTS_DIR/all/cfgs/pagedrift.sh

if [[ "$(hostname)" = "JF1121-080209T" ]]; then

  # Old CLX machine
  if [[ $NUM_NUMA_NODES = 4 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1,3"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="3"
  elif [[ $NUM_NUMA_NODES = 2 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="1"
  else
    echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
    exit
  fi

elif [[ "$(hostname)" = "cce-clx-9.jf.intel.com" ]]; then

  # New CLX machine
  if [[ $NUM_NUMA_NODES = 4 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1,3"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="3"
  elif [[ $NUM_NUMA_NODES = 2 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="1"
  else
    echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
    exit
  fi

elif [[ "$(hostname)" = "canata" ]]; then

  # LANL's Canata
  if [[ $NUM_NUMA_NODES = 4 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1,3"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="3"
  elif [[ $NUM_NUMA_NODES = 2 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="1"
  else
    echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
    exit
  fi
  
elif [[ "$(hostname)" = "SystemID-817" ]]; then

  # Intel's CLX SDP machine
  if [[ $NUM_NUMA_NODES = 4 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1,3"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="3"
  elif [[ $NUM_NUMA_NODES = 2 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1 numactl --cpunodebind=1 --membind=1"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="1"
  else
    echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
    exit
  fi

elif [[ "$(hostname)" = "brazil.eecs.utk.edu" ]]; then

  export PLATFORM_COMMAND="sudo -E env time -v "
  export SH_UPPER_NODE="0"
  export SH_LOWER_NODE="0"

else

  # KNL
  if [[ $NUM_NUMA_NODES = 2 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v numactl --preferred=1"
    export SH_UPPER_NODE="1"
    export SH_LOWER_NODE="0"
  elif [[ $NUM_NUMA_NODES = 1 ]]; then
    export PLATFORM_COMMAND="sudo -E env time -v"
    export SH_UPPER_NODE="0"
    export SH_LOWER_NODE="0"
  else
    echo "COULDN'T DETECT HARDWARE CONFIGURATION. ABORTING."
    exit
  fi

fi

if [[ ${#BENCHES[@]} = 0 ]]; then
  echo "You didn't specify a benchmark name. Aborting."
  exit 1
fi

if [[ ${#CONFIGS[@]} = 0 ]]; then
  echo "You didn't specify a configuration name. Aborting."
  exit 1
fi

if [[ ! $SIZE ]]; then
  echo "You didn't specify a size. Aborting."
  exit 1
fi

# For the PCM tools
sudo modprobe msr

for BENCH_INDEX in ${!BENCHES[*]}; do
  for CONFIG_INDEX in ${!CONFIGS[*]}; do
    BENCH="${BENCHES[${BENCH_INDEX}]}"
    CONFIG="${CONFIGS[${CONFIG_INDEX}]}"
    ARGS_SPACES="${CONFIG_ARGS[$CONFIG_INDEX]}"
    FULL_CONFIG="${FULL_CONFIGS[${CONFIG_INDEX}]}"

    # Set a function to do arbitrary commands depending on the benchmark
    # and benchmark size.
    #
    if [[ "${CPU2017_BENCHES[@]}" =~ "${BENCH}" ]]; then
      MYBENCH=`echo ${BENCH} | sed -e 's/\./_/'`
      export PRERUN="${MYBENCH}_prerun"
      export SETUP="${MYBENCH}_setup"
    else 
      export PRERUN="${BENCH}_prerun"
      export SETUP="${BENCH}_setup"
    fi

    # Create the results directory for this experiment,
    # and pass that to the BASH function
    #
    DIRECTORY="${RESULTS_DIR}/${BENCH}/${SIZE}/${FULL_CONFIG}"
    if [[ ! ${CONFIG} == *"manual"* ]]; then
      rm -rf ${DIRECTORY}
      mkdir -p ${DIRECTORY}
    fi

    # We want SICM to output its configuration for debugging
    export SH_LOG_FILE="${DIRECTORY}/config.txt"
    ulimit -c unlimited

    # Print out information about this run
    echo "Running experiment:"
    echo "  Benchmark: '${BENCH}'"
    echo "  Configuration: '${CONFIG}'"
    echo "  Configuration arguments: '${ARGS_SPACES}'"

    # Execute the BASH function with arguments
    export BASEDIR="${DIRECTORY}"
    export COMMAND="./run.sh"

    cd ${BENCH_DIR}/${BENCH}
    source ${SCRIPTS_DIR}/benchmarks/${BENCH}/${BENCH}_sizes.sh

    if [[ "${CPU2017_BENCHES[@]}" =~ "${BENCH}" ]]; then
      rm -rf run
      cp -r run-${SIZE} run
      cp src/${BENCH_EXE} run/
    fi

    echo -en '#!/bin/bash\n\n' > run/run.sh

    COMMAND_VAR="${SIZE}_COMMANDS[@]"
    BENCH_COMMANDS=("${!COMMAND_VAR}")
    for RUN in $(seq 0 $(( ${#BENCH_COMMANDS[@]} - 1 )) ); do

      PIN_BASE_COMMAND="${PIN_COMMANDS[${CONFIG}]}"
      if [[ -z ${PIN_BASE_COMMAND} ]]; then
        MY_COMMAND="${PLATFORM_COMMAND} ${SICM_ENV} \
                    ${BENCH_COMMANDS[${RUN}]} \
                    > stdout${RUN}.txt 2> stderr${RUN}.txt"
      else
        PIN_RUN_COMMAND=$(eval "echo ${PIN_BASE_COMMAND}")
        # parse arguments for pin command
        
        MY_COMMAND="${PLATFORM_COMMAND} ${PIN_RUN_COMMAND} -- ${SICM_ENV} \
                    ${BENCH_COMMANDS[${RUN}]} \
                    > stdout${RUN}.txt 2> stderr${RUN}.txt"
      fi

      if [[ ${PARALLEL} = true ]]; then
        MY_COMMAND=${MY_COMMAND}" &"
      fi

      echo ${MY_COMMAND} >> run/run.sh
    done

    END_RUN="\n"
    if [[ ${PARALLEL} ]]; then
      END_RUN="wait${END_RUN}"
    fi
    echo -en "${END_RUN}" >> run/run.sh
    
    eval "./${SETUP}"
    cd $BENCH_DIR/${BENCH}/run
    chmod +x run.sh

    SIM_CONFIG="${SIM_CONFIGS[${CONFIG}]}"
    if [[ -z ${SIM_CONFIG} ]]; then
      ( eval "$CONFIG ${ARGS_SPACES}" )
    else
      ( eval "$SIM_CONFIG ${ARGS_SPACES}" )
    fi

  done
done
