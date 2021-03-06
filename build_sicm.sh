#!/bin/bash -l
# Builds SICM

source ./all/vars.sh
source ${SCRIPTS_DIR}/all/args.sh

# Compile SICM.
cd ${SICM_PREFIX}/src/
cd sicm
rm -rf build && mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${SICM_PREFIX} \
  -DCMAKE_SYSTEM_NAME="Linux" \
  -DCMAKE_INSTALL_RPATH="${SICM_PREFIX}/lib" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DSICM_BUILD_HIGH_LEVEL=True \
  -DJEMALLOC_ROOT="${SICM_PREFIX}" \
  -DLIBPFM_INSTALL="${SICM_PREFIX}" \
  ..
make -j$(nproc)
make install
cd ..

# Compile the "scripts"
cd ${SCRIPTS_DIR}/all
INCLUDE="-I${SICM_PREFIX}/include"
gcc -g -lm c/stat.c ${INCLUDE} -o stat
gcc -g c/memreserve.c -lnuma -lpthread ${INCLUDE} -o memreserve
