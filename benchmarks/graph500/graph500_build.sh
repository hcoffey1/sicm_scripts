#!/bin/bash

source $SCRIPTS_DIR/all/bench_build.sh
bench_build c

# Compile Graph500 
cd $BENCH_DIR/graph500/src
make clean
make -j $(nproc --all)
mkdir -p ../run

cp omp-csr/omp-csr ../run/omp-csr
#cp graph500_reference_bfs_sssp ../run/graph500_reference_bfs_sssp
