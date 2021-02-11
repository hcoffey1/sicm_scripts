#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build "fort"

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"
export SH_CONTEXT="0"

cd $BENCH_DIR/521.wrf_r/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/521.wrf_r/run
