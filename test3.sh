#!/bin/bash

./run.sh --bench=519.lbm_r --size=ref --iters=1 \
  --config=pin_writemap_LC_light_bin --args=- --parallel &

#./run.sh --bench=511.povray_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=519.lbm_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=520.omnetpp_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &

#./run.sh --bench=510.parest_r --size=test --iters=1 \
#  --config=pin_inscount --args=- --parallel &
#
#./run.sh --bench=511.povray_r --size=test --iters=1 \
#  --config=pin_inscount --args=- --parallel &
#
#./run.sh --bench=519.lbm_r --size=test --iters=1 \
#  --config=pin_inscount --args=- --parallel &
#
#./run.sh --bench=520.omnetpp_r --size=test --iters=1 \
#  --config=pin_inscount --args=- --parallel &

wait
