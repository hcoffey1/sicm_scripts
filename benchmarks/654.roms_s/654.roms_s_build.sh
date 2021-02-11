#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

# Compile roms
cd $BENCH_DIR/654.roms_s/src
make clean
make -j $(nproc)
mkdir -p $BENCH_DIR/654.roms_/run
