#!/bin/bash

export test_COMMANDS=(
"./perlbench_r -I. -I./lib makerand.pl 0<&-"
"./perlbench_r -I. -I./lib test.pl 0<&-"
)

export train_COMMANDS=(
"./perlbench_r -I./lib diffmail.pl 2 550 15 24 23 100 0<&-"
"./perlbench_r -I./lib perfect.pl b 3 0<&-"
"./perlbench_r -I. -I./lib scrabbl.pl < scrabbl.in"
"./perlbench_r -I./lib splitmail.pl 535 13 25 24 1091 1 0<&-"
"./perlbench_r -I. -I./lib suns.pl 0<&-"
)

export ref_COMMANDS=(
"./perlbench_r -I./lib checkspam.pl 2500 5 25 11 150 1 1 1 1 0<&-"
"./perlbench_r -I./lib diffmail.pl 4 800 10 17 19 300 0<&-"
"./perlbench_r -I./lib splitmail.pl 6400 12 26 16 100 0 0<&-"
)

export BENCH_EXE=perlbench_r

function 500_perlbench_r_prerun {
  common_prerun
}

function 500_perlbench_r_setup {
  :
}
