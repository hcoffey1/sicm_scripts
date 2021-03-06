#!/bin/bash

function dep_build {
  echo "UNPATCHED_PREFIX: ${UNPATCHED_PREFIX}"
  # The idea here is to default to using the unpatched binaries/libraries,
  # but fall back to the patched ones.
  export PATH="${UNPATCHED_PREFIX}/bin:${SICM_PREFIX}/bin:${PATH}"
  export LD_LIBRARY_PATH="${UNPATCHED_PREFIX}/lib:${SICM_PREFIX}/lib:${LD_LIBRARY_PATH}"
  export LIBRARY_PATH="${UNPATCHED_PREFIX}/lib:${SICM_PREFIX}/lib:${LIBRARY_PATH}"
  export CPATH="${UNPATCHED_PREFIX}/include:${SICM_PREFIX}/include:${CPATH}"
  export CMAKE_PREFIX_PATH="${UNPATCHED_PREFIX}/:${SICM_PREFIX}/:${CMAKE_PREFIX_PATH}"
  export FC="${SICM_PREFIX}/bin/flang -L${UNPATCHED_PREFIX}/lib/"
  export F77="${SICM_PREFIX}/bin/flang -L${UNPATCHED_PREFIX}/lib/"
  export F90="${SICM_PREFIX}/bin/flang -L${UNPATCHED_PREFIX}/lib/"
  export CC="${SICM_PREFIX}/bin/clang -L${UNPATCHED_PREFIX}/lib/"
  export CXX="${SICM_PREFIX}/bin/clang++ -L${UNPATCHED_PREFIX}/lib/"
}

# First argument is "fort" or "c", which linker we should use
# Second argument is a list of linker flags to add, which are just appended
# Third argument is a list of compiler flags to add, which are just appended
function bench_build {
  export PATH="${SICM_PREFIX}/bin:${PATH}"
  export LD_LIBRARY_PATH="${SICM_PREFIX}/lib:${LD_LIBRARY_PATH}"
  export LIBRARY_PATH="${SICM_PREFIX}/lib:${LIBRARY_PATH}"
  export CPATH="${SICM_PREFIX}/include:${CPATH}"
  export CMAKE_PREFIX_PATH="${SICM_PREFIX}/:${CMAKE_PREFIX_PATH}"
  export FC="${SICM_PREFIX}/bin/flang"
  export F77="${SICM_PREFIX}/bin/flang"
  export F90="${SICM_PREFIX}/bin/flang"
  
  if [ "$1" = "fort" ]; then
    export LD_LINKER="flang $2 -Wno-unused-command-line-argument -Wl,-rpath,${SICM_PREFIX}/lib -L${SICM_PREFIX}/lib -lflang -lflangrti -g"
  elif [ "$1" = "c" ]; then
    export LD_LINKER="clang++ $2 -Wno-unused-command-line-argument -L${SICM_PREFIX}/lib -lpgmath -lflang -lflangrti -Wl,-rpath,${SICM_PREFIX}/lib -g"
  else
    echo "No linker specified. Aborting."
    exit
  fi
    
  #HC
  export LD_FLAGS="$2 -L${SICM_PREFIX}/lib -lpgmath -Wl,-rpath,${SICM_PREFIX}/lib -g"
  #export LD_FLAGS="$2 -L${SICM_PREFIX}/lib -lpgmath -lflang -lflangrti -Wl,-rpath,${SICM_PREFIX}/lib -g"
  export MPIC_COMPILER="mpicc $3 -march=x86-64 -g -I${SICM_PREFIX}/include"

  # Define the variables for the compiler wrappers
  export LD_COMPILER="clang++ -Wno-unused-command-line-argument -march=x86-64 -g -L${SICM_PREFIX}/lib" # Compiles from .bc -> .o
  export CXX_COMPILER="clang++ $3  -Wno-unused-command-line-argument -march=x86-64 -g -I${SICM_PREFIX}/include"
  export FORT_COMPILER="flang $3  -Mpreprocess -Wno-unused-command-line-argument -march=x86-64 -I${SICM_PREFIX}/include -L${SICM_PREFIX}/lib -lflang -lflangrti -g"
  export C_COMPILER="clang  $3 -Wno-unused-command-line-argument -march=x86-64 -g -I${SICM_PREFIX}/include"
  export LLVMLINK="llvm-link"
  export LLVMOPT="opt"

  # Make sure the Makefiles find our wrappers
  export COMPILER_WRAPPER="compiler_wrapper.sh "
  export LD_WRAPPER="ld_wrapper.sh "
  export PREPROCESS_WRAPPER="clang -E -x c -P "
  export AR_WRAPPER="ar_wrapper.sh "
  export RANLIB_WRAPPER="ranlib_wrapper.sh "
}

function bench_build_no_transform {
  bench_build $@
  export NO_TRANSFORM="yes"
}
