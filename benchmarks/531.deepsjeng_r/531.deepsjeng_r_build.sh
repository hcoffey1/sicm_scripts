#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

export PREPROCESS_WRAPPER="${BENCH_DIR}/suites/cpu2017/bin/specperl -I ${BENCH_DIR}/suites/cpu2017/bin/modules.specpp ${BENCH_DIR}/suites/cpu2017/bin/harness/specpp"

cd $BENCH_DIR/suites/cpu2017/benchspec/CPU/531.deepsjeng_r/build/build_base_hcoffey1-m64.0000
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/suites/cpu2017/benchspec/CPU/531.deepsjeng_r/run
