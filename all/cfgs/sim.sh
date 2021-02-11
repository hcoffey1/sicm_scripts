#!/bin/bash

PIN_DIR=${SICM_HOME}/pin-3.11
PIN_TOOLS_DIR=${PIN_DIR}/source/tools
PIN_EXE=${PIN_DIR}/pin

declare -A PIN_COMMANDS
declare -A SIM_CONFIGS
declare -A SIM_OUTPUT

PROCCOUNT="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/ManualExamples/obj-intel64/proccount.so"
INSCOUNT="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/ManualExamples/obj-intel64/inscount2.so "'-o inscount${RUN}.out'
WRITEMAP_NO_CACHE="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/WriteMap/obj-intel64/writemap.so "'-o writemap${RUN}.out'
WRITEMAP_SMALL_CACHE="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/WriteMap/obj-intel64/writemap.so -cache 512KBL1 "'-o writemap${RUN}.out -d -wbtxt writebacks${RUN}.txt'
WRITEMAP_LARGE_CACHE="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/WriteMap/obj-intel64/writemap.so -cache 8MBL2 "'-o writemap${RUN}.out -d -wbtxt writebacks${RUN}.txt'
WRITEMAP_SMALL_CACHE_BIN="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/WriteMap/obj-intel64/writemap.so -cache 512KBL1 "'-o writemap${RUN}.out -d -wbbin writebacks${RUN}.bin'
WRITEMAP_LARGE_CACHE_BIN="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/WriteMap/obj-intel64/writemap.so -cache 8MBL2 "'-o writemap${RUN}.out -d -wbbin writebacks${RUN}.bin'
WRITEMAP_SMALL_CACHE_XX="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/WriteMap/obj-intel64/writemap.so -cache 512KBL1 "'-o writemap${RUN}.out -f -r -d -wbtxt writebacks${RUN}.txt -wbbin writebacks${RUN}.bin'
WRITEMAP_LARGE_CACHE_XX="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/WriteMap/obj-intel64/writemap.so -cache 8MBL2 "'-o writemap${RUN}.out -f -r -d -wbtxt writebacks${RUN}.txt -wbbin writebacks${RUN}.bin'
WRITEMAP_SC_LIGHT_BIN="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/WriteMap/obj-intel64/writemap.so -cache 512KBL1 -w 23 -s 13 "'-o writemap${RUN}.out -d -wbbin writebacks${RUN}.bin'
WRITEMAP_LC_LIGHT_BIN="${PIN_EXE} -follow_execv -t ${PIN_TOOLS_DIR}/WriteMap/obj-intel64/writemap.so -cache 8MBL2 -w 23 -s 13 "'-o writemap${RUN}.out -d -wbbin writebacks${RUN}.bin'

function base_sim_cfg {
  eval "${PRERUN}"
  export SH_DEFAULT_NODE="${SH_UPPER_NODE}"

  for i in $(seq 0 $MAX_ITER); do
    DIR="${BASEDIR}/i${i}"
    mkdir ${DIR}

    eval "${COMMAND}" &>> ${DIR}/run_sh_stdout.txt

    COMMAND_VAR="${SIZE}_COMMANDS[@]"
    BENCH_COMMANDS=("${!COMMAND_VAR}")
    for RUN in $(seq 0 $(( ${#BENCH_COMMANDS[@]} - 1 )) ); do
      SIM_OUTPUT_FILES="${SIM_OUTPUT[${CONFIG}]}"
      for SIM_FILE_VAR in ${SIM_OUTPUT_FILES[@]}; do
        FILE=$(eval "echo ${SIM_FILE_VAR}")
        cp ${BENCH_DIR}/${BENCH}/run/${FILE} ${DIR}/

        # bin files can get very large
        if [[ $FILE =~ \.bin$ ]]; then
          rm -f ${BENCH_DIR}/${BENCH}/run/${FILE}
        fi
      done

      cp "${BENCH_DIR}/${BENCH}/run/stdout${RUN}.txt" ${DIR}/
      cp "${BENCH_DIR}/${BENCH}/run/stderr${RUN}.txt" ${DIR}/
    done
  done
}

PIN_COMMANDS["pin_proccount"]=$PROCCOUNT
PIN_COMMANDS["pin_inscount"]=$INSCOUNT
PIN_COMMANDS["pin_writemap_no_cache"]=$WRITEMAP_NO_CACHE
PIN_COMMANDS["pin_writemap_512KBL1"]=$WRITEMAP_SMALL_CACHE
PIN_COMMANDS["pin_writemap_8MBL2"]=$WRITEMAP_LARGE_CACHE
PIN_COMMANDS["pin_writemap_512KBL1_bin"]=$WRITEMAP_SMALL_CACHE_BIN
PIN_COMMANDS["pin_writemap_8MBL2_bin"]=$WRITEMAP_LARGE_CACHE_BIN
PIN_COMMANDS["pin_writemap_512KBL1_xx"]=$WRITEMAP_SMALL_CACHE_XX
PIN_COMMANDS["pin_writemap_8MBL2_xx"]=$WRITEMAP_LARGE_CACHE_XX
PIN_COMMANDS["pin_writemap_SC_light_bin"]=$WRITEMAP_SC_LIGHT_BIN
PIN_COMMANDS["pin_writemap_LC_light_bin"]=$WRITEMAP_LC_LIGHT_BIN

SIM_CONFIGS["pin_proccount"]=base_sim_cfg
SIM_CONFIGS["pin_inscount"]=base_sim_cfg
SIM_CONFIGS["pin_writemap_no_cache"]=base_sim_cfg
SIM_CONFIGS["pin_writemap_512KBL1"]=base_sim_cfg
SIM_CONFIGS["pin_writemap_8MBL2"]=base_sim_cfg
SIM_CONFIGS["pin_writemap_512KBL1_bin"]=base_sim_cfg
SIM_CONFIGS["pin_writemap_8MBL2_bin"]=base_sim_cfg
SIM_CONFIGS["pin_writemap_512KBL1_xx"]=base_sim_cfg
SIM_CONFIGS["pin_writemap_8MBL2_xx"]=base_sim_cfg
SIM_CONFIGS["pin_writemap_SC_light_bin"]=base_sim_cfg
SIM_CONFIGS["pin_writemap_LC_light_bin"]=base_sim_cfg

SIM_OUTPUT["pin_proccount"]=
SIM_OUTPUT["pin_inscount"]='inscount${RUN}.out'
SIM_OUTPUT["pin_writemap_no_cache"]='writemap${RUN}.out'
SIM_OUTPUT["pin_writemap_512KBL1"]='writemap${RUN}.out writebacks${RUN}.txt'
SIM_OUTPUT["pin_writemap_8MBL2"]='writemap${RUN}.out writebacks${RUN}.txt'
SIM_OUTPUT["pin_writemap_512KBL1_bin"]='writemap${RUN}.out writebacks${RUN}.bin'
SIM_OUTPUT["pin_writemap_8MBL2_bin"]='writemap${RUN}.out writebacks${RUN}.bin'
SIM_OUTPUT["pin_writemap_512KBL1_xx"]='writemap${RUN}.out writebacks${RUN}.txt writebacks${RUN}.bin'
SIM_OUTPUT["pin_writemap_8MBL2_xx"]='writemap${RUN}.out writebacks${RUN}.txt writebacks${RUN}.bin'
SIM_OUTPUT["pin_writemap_SC_light_bin"]='writemap${RUN}.out writebacks${RUN}.bin'
SIM_OUTPUT["pin_writemap_LC_light_bin"]='writemap${RUN}.out writebacks${RUN}.bin'

