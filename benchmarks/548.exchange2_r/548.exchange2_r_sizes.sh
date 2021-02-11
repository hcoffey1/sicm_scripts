#!/bin/bash

export test_COMMANDS=(
"./exchange2_r 0 0<&-"
)

export train_COMMANDS=(
)

export ref_COMMANDS=(
"./exchange2_r 6 0<&-"
)

export BENCH_EXE=exchange2_r

function 548_exchange2_r_prerun {
  common_prerun
}

function 548_exchange2_r_setup {
  :
}
