#!/bin/bash

export test_COMMANDS=(
"./cpuxalan_r -v test.xml xalanc.xsl 0<&-"
)

export train_COMMANDS=(
"./cpuxalan_r -v allbooks.xml xalanc.xsl 0<&-"
)

export ref_COMMANDS=(
"./cpuxalan_r -v t5.xml xalanc.xsl 0<&-"
)

export BENCH_EXE=cpuxalan_r

function 523_xalancbmk_r_prerun {
  common_prerun
}

function 523_xalancbmk_r_setup {
  :
}
