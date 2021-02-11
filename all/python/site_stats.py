#!/usr/bin/env python3

from lib.globals import *
from lib.postprocess import *
from lib.report import *

import sys
import argparse
import pickle

def main(args):
  parser = argparse.ArgumentParser()
  parser.add_argument('-b',  '--bench',  required=True)
  parser.add_argument('-z',  '--size',   required=True)
  parser.add_argument('-g',  '--config', required=True)
  parser.add_argument('-a',  '--args',   required=True)
  parser.add_argument('-r',  '--report', default="abs_base", required=False)
  parser.add_argument('-k1', '--sk1',    default=PER_SITE,   required=False)
  parser.add_argument('-k2', '--sk2',    default=ABSOLUTE,   required=False)
  parser.add_argument('-k3', '--sk3',    default=DDR_ACCS,   required=False)
  parser.add_argument('-k4', '--sk4',    default=None,       required=False)
  parser.add_argument('-l',  '--lines',  type=int,           required=False)
  parser.add_argument('-i',  '--iter',   default=0,          type=int,            required=False)
  parser.add_argument('-c',  '--clean',  default=False,      action='store_true', required=False)

  args = parser.parse_args()
  print( ("site_stat: %s-%s-%s:%s-i%d " %
           ( args.bench, args.size, args.config,
             ("_".join(args.args.split(','))), args.iter )), end='' )

  sort_keys = tuple([ x for x in [args.sk1,args.sk2,args.sk3,args.sk4] \
                      if x != None])
  if args.lines:
    print(("%d_lines" % args.lines), end='')
  else:
    print(("all_lines"), end='' )
  print("")


  site_map = get_site_map(args.bench, args.size, args.config,
             args.args, args.iter, args.clean)

  report_site_stats(site_map, site_report_fmt[args.report], sort_keys, args.lines)

if __name__ == "__main__":
  main(sys.argv)
