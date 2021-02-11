#!/bin/bash

export test_COMMANDS=(
"./fotonik3d_r 0<&-"
)

export train_COMMANDS=(
"./fotonik3d_r 0<&-"
)

export ref_COMMANDS=(
"./fotonik3d_r 0<&-"
)

export BENCH_EXE=fotonik3d_r

function 549_fotonik3d_r_prerun {
  common_prerun
}

function 549_fotonik3d_r_setup {
  :
}
