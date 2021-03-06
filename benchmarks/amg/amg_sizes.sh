#!/bin/bash

OLD="./amg -problem 2 -n 120 120 120"

export small_COMMANDS=(
"./amg -problem 2 -n 120 120 120"
)

export medium_COMMANDS=(
"./amg -problem 2 -n 220 220 220"
)
LARGE="./amg -problem 2 -n 270 270 270"

SMALL_AEP="./amg -problem 2 -n 120 120 120"
MEDIUM_AEP="./amg -problem 2 -n 340 340 340"
LARGE_AEP="./amg -problem 2 -n 520 520 520"
HUGE_AEP="./amg -problem 2 -n 600 600 600"

function amg_prerun {
    export SH_MAX_SITES="9000"
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
  echo "Using JE_MALLOC_CONF='$JE_MALLOC_CONF'."
  common_prerun
}

function amg_setup {
    :
}
