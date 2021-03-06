#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build "fort"

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

# Compile Lulesh
cd $BENCH_DIR/649.fotonik3d_s/src
make clean
make -j $(nproc --all)
mkdir -p $BENCH_DIR/649.fotonik3d_s/run
