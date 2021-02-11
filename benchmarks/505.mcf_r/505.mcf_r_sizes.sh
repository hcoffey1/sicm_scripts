#!/bin/bash

export test_COMMANDS=(
"./mcf_r inp.in 0<&-"
)

export train_COMMANDS=(
"./mcf_r inp.in 0<&-"
)

export ref_COMMANDS=(
"./mcf_r inp.in 0<&-"
)

export BENCH_EXE=mcf_r

function 505_mcf_r_prerun {
  common_prerun
}

function 505_mcf_r_setup {
  :
}
