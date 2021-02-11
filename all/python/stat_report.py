#!/usr/bin/env python3

from lib.globals import *
from lib.postprocess import *
from lib.report import *

import sys
import argparse
import pickle

bench_sets = {
  "all" : [
    "fotonik3d-large",
    "lulesh-large",
    "amg-large",
    "snap-large",
    "qmcpack-large"
  ]
}

config_sets = {
  "default" : [
    "firsttouch_exclusive_device:",
#    "firsttouch_exclusive_device:shuffle_off",
    "guided_offline:0GB_8GB_cache",
    "guided_offline:8GB_8GB_cache",
    "guided_offline:16GB_8GB_cache",
    "guided_offline:24GB_8GB_cache",
    "guided_offline:16GB_flat",
    "guided_offline:24GB_flat",
  ]
}

def main(args):
  parser = argparse.ArgumentParser()
  parser.add_argument('-b',  '--benches',  default="all",     required=False)
  parser.add_argument('-g',  '--configs',  default="default", required=False)
  parser.add_argument('-s',  '--stat',     default=FOM,       required=False)
  parser.add_argument('-y',  '--style',    default=MEAN,      required=False)
  parser.add_argument('-a',  '--absolute', default=False,     action='store_true', required=False)
  parser.add_argument('-c',  '--ci95',     default=False,     action='store_true', required=False)
  parser.add_argument('-i',  '--iters',    default=5,         type=int,            required=False)

  args = parser.parse_args()
  if not (args.benches in bench_sets.keys()):
    print ("invalid benches: %s" % args.benches)
    return 1

  if not (args.configs in config_sets.keys()):
    print ("invalid configs: %s" % args.configs)
    return 1

  stat_report(bench_sets[args.benches], config_sets[args.configs],
              args.iters, args.stat, args.absolute, args.ci95,
              args.style)

if __name__ == "__main__":
  main(sys.argv)

