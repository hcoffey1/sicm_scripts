#!/bin/bash

export test_COMMANDS=(
"./deepsjeng_r test.txt 0<&-"
)

export train_COMMANDS=(
"./deepsjeng_r train.txt 0<&-"
)

export ref_COMMANDS=(
"./deepsjeng_r ref.txt 0<&-"
)

export BENCH_EXE=deepsjeng_r

function 531_deepsjeng_r_prerun {
  common_prerun
}

function 531_deepsjeng_r_setup {
  :
}
