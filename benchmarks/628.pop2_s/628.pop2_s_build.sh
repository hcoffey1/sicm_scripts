#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort
export SH_CONTEXT="0"

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

cd $BENCH_DIR/628.pop2_s/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/688.pop2_s/run
