#!/bin/bash

export small_COMMANDS=(
"./lulesh2.0 -s 220 -i 3 -r 11 -b 0 -c 64 -p"
)

export medium_COMMANDS=(
"./lulesh2.0 -s 340 -i 12 -r 11 -b 0 -c 64 -p"
)

export large_COMMANDS=(
"./lulesh2.0 -s 420 -i 12 -r 11 -b 0 -c 64 -p"
)

export small_aep_COMMANDS=(
"./lulesh2.0 -s 220 -i 12 -r 11 -b 0 -c 64 -p"
)

export medium_aep_COMMANDS=(
"./lulesh2.0 -s 400 -i 6 -r 11 -b 0 -c 64 -p"
)

export large_aep_COMMANDS=(
"./lulesh2.0 -s 690 -i 3 -r 11 -b 0 -c 64 -p"
)

export huge_aep_COMMANDS=(
"./lulesh2.0 -s 780 -i 3 -r 11 -b 0 -c 64 -p"
)

export BENCH_EXE="./lulesh2.0"

function lulesh_prerun {
  common_prerun
}

function lulesh_setup {
  :
}

