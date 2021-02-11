#!/bin/bash

export test_COMMANDS=(
"./roms_r < ocean_benchmark0.in.x"
)

export train_COMMANDS=(
"./roms_r < ocean_benchmark1.in.x"
)

export ref_COMMANDS=(
"./roms_r < ocean_benchmark2.in.x"
)

export BENCH_EXE=roms_r

function 554_roms_r_prerun {
  common_prerun
}

function 554_roms_r_setup {
  :
}
