#!/bin/bash
export test_COMMANDS=(
"./omp-csr"
) 

export toy_COMMANDS=(
"./omp-csr -s 26 -e 16"
) 

export mini_COMMANDS=(
"./omp-csr -s 29 -e 16"
)

export small_COMMANDS=(
"./omp-csr -s 32 -e 16"
)

#"mpiexec --use-hwthread-cpus ./graph500_reference_bfs_sssp 36 16"
export medium_COMMANDS=(
"./omp-csr -s 36 -e 16"
)

export large_COMMANDS=(
"mpiexec --use-hwthread-cpus ./graph500_reference_bfs_sssp 39 16"
)

export huge_COMMANDS=(
"mpiexec --use-hwthread-cpus ./graph500_reference_bfs_sssp 42 16"
)

#export small_aep_COMMANDS=(
#"./lulesh2.0 -s 220 -i 12 -r 11 -b 0 -c 64 -p"
#)
#
#export medium_aep_COMMANDS=(
#"./lulesh2.0 -s 400 -i 6 -r 11 -b 0 -c 64 -p"
#)
#
#export large_aep_COMMANDS=(
#"./lulesh2.0 -s 690 -i 3 -r 11 -b 0 -c 64 -p"
#)
#
#export huge_aep_COMMANDS=(
#"./lulesh2.0 -s 780 -i 3 -r 11 -b 0 -c 64 -p"
#)

export BENCH_EXE="./graph500_reference_bfs_sssp"

function graph500_prerun {
  common_prerun
}

function graph500_setup {
  :
}

