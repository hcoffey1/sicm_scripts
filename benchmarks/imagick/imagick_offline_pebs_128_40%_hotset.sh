#!/bin/bash

cd $SICM_DIR/examples/high/imagick/run
source $SCRIPTS_DIR/all/offline_pebs.sh
source $SCRIPTS_DIR/benchmarks/imagick/imagick_sizes.sh

pebs "128" "40" "hotset" "$LARGE"