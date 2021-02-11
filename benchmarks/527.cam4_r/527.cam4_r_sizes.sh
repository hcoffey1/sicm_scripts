#!/bin/bash

export test_COMMANDS=(
"./cam4_r 0<&-"
)

export train_COMMANDS=(
"./cam4_r 0<&-"
)

export ref_COMMANDS=(
"./cam4_r 0<&-"
)

export BENCH_EXE=cam4_r

function 527_cam4_r_prerun {
  common_prerun
}

function 527_cam4_r_setup {
  :
}
