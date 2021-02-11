#!/bin/bash

#./run.sh --bench=502.gcc_r --size=test --iters=1 \
#  --config=pin_inscount --args=- --parallel &


#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=profile_all_and_pagemap --args=256,10000


./run.sh --bench=lulesh --size=small --iters=1 \
  --config=firsttouch_exclusive_device --args=-

./run.sh --bench=lulesh --size=small --iters=1 \
  --config=guided_compress --args=32,1 \
  --profile="/home/mrjantz/projects/bitflip/results/lulesh/small/profile_all_and_pagemap:256_10000/i0/guidance-knapsack-touched-accesses-01.txt"
#
#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=guided_compress --args=32,2 \
#  --profile="/home/mrjantz/projects/bitflip/results/lulesh/small/profile_all_and_pagemap:256_10000/i0/guidance-knapsack-touched-accesses-02.txt"
#
#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=guided_compress --args=32,5 \
#  --profile="/home/mrjantz/projects/bitflip/results/lulesh/small/profile_all_and_pagemap:256_10000/i0/guidance-knapsack-touched-accesses-05.txt"
#
#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=guided_compress --args=31,1 \
#  --profile="/home/mrjantz/projects/bitflip/results/lulesh/small/profile_all_and_pagemap:256_10000/i0/guidance-knapsack-touched-accesses-01.txt"
#
#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=guided_compress --args=31,2 \
#  --profile="/home/mrjantz/projects/bitflip/results/lulesh/small/profile_all_and_pagemap:256_10000/i0/guidance-knapsack-touched-accesses-02.txt"
#
#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=guided_compress --args=31,5 \
#  --profile="/home/mrjantz/projects/bitflip/results/lulesh/small/profile_all_and_pagemap:256_10000/i0/guidance-knapsack-touched-accesses-05.txt"
#
#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=guided_compress --args=33,1 \
#  --profile="/home/mrjantz/projects/bitflip/results/lulesh/small/profile_all_and_pagemap:256_10000/i0/guidance-knapsack-touched-accesses-01.txt"
#
#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=guided_compress --args=33,2 \
#  --profile="/home/mrjantz/projects/bitflip/results/lulesh/small/profile_all_and_pagemap:256_10000/i0/guidance-knapsack-touched-accesses-02.txt"
#
#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=guided_compress --args=33,5 \
#  --profile="/home/mrjantz/projects/bitflip/results/lulesh/small/profile_all_and_pagemap:256_10000/i0/guidance-knapsack-touched-accesses-05.txt"

#./run.sh --bench=lulesh --size=small --iters=1 \
#  --config=profile_all_exclusive_device --args=256,10

#./run.sh --bench=500.perlbench_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=502.gcc_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=503.bwaves_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=505.mcf_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=507.cactuBSSN_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=508.namd_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=510.parest_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=511.povray_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=519.lbm_r --size=ref --iters=1 \
#  --config=pin_writemap_light_LC_bin --args=- --parallel &
#
#./run.sh --bench=520.omnetpp_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=521.wrf_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=523.xalancbmk_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &

#./run.sh --bench=525.x264_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=526.blender_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=527.cam4_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=531.deepsjeng_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=538.imagick_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=541.leela_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=544.nab_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=548.exchange2_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=549.fotonik3d_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=554.roms_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &
#
#./run.sh --bench=557.xz_r --size=ref --iters=1 \
#  --config=pin_writemap_8MBL2_bin --args=- --parallel &

wait
