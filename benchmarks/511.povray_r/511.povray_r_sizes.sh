#!/bin/bash

export test_COMMANDS=(
"./povray_r SPEC-benchmark-test.ini 0<&-"
)

export train_COMMANDS=(
)

export ref_COMMANDS=(
"./povray_r SPEC-benchmark-ref.ini 0<&-"
)

export BENCH_EXE=povray_r

function 511_povray_r_prerun {
  common_prerun
}

function 511_povray_r_setup {
  :
}
