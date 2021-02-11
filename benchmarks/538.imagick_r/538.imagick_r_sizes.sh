#!/bin/bash

export test_COMMANDS=(
"./imagick_r -limit disk 0 test_input.tga -shear 25 -resize 640x480 -negate -alpha Off test_output.tga 0<&-"
)

export train_COMMANDS=(
"./imagick_r -limit disk 0 train_input.tga -resize 320x240 -shear 31 -edge 140 -negate -flop -resize 900x900 -edge 10 train_output.tga 0<&-"
)

export ref_COMMANDS=(
"./imagick_r -limit disk 0 refrate_input.tga -edge 41 -resample 181% -emboss 31 -colorspace YUV -mean-shift 19x19+15% -resize 30% refrate_output.tga 0<&-"
)

export BENCH_EXE=imagick_r

function 538_imagick_r_prerun {
  common_prerun
}

function 538_imagick_r_setup {
  :
}
