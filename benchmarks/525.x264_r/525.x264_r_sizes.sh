#!/bin/bash

export test_COMMANDS=(
"./x264_r --dumpyuv 50 --frames 156 -o BuckBunny_New.264 BuckBunny.yuv 1280x720"
)

export train_COMMANDS=(
"./x264_r --dumpyuv 50 --frames 142 -o BuckBunny_New.264 BuckBunny.yuv 1280x720 0<&-"
)

export ref_COMMANDS=(
"./x264_r --pass 1 --stats x264_stats.log --bitrate 1000 --frames 1000 -o BuckBunny_New_0.264 BuckBunny.yuv 1280x720 0<&-"
"./x264_r --pass 2 --stats x264_0_stats.log --bitrate 1000 --dumpyuv 200 --frames 1000 -o BuckBunny_New_1.264 BuckBunny.yuv 1280x720 0<&-"
"./x264_r --seek 500 --dumpyuv 200 --frames 1250 -o BuckBunny_New_2.264 BuckBunny.yuv 1280x720 0<&-"
)

export BENCH_EXE=x264_r

function 525_x264_r_prerun {
  common_prerun
}

function 525_x264_r_setup {
  :
}
