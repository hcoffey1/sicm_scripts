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
  parser.add_argument('-t',  '--type',   default=PAGES,     required=False)
  parser.add_argument('-s',  '--style',  default=ALL_PAGES, required=False)
  parser.add_argument('-k',  '--sort',   default=ACCESSES,  required=False)
  parser.add_argument('-p',  '--step',   default=ACCESSES,  required=False)
  parser.add_argument('-l',  '--lines',  type=int,          required=False)
  parser.add_argument('-i',  '--iter',   default=0,         type=int,            required=False)
  parser.add_argument('-x',  '--maxrat', default=7,         type=int,            required=False)
  parser.add_argument('-f',  '--cutoff', default=0.0,       type=float,          required=False)
  parser.add_argument('-m',  '--accum',  default=False,     action='store_true', required=False)
  parser.add_argument('-c',  '--clean',  default=False,     action='store_true', required=False)

  args = parser.parse_args()
  print( ("site_stat: %s-%s-%s:%s-i%d " %
           ( args.bench, args.size, args.config,
             ("_".join(args.args.split(','))), args.iter )), end='' )

  if args.lines:
    print(("%d_lines" % args.lines), end='')
  else:
    print(("all_lines"), end='' )
  print("")

  if args.type == PAGES:
    page_map = get_page_map(args.bench, args.size, args.config,
               args.args, args.iter, args.clean)
  elif args.type == HUGE_PAGES:
    page_map = get_huge_page_map(args.bench, args.size, args.config,
               args.args, args.iter, args.clean)
  elif args.type == GB_PAGES:
    page_map = get_gb_page_map(args.bench, args.size, args.config,
               args.args, args.iter, args.clean)
  else:
    print("Error: Invalid page type: %s" % (args.type))
    return

  total_rss = get_proc_rss(args.bench, args.size, args.config,
                           args.args, args.iter)

  (total_pages, total_huge_pages, _) = get_page_map_sizes(args.bench, args.size, \
                                       args.config, args.args, args.iter, args.clean)

  #page_rss = (pages*(1<<PAGE_SHIFT))
  #huge_rss = (huge_pages*(1<<HUGE_PAGE_SHIFT))
  #gb_rss   = (gb_pages*(1<<GB_PAGE_SHIFT))

  report_page_map(page_map, args.type, args.sort, args.style, args.step, \
                  args.lines, total_rss, total_pages, total_huge_pages, \
                  args.cutoff, args.maxrat, args.accum)

if __name__ == "__main__":
  main(sys.argv)

