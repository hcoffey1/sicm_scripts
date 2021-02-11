#!/bin/bash

export test_COMMANDS=(
"./lbm_r 20 reference.dat 0 1 100_100_130_cf_a.of 0<&-"
)

export train_COMMANDS=(
"./lbm_r 300 reference.dat 0 1 100_100_130_cf_b.of 0<&-"
)

export ref_COMMANDS=(
"./lbm_r 3000 reference.dat 0 0 100_100_130_ldc.of 0<&-"
)

export BENCH_EXE=lbm_r

function 519_lbm_r_prerun {
  common_prerun
}

function 519_lbm_r_setup {
  :
}
