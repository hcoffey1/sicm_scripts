#!/usr/bin/env python3

import sys
import os

def rename(args):

  src = args[1]
  dst = args[2]

  os.rename(("%s/%s_sizes.sh" % (src,src)), ("%s/%s_sizes.sh" % (src,dst)))
  os.rename(("%s/%s_build.sh" % (src,src)), ("%s/%s_build.sh" % (src,dst)))
  os.rename(src, dst)

if __name__ == "__main__":
  rename(sys.argv)
