#!/bin/bash

export test_COMMANDS=(
"./wrf_r 0<&-"
)

export train_COMMANDS=(
"./wrf_r 0<&-"
)

export ref_COMMANDS=(
"./wrf_r 0<&-"
)

export BENCH_EXE=wrf_r

function 521_wrf_r_prerun {
  common_prerun
}

function 521_wrf_r_setup {
  :
}
