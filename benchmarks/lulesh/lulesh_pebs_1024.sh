#!/bin/bash

cd $SICM_DIR/examples/high/lulesh/run
source $SCRIPTS_DIR/all/pebs.sh
source $SCRIPTS_DIR/benchmarks/lulesh/lulesh_sizes.sh

pebs "1024" "$SMALL"