#!/usr/bin/env python3

import os
import shlex
import subprocess

#############################################################################
# ENVIRONMENT VARIABLES
#############################################################################
command = shlex.split("env -i bash -c 'source ../vars.sh && env'")
proc = subprocess.Popen(command, stdout = subprocess.PIPE)
for line in proc.stdout:
  (key, _, value) = line.decode().strip().partition("=")
  os.environ[key] = value
proc.communicate()

SICM_HOME   = os.environ['SICM_HOME']
SICM_PREFIX = os.environ['SICM_PREFIX']
BENCH_DIR   = os.environ['BENCH_DIR']
SCRIPTS_DIR = os.environ['SCRIPTS_DIR']
RESULTS_DIR = os.environ['RESULTS_DIR']

#############################################################################
# GLOBAL VALUES
#############################################################################
PAGE_SIZE = 4096
LINE_SIZE = 64

PAGE_SHIFT      = 12
HUGE_PAGE_SHIFT = 21
GB_PAGE_SHIFT   = 30


PAGES      = "pages"
HUGE_PAGES = "huge_pages"
GB_PAGES   = "gb_pages"
LINES      = "lines"
PER_SITE   = "per_site"
PER_PAGE   = "per_page"
PER_LINE   = "per_line"
ABSOLUTE   = "absolute"
ACC_RATIO  = "acc_ratio"
DDR_RATIO  = "ddr_ratio"
PMM_RATIO  = "pmm_ratio"
RSS_RATIO  = "rss_ratio"
HIT_RATIO  = "hit_ratio"
MISS_RATIO = "miss_ratio"
ACC_STATS  = "acc_stats"
DDR_STATS  = "ddr_stats"
PMM_STATS  = "pmm_stats"
ACCS_SITE  = "accs_site"
ACCS_PAGE  = "accs_page"
ACCS_LINE  = "accs_line"
ACCESSES   = "accesses"
DDR_ACCS   = "ddr_accs"
PMM_ACCS   = "pmm_accs"
TOUCHED    = "touched"
MEAN       = "mean"
MEDIAN     = "median"
MIN        = "min"
MAX        = "max"
STDEV      = "stdev"
DIST       = "dist"

knapsack_key = "knapsack_per:%s_val:%s_wgt:%s_cap:%4.3f"
hotset_key   = "hotset_per:%s_val:%s_wgt:%s_cap:%4.3f"

#############################################################################
# UTILITY FUNCTIONS
#############################################################################
def MB_scale(x):
  return (x * (1.0 / (1024.0*1024.0)))

def cap2str(cap):
  return ("%02d" % int(cap))

def get_results_dir(bench, size, config, args):
  return (RESULTS_DIR + ("/%s/%s/%s:%s" % (bench, size, config, ("_".join(args.split(','))) )))

def get_iter_dir(bench, size, config, args, it):
  return ( get_results_dir(bench, size, config, args) + ("/i%d" % it) )

def get_site_map_pickle(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/.site_map.pkl" )

def get_page_map_pickle(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/.page_map.pkl" )

def get_huge_page_map_pickle(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/.huge_page_map.pkl" )

def get_gb_page_map_pickle(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/.gb_page_map.pkl" )

def get_sites_file(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/sites.txt" )

def get_page_map_file(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/pagemap.txt" )

def get_cache_map_file(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/cachemap.txt" )

def get_guidance_file(bench, size, config, args, it, \
  kstype, valkey, wgtkey, cap):
  return ( get_iter_dir(bench, size, config, args, it) + \
           "/guidance-%s-%s-%s-%s.txt" % (kstype, valkey, wgtkey,\
           cap2str(cap)) )

def get_val(d, ks):
  if len(ks) == 1:
    return d[ks[0]]
  elif len(ks) == 2:
    return d[ks[0]][ks[1]]
  elif len(ks) == 3:
    return d[ks[0]][ks[1]][ks[2]]
  elif len(ks) == 4:
    return d[ks[0]][ks[1]][ks[2]][ks[3]]
  raise (SystemExit(1))

