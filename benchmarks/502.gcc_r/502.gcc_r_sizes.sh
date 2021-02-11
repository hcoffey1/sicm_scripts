#!/bin/bash

export test_COMMANDS=(
"./cpugcc_r t1.c -O3 -finline-limit=50000 -o t1.opts-O3_-finline-limit_50000.s 0<&-"
)

export train_COMMANDS=(
"./cpugcc_r 200.c -O3 -finline-limit=50000 -o 200.opts-O3_-finline-limit_50000.s 0<&-"
"./cpugcc_r scilab.c -O3 -finline-limit=50000 -o scilab.opts-O3_-finline-limit_50000.s 0<&-"
"./cpugcc_r train01.c -O3 -finline-limit=50000 -o train01.opts-O3_-finline-limit_50000.s 0<&-"
)

export ref_COMMANDS=(
"./cpugcc_r gcc-pp.c -O3 -finline-limit=0 -fif-conversion -fif-conversion2 -o gcc-pp.opts-O3_-finline-limit_0_-fif-conversion_-fif-conversion2.s 0<&-"
"./cpugcc_r gcc-pp.c -O2 -finline-limit=36000 -fpic -o gcc-pp.opts-O2_-finline-limit_36000_-fpic.s 0<&-"
"./cpugcc_r gcc-smaller.c -O3 -fipa-pta -o gcc-smaller.opts-O3_-fipa-pta.s 0<&-"
"./cpugcc_r ref32.c -O5 -o ref32.opts-O5.s 0<&-"
"./cpugcc_r ref32.c -O3 -fselective-scheduling -fselective-scheduling2 -o ref32.opts-O3_-fselective-scheduling_-fselective-scheduling2.s 0<&-"
)

export BENCH_EXE=cpugcc_r

function 502_gcc_r_prerun {
  common_prerun
}

function 502_gcc_r_setup {
  :
}
