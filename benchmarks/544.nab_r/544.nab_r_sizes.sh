#!/bin/bash

export test_COMMANDS=(
"./nab_r hkrdenq 1930344093 1000 0<&-"
)

export train_COMMANDS=(
"./nab_r aminos 391519156 1000 0<&-"
"./nab_r gcn4dna 1850041461 300 0<&-"
)

export ref_COMMANDS=(
"./nab_r 1am0 1122214447 122 0<&-"
)

export BENCH_EXE=nab_r

function 544_nab_r_prerun {
  common_prerun
}

function 544_nab_r_setup {
  :
}
