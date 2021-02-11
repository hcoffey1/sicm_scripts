#!/bin/bash

export test_COMMANDS=(
"./blender_r cube.blend --render-output cube_ --threads 1 -b -F RAWTGA -s 1 -e 1 -a 0<&-"
)

export train_COMMANDS=(
"./blender_r sh5_reduced.blend --render-output sh5_reduced_ --threads 1 -b -F RAWTGA -s 234 -e 234 -a 0<&-"
)

export ref_COMMANDS=(
"./blender_r sh3_no_char.blend --render-output sh3_no_char_ --threads 1 -b -F RAWTGA -s 849 -e 849 -a 0<&-"
)

export BENCH_EXE=blender_r

function 526_blender_r_prerun {
  common_prerun
}

function 526_blender_r_setup {
  :
}
