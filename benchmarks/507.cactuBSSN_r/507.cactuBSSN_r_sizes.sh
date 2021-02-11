#!/bin/bash

export test_COMMANDS=(
"./cactusBSSN_r spec_test.par 0<&-"
)

export train_COMMANDS=(
"./cactusBSSN_r spec_train.par 0<&-"
)

export ref_COMMANDS=(
"./cactusBSSN_r spec_ref.par 0<&-"
)

export BENCH_EXE=cactusBSSN_r

function 507_cactuBSSN_r_prerun {
  common_prerun
}

function 507_cactuBSSN_r_setup {
  :
}
