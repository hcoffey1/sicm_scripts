#!/bin/bash

./run.sh --bench=500.perlbench_r --size=ref --iters=1 \
  --config=pin_writemap_8MBL2_bin --args=- --parallel &

#./run.sh --bench=525.x264_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=526.blender_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=527.cam4_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &

#./run.sh --bench=523.xalancbmk_r --size=test --iters=1 \
#  --config=pin_inscount --args=- --parallel &

#./run.sh --bench=525.x264_r --size=test --iters=1 \
#  --config=pin_inscount --args=- --parallel &

#./run.sh --bench=526.blender_r --size=test --iters=1 \
#  --config=pin_inscount --args=- --parallel &

#./run.sh --bench=527.cam4_r --size=test --iters=1 \
#  --config=pin_inscount --args=- --parallel &

wait

