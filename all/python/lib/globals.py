#!/usr/bin/env python3

import os
import errno
import shlex
import subprocess
from distutils.dir_util import copy_tree, remove_tree
from functools import reduce
import operator
import re
from copy import copy
from math import sqrt

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
FOM        = "FoM"
RUN_TIME   = "run_time"
PEAK_RSS   = "peak_rss"

ALL_PAGES    = "all_pages"
SAMPLE_PAGES = "sample_pages"
AGG_PAGES    = "agg_pages"
PAGE_DISTRO  = "page_distro"
PAGE_ADDR    = "page_addr"

knapsack_key = "knapsack_per:%s_val:%s_wgt:%s_cap:%4.3f"
hotset_key   = "hotset_per:%s_val:%s_wgt:%s_cap:%4.3f"
rrhot_key    = "rrhot_per:%s_val:%s_wgt:%s"

student_t_95 = {
  1  : 12.71,
  2  : 4.303,
  3  : 3.182,
  4  : 2.776,
  5  : 2.571,
  6  : 2.447,
  7  : 2.998,
  8  : 2.306,
  9  : 2.262,
  10 : 2.228,
  11 : 2.201,
  12 : 2.179,
  13 : 2.160,
  14 : 2.145,
  15 : 2.131,
  16 : 2.120,
  17 : 2.110,
  18 : 2.101,
  19 : 2.093,
  20 : 2.086
}

fom_parse = dict()
fom_parse['lulesh']    = ( re.compile('FOM'), \
                         (lambda line : ( (float(line.split()[-2])) * 1000000.0 ))
                       )
fom_parse['pennant']   = ( re.compile('hydro cycle'),
                         (lambda line : ( float(line.split()[-1])) )
                       )
fom_parse['amg']       = ( re.compile('Figure of Merit \(FOM_2\):'),
                         (lambda line : ( float(line.split()[-1])) )
                       )
fom_parse['snap']      = ( re.compile('  Grind Time'),
                         (lambda line : ( 1.0/float(line.split()[-1])) )
                       )
fom_parse['qmcpack']   = ( re.compile('  QMC Execution time'),
                         (lambda line : ( 1.0/float(line.split()[-2])) )
                       )

time_re = re.compile('(\s)*Elapsed \(wall clock\) time')
rss_re  = re.compile('(\s)*Maximum resident set size')

#############################################################################
# UTILITY FUNCTIONS
#############################################################################
def KB(num):
  return (num / 1024.0)

def MB(num):
  return (KB(num) / (1024.0))

def GB(num):
  return (MB(num) / (1024.0))

def KB2B(kbytes):
  return (float(kbytes) * 1024.0)

def CLMB(num):
  return (MB(num*CACHE_LINE_SIZE))

def mkdir_p(path):
  try:
    os.makedirs(path)
  except OSError as exc:
    if exc.errno == errno.EEXIST:
      pass
    else: raise

def rm_f(path):
  try:
    os.remove(path)
  except OSError as exc:
    if exc.errno == errno.EEXIST:
      pass
    else: raise

def rm_rf(path, root=False):
  if root:
    os.system(("sudo rm -rf %s" % path))
  else:
    try:
      remove_tree(path)
    except OSError as exc:
      if exc.errno == errno.ENOENT:
        pass
      else: raise

def copy_any(src, dst):
  try:
    copy_tree(src, dst)
  except OSError as exc:
    if exc.errno == errno.ENOTDIR:
      copy(src, dst) 
    else: raise

def copy_to_dir(f, dir):
  copy_any(f, (dir+f.split('/')[-1]))

def getdir(dir, create=False, clean=False):
  if clean:
    os.system("rm -rf %s" % dir)
  if create:
    mkdir_p(dir)
  return dir

def convert_to_seconds(time):
  parts = time.split(':')
  hours = minutes = seconds = 0.0
  if len(parts) > 2:
    hours = float(parts[0])
    parts = parts[1:]

  minutes = float(parts[0])
  seconds = float(parts[1])
  return ( (hours*3600.0) + (minutes*60.0) + seconds )

def expiter(benches, cfgs, iters):
  for bench in benches:
    for cfg in cfgs:
      for it in range(iters):
        yield (bench, cfg, it)


def MB_scale(x):
  return (x * (1.0 / (1024.0*1024.0)))

def cap2str(cap):
  return ("%02d" % int(cap))

def get_results_dir(bench, size, config, args):
  return (RESULTS_DIR + ("/%s/%s/%s:%s" % (bench, size, config, ("_".join(args.split(','))) )))

def get_iter_dir(bench, size, config, args, it):
  return ( get_results_dir(bench, size, config, args) + ("/i%d" % it) )

def get_stdout_file(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/stdout.txt" )

def get_site_map_pickle(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/.site_map.pkl" )

def get_page_map_size_pickle(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/.page_map_sizes.pkl" )

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

def get_numastat_file(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/numastat.txt" )

def get_pcm_memory_file(bench, size, config, args, it):
  return ( get_iter_dir(bench, size, config, args, it) + "/pcm-memory.txt" )


def get_guidance_file(bench, size, config, args, it, \
  kstype, valkey, wgtkey, cap=None):
  if cap != None:
    return ( get_iter_dir(bench, size, config, args, it) + \
             "/guidance-%s-%s-%s-%s.txt" % (kstype, valkey, wgtkey,\
             cap2str(cap)) )
  else:
    return ( get_iter_dir(bench, size, config, args, it) + \
             "/guidance-%s-%s-%s.txt" % (kstype, valkey, wgtkey) )

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


def geo_mean(iterable):
  return (reduce(operator.mul, iterable)) ** (1.0/len(iterable))

def safe_mean(iterable, default=None):
  if len(iterable) == 0:
    return default 
  return mean(iterable)

def safe_geo_mean(iterable):
  if (0.0 in iterable):
    xxx = [(x+1) for x in iterable]
    val = (reduce(operator.mul, xxx)) ** (1.0/len(xxx))
    return (val-1)
  return (reduce(operator.mul, iterable)) ** (1.0/len(iterable))

def safediv(num, den, default=0.0):
  return ( (float(num) / den) if den != 0 else default )

def get95CI(basemean, expmean, basestd, expstd, nruns):

  foo   = ( (basestd**2) / nruns) + ( (expstd**2) / nruns)
  s_x   = sqrt( foo )

  if nruns < 30:

    faz  = (( (basestd**2) / nruns) **2) / (nruns-1)
    fez  = (( (expstd**2)  / nruns) **2) / (nruns-1)
    n_df = int(round( ((foo**2) / (faz + fez)) ))

    ci = (student_t_95[n_df] * s_x)

  else:

    # assume normal distribution
    ci = 1.96 * s_x

  return ci
