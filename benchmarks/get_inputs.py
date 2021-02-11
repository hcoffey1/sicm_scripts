#!/usr/bin/env python3

import sys
import os
import glob

benchmarks_dir = "/home/mrjantz/projects/bitflip/benchmarks"
scripts_dir = "/home/mrjantz/projects/bitflip/sicm_scripts"

def get_inputs(args):

  bench = args[1]

  testcmds = []
  testdir = benchmarks_dir + ("/%s/run-test" % bench)
  for runfile in sorted(glob.glob("%s/run-*.sh" % testdir)):
    runf = open(runfile)
    next(runf)
    next(runf)
    testcmds.append(" ".join(next(runf).split()[:-4]))
    runf.close()

  traincmds = []
  traindir = benchmarks_dir + ("/%s/run-train" % bench)
  for runfile in sorted(glob.glob("%s/run-*.sh" % traindir)):
    runf = open(runfile)
    next(runf)
    next(runf)
    traincmds.append(" ".join(next(runf).split()[:-4]))
    runf.close()

  refcmds = []
  refdir = benchmarks_dir + ("/%s/run-ref" % bench)
  for runfile in sorted(glob.glob("%s/run-*.sh"%refdir)):
    runf = open(runfile)
    next(runf)
    next(runf)
    refcmds.append(" ".join(next(runf).split()[:-4]))
    runf.close()

  outlines = []
  outlines.append("#!/bin/bash\n")
  outlines.append("\n")
  outlines.append("export test_COMMANDS=(\n")
  for cmd in testcmds:
    outlines.append("\"%s\"\n" % cmd)
  outlines.append(")\n")
  outlines.append("\n")

  outlines.append("export train_COMMANDS=(\n")
  for cmd in traincmds:
    outlines.append("\"%s\"\n" % cmd)
  outlines.append(")\n")
  outlines.append("\n")

  outlines.append("export ref_COMMANDS=(\n")
  for cmd in refcmds:
    outlines.append("\"%s\"\n" % cmd)
  outlines.append(")\n")
  outlines.append("\n")

  sizesf = open(scripts_dir + ("/benchmarks/%s/%s_sizes.sh" % (bench,bench)))
  ready = False
  for line in sizesf:
    if line.startswith("export BENCH_EXE"):
      ready = True
    if ready:
      outlines.append(line)
  sizesf.close()

  sizesf = open(scripts_dir + ("/benchmarks/%s/%s_sizes.sh" % (bench,bench)), 'w')
  for outline in outlines:
    print (outline, file=sizesf, end='')
  sizesf.close()
  
if __name__ == "__main__":
  get_inputs(sys.argv)
