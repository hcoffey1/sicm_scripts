#!/bin/bash

export REF="./lbm.exe 2000 reference.dat 0 0 200_200_260_ldc.of"
export TRAIN="./lbm.exe 300 reference.dat 0 1 200_200_260_ldc.of"
export TEST="./lbm.exe 20 reference.dat 0 1 200_200_260_ldc.of"

function 619_lbm_s_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
}

function 619_lbm_s_setup {
  if [[ $SIZE = "ref" ]]; then
    rm -rf run
    cp -r run-ref run
  elif [[ $SIZE = "train" ]]; then
    rm -rf run
    cp -r run-train run
  elif [[ $SIZE = "test" ]]; then
    rm -rf run
    cp -r run-test run
  fi
  cp src/lbm_s run/
}
