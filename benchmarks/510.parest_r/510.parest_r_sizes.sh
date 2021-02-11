#!/bin/bash

export test_COMMANDS=(
"./parest_r test.prm 0<&-"
)

export train_COMMANDS=(
"./parest_r train.prm 0<&-"
)

export ref_COMMANDS=(
"./parest_r ref.prm 0<&-"
)

export BENCH_EXE=parest_r

function 510_parest_r_prerun {
  common_prerun
}

function 510_parest_r_setup {
  :
}
