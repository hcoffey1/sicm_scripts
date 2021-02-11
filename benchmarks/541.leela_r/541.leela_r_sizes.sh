#!/bin/bash

export test_COMMANDS=(
"./leela_r test.sgf 0<&-"
)

export train_COMMANDS=(
"./leela_r train.sgf 0<&-"
)

export ref_COMMANDS=(
"./leela_r ref.sgf 0<&-"
)

export BENCH_EXE=leela_r

function 541_leela_r_prerun {
  common_prerun
}

function 541_leela_r_setup {
  :
}
