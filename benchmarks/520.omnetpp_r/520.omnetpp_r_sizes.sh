#!/bin/bash

export test_COMMANDS=(
"./omnetpp_r -c General -r 0 0<&-"
)

export train_COMMANDS=(
"./omnetpp_r -c General -r 0 0<&-"
)

export ref_COMMANDS=(
"./omnetpp_r -c General -r 0 0<&-"
)

export BENCH_EXE=omnetpp_r

function 520_omnetpp_r_prerun {
  common_prerun
}

function 520_omnetpp_r_setup {
  :
}
