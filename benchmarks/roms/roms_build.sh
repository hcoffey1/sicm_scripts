#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build fort

export PREPROCESS_WRAPPER="${BENCH_DIR}/cpu2017/bin/specperl -I ${BENCH_DIR}/cpu2017/bin/modules.specpp ${BENCH_DIR}/cpu2017/bin/harness/specpp"

# Compile roms
cd $BENCH_DIR/roms/src
make clean
make -j $(nproc)
mkdir -p $BENCH_DIR/roms/run
cp sroms roms.exe
