#!/bin/bash

export test_COMMANDS=(
"./bwaves_r bwaves_1 < bwaves_1.in"
"./bwaves_r bwaves_2 < bwaves_2.in"
)

export train_COMMANDS=(
"./bwaves_r bwaves_1 < bwaves_1.in"
"./bwaves_r bwaves_2 < bwaves_2.in"
)

export ref_COMMANDS=(
"./bwaves_r bwaves_1 < bwaves_1.in"
"./bwaves_r bwaves_2 < bwaves_2.in"
"./bwaves_r bwaves_3 < bwaves_3.in"
"./bwaves_r bwaves_4 < bwaves_4.in"
)

export BENCH_EXE=bwaves_r

function 503_bwaves_r_prerun {
  common_prerun
}

function 503_bwaves_r_setup {
  :
}
