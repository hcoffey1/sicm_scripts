#!/bin/bash

export test_COMMANDS=(
"./namd_r --input apoa1.input --iterations 1 --output apoa1.test.output 0<&-"
)

export train_COMMANDS=(
"./namd_r --input apoa1.input --iterations 7 --output apoa1.train.output 0<&-"
)

export ref_COMMANDS=(
"./namd_r --input apoa1.input --output apoa1.ref.output --iterations 65 0<&-"
)

export BENCH_EXE=namd_r

function 508_namd_r_prerun {
  common_prerun
}

function 508_namd_r_setup {
  :
}
