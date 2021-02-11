#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

cd $BENCH_DIR/531.deepsjeng_r/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/531.deepsjeng_r/run
