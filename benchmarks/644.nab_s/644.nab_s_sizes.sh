#!/bin/bash

export REF="./nab_s 3j1n 20140317 220"
export TRAIN="./nab_s aminos 391519156 1000; ./nab_s gcn4dna 1850041461 300"
export TEST="./nab_s hkrdenq 1930344093 1000"

function 644_nab_s_prerun {
  if [[ $SH_ARENA_LAYOUT = "SHARED_SITE_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  elif [[ $SH_ARENA_LAYOUT = "BIG_SMALL_ARENAS" ]]; then
    export JE_MALLOC_CONF="oversize_threshold:0,background_thread:true,max_background_threads:1"
  else
    export JE_MALLOC_CONF="oversize_threshold:0"
  fi
}

function 644_nab_s_setup {
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
  cp src/nab_s run/
}
