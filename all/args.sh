#!/bin/bash

source ./all/vars.sh

# Arguments
GETOPT_OUTPUT=`getopt -o ebcsagumipnrtlxyfGP --long site:,parallel,eps,bench:,config:,graph_title:,size:,args:,x_label:,y_label:,groupsize:,groupname:,label:,metric:,iters:,profile:,node:,baseconfig:,base_args:,filename: -n 'args.sh' -- "$@"`
if [ $? != 0 ] ; then echo "'getopt' failed. Aborting." >&2 ; exit 1 ; fi
eval set -- "$GETOPT_OUTPUT"

declare -a CPU2017_BENCHES=(
  "500.perlbench_r"
  "502.gcc_r"
  "503.bwaves_r"
  "505.mcf_r"
  "507.cactuBSSN_r"
  "508.namd_r"
  "510.parest_r"
  "511.povray_r"
  "519.lbm_r"
  "520.omnetpp_r"
  "521.wrf_r"
  "523.xalancbmk_r"
  "525.x264_r"
  "526.blender_r"
  "527.cam4_r"
  "531.deepsjeng_r"
  "538.imagick_r"
  "541.leela_r"
  "544.nab_r"
  "548.exchange2_r"
  "549.fotonik3d_r"
  "554.roms_r"
  "557.xz_r"
  "600.perlbench_s"
  "602.gcc_s"
  "603.bwaves_s"
  "605.mcf_s"
  "607.cactuBSSN_s"
  "619.lbm_s"
  "620.omnetpp_s"
  "621.wrf_s"
  "623.xalancbmk_s"
  "625.x264_s"
  "627.cam4_s"
  "628.pop2_s"
  "631.deepsjeng_s"
  "638.imagick_s"
  "641.leela_s"
  "644.nab_s"
  "648.exchange2_s"
  "649.fotonik3d_s"
  "654.roms_s"
  "657.xz_s"
)

declare -a CORAL_BENCHES=(
  "lulesh",
  "amg",
  "snap",
  "qmcpack"
)

export ALL_BENCHES=("${CPU2017_BENCHES}" "${CORAL_BENCHES}")

# Handle arguments
NODE=""
BENCHES=()
CONFIGS=()
GROUPSIZE="0"
BASECONFIG=""
BASECONFIG_ARGS_STR=""
SIZE=""
CONFIG_ARGS_STRS=()
ITERS="3"
METRIC=""
PROFILE_DIR=""
X_LABEL=""
Y_LABEL=""
FILENAME=""
GRAPH_TITLE=""
GROUPNAMES=()
LABELS=()
SITE=""
EPS=false
PARALLEL=false
while true; do
  case "$1" in
    -b | --bench ) BENCHES+=("$2"); shift 2;;
    -c | --config ) CONFIGS+=("$2"); shift 2;;
    -x | --x_label ) X_LABEL="$2"; shift 2;;
    -y | --y_label ) Y_LABEL="$2"; shift 2;;
    -g | --groupsize ) GROUPSIZE="$2"; shift 2;;
    -u | --groupname ) GROUPNAMES+=("$2"); shift 2;;
    -l | --label ) LABELS+=("$2"); shift 2;;
    -a | --args ) CONFIG_ARGS_STRS+=("$2"); shift 2;;
    -r | --baseconfig ) BASECONFIG="$2"; shift 2;;
    -t | --base_args ) BASECONFIG_ARGS_STR="$2"; shift 2;;
    -s | --size ) SIZE="$2"; shift 2;;
    -m | --metric ) METRIC="$2"; shift 2;;
    -i | --iters ) ITERS="$2"; shift 2;;
    -p | --profile ) PROFILE="$2"; shift 2;;
    -n | --node ) NODE="$2"; shift 2;;
    -f | --filename ) FILENAME="$2"; shift 2;;
    -G | --graph_title ) GRAPH_TITLE="$2"; shift 2;;
    -z | --site ) SITE="$2"; shift 2;;
    -e | --eps ) EPS=true; shift 1;;
    -P | --parallel ) PARALLEL=true; shift 1;;
    -- ) shift; break;;
    * ) break;;
  esac
done

MAX_ITER=$(echo "$ITERS - 1" | bc)

export SICM="sicm-high"

# Get the number of NUMA nodes on the system
export NUM_NUMA_NODES=$(lscpu | awk '/NUMA node\(s\).*/{print $3;}')

# CONFIG_ARGS is an array of strings.
# Each string contains a space-delimited list of arguments.
CONFIG_ARGS=()
CONFIG_ARGS_UNDERSCORES=()
for args in ${CONFIG_ARGS_STRS[@]}; do
  if [[ ${args} = "-" ]]; then
    CONFIG_ARGS+=(" ")
    CONFIG_ARGS_UNDERSCORES+=(" ")
    continue
  fi
  CONFIG_ARGS+=("${args//,/ }")
  CONFIG_ARGS_UNDERSCORES+=(${args//,/_})
done

# BASECONFIG ARGS
BASECONFIG_ARGS=""
BASECONFIG_ARGS_UNDERSCORES=""
if [[ ${BASECONFIG_ARGS_STR} = "-" ]]; then
  BASECONFIG_ARGS=" "
  BASECONFIG_ARGS_UNDERSCORES=" "
else
  BASECONFIG_ARGS="${BASECONFIG_ARGS_STR//,/ }"
  BASECONFIG_ARGS_UNDERSCORES=${BASECONFIG_ARGS_STR//,/_}
fi

# Each member of the FULL_CONFIGS array is a full configuration string:
# the config name, a colon, and an underscore-delimited list of arguments to that config.
CTR=0
while true; do
  if [[ ! ${CONFIG_ARGS_UNDERSCORES[${CTR}]} ]]; then
    break
  fi
  if [[ ! ${CONFIGS[${CTR}]} ]]; then
    break
  fi

  FULL_CONFIGS+=(${CONFIGS[${CTR}]}:${CONFIG_ARGS_UNDERSCORES[${CTR}]})

  CTR=$(echo "$CTR + 1" | bc)
done

FULL_BASECONFIG=""
if [[ ! -z "${BASECONFIG}" ]]; then
  FULL_BASECONFIG="${BASECONFIG}:${BASECONFIG_ARGS_UNDERSCORES}"
fi

export SICM_ENV="env LD_LIBRARY_PATH="${SICM_PREFIX}/lib:${LD_LIBRARY_PATH}" LD_PRELOAD='${SICM_PREFIX}/lib/libsicm_overrides.so'"

function common_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
  #echo "Using JE_MALLOC_CONF='$JE_MALLOC_CONF'."
}
