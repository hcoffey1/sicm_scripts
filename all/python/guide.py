#!/usr/bin/env python3

from lib.globals import *
from lib.postprocess import *
from lib.report import *

import sys
import argparse
import pickle

def main(args):
  parser = argparse.ArgumentParser()
  parser.add_argument('-b',  '--bench',    required=True)
  parser.add_argument('-z',  '--size',     required=True)
  parser.add_argument('-g',  '--config',   required=True)
  parser.add_argument('-a',  '--args',     required=True)
  parser.add_argument('-k',  '--perkey',   default=PER_SITE,   required=False)
  parser.add_argument('-v',  '--valkey',   default=PMM_ACCS,   required=False)
  parser.add_argument('-w',  '--wgtkey',   default=DDR_ACCS,   required=False)
  parser.add_argument('-t',  '--type',     default="knapsack", required=False)
  parser.add_argument('-u',  '--upper',    default=1,          type=int,   required=False)
  parser.add_argument('-l',  '--lower',    default=3,          type=int,   required=False)
  parser.add_argument('-p',  '--capacity', default=None,       type=float, required=False)
  parser.add_argument('-n',  '--sigfigs',  default=6,          type=int,   required=False)
  parser.add_argument('-i',  '--iter',     default=0,          type=int,            required=False)
  parser.add_argument('-r',  '--report',   default=False,      action='store_true', required=False)
  parser.add_argument('-W',  '--swaptier', default=False,      action='store_true', required=False)
  parser.add_argument('-c',  '--clean',    default=False,      action='store_true', required=False)
  parser.add_argument('-P',  '--absolute', default=False,      action='store_true', required=False)
  parser.add_argument('-L',  '--lines',    type=int,           required=False)

  args = parser.parse_args()
  print( ("creating %s guidance for: %s-%s-%s:%s-i%d per:%s val:%s wgt:%s %s (%s)" %
           ( args.type, args.bench, args.size, args.config,
             ("_".join(args.args.split(','))), args.iter,
             args.perkey, args.valkey, args.wgtkey, 
             ( ("cap:%5.2f"%args.capacity) if args.capacity != None else ""),
             ("absolute" if args.absolute else "relative")
           )
        ) )

  site_map = get_site_map(args.bench, args.size, args.config,
             args.args, args.iter)

  if args.type == "knapsack":
    compute_knapsack( site_map, args.perkey, args.valkey, args.wgtkey,
                      args.capacity, args.sigfigs, args.absolute, args.upper,
                      args.lower, args.swaptier )
    guidekey = (knapsack_key % (args.perkey, args.valkey, args.wgtkey, args.capacity))
  elif args.type == "hotset":
    compute_hotset( site_map, args.perkey, args.valkey, args.wgtkey,
                    args.capacity, args.absolute, args.upper, args.lower,
                    args.swaptier )
    guidekey = (hotset_key % (args.perkey, args.valkey, args.wgtkey, args.capacity))
  elif args.type == "rr_hotset":
    compute_rr_hotset( site_map, args.perkey, args.valkey, args.wgtkey,
                       args.capacity, args.absolute, args.upper, args.lower )
    guidekey = (rrhot_key % (args.perkey, args.valkey, args.wgtkey))
  else:
    print("unsupported guidance type: %s" % args.type)
    raise (SystemExit(1))

  if args.report:
    sort_keys = (args.perkey, ABSOLUTE, args.valkey)
    report_site_stats(site_map, site_report_fmt["guide_report"], sort_keys,
                      args.lines, guidekey)


  sort_keys = (args.perkey, ABSOLUTE, args.valkey)
  sorted_sites = {k: v for k, v in \
    sorted(site_map.items(), key=lambda item: get_val(item[1], sort_keys), \
           reverse=True)}

  guidef = open(get_guidance_file(args.bench, args.size, args.config,
                args.args, args.iter, args.type, args.valkey, args.wgtkey,
                args.capacity), 'w')
  print("===== GUIDANCE =====", file=guidef)
  for i,site in enumerate(sorted_sites,start=1):
    print("%-8d%-4d" % (site,site_map[site][guidekey]), file=guidef)
  print("===== END GUIDANCE =====", file=guidef)
  guidef.close()

if __name__ == "__main__":
  main(sys.argv)

