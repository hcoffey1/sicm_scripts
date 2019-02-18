#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

# Compile Lulesh
cd $BENCH_DIR/lulesh/src
make clean
make -j $(nproc --all)
mkdir -p ../run
cp lulesh2.0 ../run/lulesh2.0
