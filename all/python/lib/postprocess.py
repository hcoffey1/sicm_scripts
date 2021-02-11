#!/usr/bin/env python3

from lib.globals import *

import pickle
import re
from statistics import mean, stdev, median

#############################################################################
# PARSING & PROCESSING
#############################################################################
def new_site_record():
  rec = {}
  rec[PAGES] = {}
  rec[LINES] = {}

  xs = [PER_SITE, PER_PAGE, PER_LINE]
  ys = [ABSOLUTE, ACC_RATIO, DDR_RATIO, PMM_RATIO, RSS_RATIO]
  for x in xs:
    rec[x] = {}
    for y in ys:
      rec[x][y] = {}
      rec[x][y][ACCESSES] = 0
      rec[x][y][DDR_ACCS] = 0
      rec[x][y][PMM_ACCS] = 0
      rec[x][y][TOUCHED]  = 0

  xs = [PER_PAGE, PER_LINE]
  ys = [ACC_STATS, DDR_STATS, PMM_STATS]
  for x in xs:
    for y in ys:
      rec[x][y]         = {}
      rec[x][y][MEAN]   = 0
      rec[x][y][MEDIAN] = 0
      rec[x][y][MIN]    = 0
      rec[x][y][MAX]    = 0
      rec[x][y][STDEV]  = 0
      rec[x][y][DIST]   = []

  return rec

def update_page_map(page_map, pg_addr, ddr, pmm, site):
  if not pg_addr in page_map.keys():
    page_map[pg_addr] = [0,0, set([])]
  page_map[pg_addr][0] += ddr
  page_map[pg_addr][1] += pmm
  page_map[pg_addr][2].add(site)

def parse_sites_file(sites_file, site_map):
  print("File : ",sites_file)
  sitesf = open(sites_file)

  header = next(sitesf)
  if len(header.split()) == 4:
    has_pmm = True
    rss_idx = 3
  elif len(header.split()) == 3:
    has_pmm = False
    rss_idx = 2
  else:
    print ("bad header in sites file: %s" % header)
    raise (SystemExit(1))

  for line in sitesf:
    if line.strip() == '':
      continue
    pts   = line.split()
    site  = int(pts[0])
    ddr   = int(pts[1])
    pmm   = int(pts[2]) if has_pmm else 0
    rss   = int(pts[rss_idx])
    total = (ddr + pmm)

    site_map[site] = new_site_record()
    site_map[site][PER_SITE][ABSOLUTE][ACCESSES]   = total
    site_map[site][PER_SITE][ABSOLUTE][DDR_ACCS]   = ddr
    site_map[site][PER_SITE][ABSOLUTE][PMM_ACCS]   = pmm
    site_map[site][PER_SITE][ABSOLUTE][TOUCHED]    = rss
    site_map[site][PER_SITE][ABSOLUTE][HIT_RATIO]  = (float(ddr) / total) \
                                                     if total != 0 else 0.0
    site_map[site][PER_SITE][ABSOLUTE][MISS_RATIO] = (float(pmm) / total) \
                                                     if total != 0 else 0.0
  sitesf.close()

def parse_map_file(map_file, site_map, map_key, page_map=None,
  huge_page_map=None, gb_page_map=None, addr_shift=12):

  try:
    mapf = open(map_file)
  except:
    return

  header = next(mapf)
  if len(header.split()) == 5:
    has_pmm = True
    site_idx = 4
  elif len(header.split()) == 4:
    has_pmm = False
    site_idx = 3
  else:
    print ("bad header in map file: %s" % header)
    raise (SystemExit(1))

  for line in mapf:
    if line.strip() == '':
      continue
    pts   = line.split()
    vaddr = int(pts[0], base=16)
    paddr = int(pts[1], base=16)
    ddr   = int(pts[2])
    pmm   = int(pts[3]) if has_pmm else 0
    accs  = (ddr+pmm)

    sites = [int(x) for x in pts[site_idx:]]
    if (len(sites) != 1):
      print (line)
      raise (SystemExit(1))

    site = sites[0]
    if not site in site_map.keys():
      site_map[site] = new_site_record()
    site_map[site][map_key][vaddr] = (accs, ddr, pmm)

    if page_map != None:
      pg_addr = ( (paddr << addr_shift) >> PAGE_SHIFT )
      update_page_map(page_map, pg_addr, ddr, pmm, site)

    if huge_page_map != None:
      pg_addr = ( (paddr << addr_shift) >> HUGE_PAGE_SHIFT )
      update_page_map(huge_page_map, pg_addr, ddr, pmm, site)

    if gb_page_map != None:
      pg_addr = ( (paddr << addr_shift) >> GB_PAGE_SHIFT )
      update_page_map(gb_page_map, pg_addr, ddr, pmm, site)

  mapf.close()

def compute_map_stats(site_map, map_key, per_key, region_size):
  for site in site_map.keys():
    rmap      = site_map[site][map_key]
    abs_stats = site_map[site][per_key][ABSOLUTE]
    acc_stats = site_map[site][per_key][ACC_STATS]
    ddr_stats = site_map[site][per_key][DDR_STATS]
    pmm_stats = site_map[site][per_key][PMM_STATS]

    sorted_rmap = {k: v for k, v in \
      sorted(rmap.items(), key=lambda item: item[1][0], reverse=True)}

    sorted_accs = [x[0] for x in sorted_rmap.values()]
    sorted_ddr  = [x[1] for x in sorted_rmap.values()]
    sorted_pmm  = [x[2] for x in sorted_rmap.values()]
    num_regions = len(sorted_accs)

    abs_stats[ACCESSES]   = sum ( sorted_accs )
    abs_stats[DDR_ACCS]   = sum ( sorted_ddr  )
    abs_stats[PMM_ACCS]   = sum ( sorted_pmm  )
    abs_stats[HIT_RATIO]  = (float(abs_stats[DDR_ACCS]) / abs_stats[ACCESSES]) \
                             if abs_stats[ACCESSES] != 0 else 0.0
    abs_stats[MISS_RATIO] = (float(abs_stats[PMM_ACCS]) / abs_stats[ACCESSES]) \
                            if abs_stats[ACCESSES] != 0 else 0.0
    abs_stats[TOUCHED]    = ( num_regions * region_size )

    stat_accs = [ (acc_stats, sorted_accs),
                  (ddr_stats, sorted_ddr),
                  (pmm_stats, sorted_pmm)
                ]

    for stats,accs in stat_accs:
      if len(accs) == 0:
        stats[MEAN]   = 0
        stats[STDEV]  = 0
        stats[MAX]    = 0
        stats[MIN]    = 0
        stats[MEDIAN] = 0
        for i in range(100):
          stats[DIST].append(0)

      else:

        stats[MEAN]  = mean  (accs)
        stats[STDEV] = stdev (accs) if len(accs) > 1 else 0
        stats[MAX]   = accs[0]
        stats[MIN]   = accs[-1]

        mid = num_regions // 2
        if ((num_regions % 2) == 0):
          t1 = accs[mid-1]
          t2 = accs[mid]
          acc_stats[MEDIAN] = ((t1+t2)/2)
        else:
          acc_stats[MEDIAN] = accs[mid]

        total_accs     = abs_stats[ACCESSES]
        total_rss      = max( [ site_map[site][PER_SITE][ABSOLUTE][TOUCHED],
                               (num_regions*region_size) ] )
        cur_accs       = 0
        cur_regions    = 0
        cur_target_pct = 0
        cur_target     = 0

        while cur_accs >= cur_target:
          acc_stats[DIST].append((float((cur_regions*region_size)) / total_rss))
          cur_target_pct += 1
          if cur_target_pct == 100:
            break
          cur_target = int(((float(cur_target_pct) / 100.0) * total_accs))
      
        for val in accs:
          cur_accs += val
          cur_regions += 1
          while cur_accs >= cur_target:
            acc_stats[DIST].append((float((cur_regions*region_size)) / total_rss))
            cur_target_pct += 1
            if cur_target_pct == 100:
              break
            cur_target = int(((float(cur_target_pct) / 100.0) * total_accs))

def compute_ratio_stats(site_map, per_key, sort_key):

  if sort_key == ACCESSES:
    ratio_key = ACC_RATIO
  elif sort_key == DDR_ACCS:
    ratio_key = DDR_RATIO
  elif sort_key == PMM_ACCS:
    ratio_key = PMM_RATIO
  else:
    ratio_key = RSS_RATIO

  sort_keys = (per_key, ABSOLUTE, sort_key)
  sorted_sites = {k: v for k, v in \
    sorted(site_map.items(), key=lambda item: get_val(item[1], sort_keys), \
           reverse=True)}

  total_accs  = sum ( [ site_map[x][per_key][ABSOLUTE][ACCESSES] \
                        for x in site_map.keys() ] )
  total_ddr   = sum ( [ site_map[x][per_key][ABSOLUTE][DDR_ACCS] \
                        for x in site_map.keys() ] )
  total_pmm   = sum ( [ site_map[x][per_key][ABSOLUTE][PMM_ACCS] \
                        for x in site_map.keys() ] )
  total_bytes = sum ( [ site_map[x][per_key][ABSOLUTE][TOUCHED] \
                        for x in site_map.keys() ] )

  cur_accs  = 0
  cur_ddr   = 0
  cur_pmm   = 0
  cur_bytes = 0
  for site in sorted_sites:
    cur_ddr   += site_map[site][per_key][ABSOLUTE][DDR_ACCS]
    cur_pmm   += site_map[site][per_key][ABSOLUTE][PMM_ACCS]
    cur_accs  += site_map[site][per_key][ABSOLUTE][ACCESSES]
    cur_bytes += site_map[site][per_key][ABSOLUTE][TOUCHED]

    site_map[site][per_key][ratio_key][DDR_ACCS] = (float(cur_ddr)   / total_ddr)   \
                                                   if total_ddr   != 0 else 0.0
    site_map[site][per_key][ratio_key][PMM_ACCS] = (float(cur_pmm)   / total_pmm)   \
                                                   if total_pmm   != 0 else 0.0
    site_map[site][per_key][ratio_key][ACCESSES] = (float(cur_accs)  / total_accs)  \
                                                   if total_accs  != 0 else 0.0
    site_map[site][per_key][ratio_key][TOUCHED]  = (float(cur_bytes) / total_bytes) \
                                                   if total_bytes != 0 else 0.0

def build_site_map(bench, size, config, args, it):
  sites_file     = get_sites_file(bench, size, config, args, it)
  page_map_file  = get_page_map_file(bench, size, config, args, it)
  cache_map_file = get_cache_map_file(bench, size, config, args, it)

  site_map = {}
  parse_sites_file(sites_file,   site_map)

  page_map      = {}
  huge_page_map = {}
  gb_page_map   = {}
  parse_map_file(page_map_file,  site_map, PAGES, page_map, huge_page_map,\
                 gb_page_map)

  parse_map_file(cache_map_file, site_map, LINES)

  compute_map_stats(site_map, PAGES, PER_PAGE, PAGE_SIZE)
  compute_map_stats(site_map, LINES, PER_LINE, LINE_SIZE)

  for site in site_map.keys():
    del site_map[site][PAGES]
    del site_map[site][LINES]

  perkeys = [ PER_SITE, PER_PAGE, PER_LINE ]

  for x in perkeys:
    for y in [ACCESSES, DDR_ACCS, PMM_ACCS, TOUCHED]:
      compute_ratio_stats(site_map, x, y)

  for x in perkeys:
    for site in site_map.keys():
      accs     = site_map[site][x][ABSOLUTE][ACCESSES]
      site_mem = site_map[site][PER_SITE][ABSOLUTE][TOUCHED]
      pages    = site_map[site][PER_PAGE][ABSOLUTE][TOUCHED]
      lines    = site_map[site][PER_LINE][ABSOLUTE][TOUCHED]

      v1 = 0.0 if site_mem == 0 else (float(accs) / site_mem)
      v2 = 0.0 if pages == 0 else (float(accs) / pages)
      v3 = 0.0 if lines == 0 else (float(accs) / lines)

      site_map[site][x][ABSOLUTE][ACCS_SITE] = v1
      site_map[site][x][ABSOLUTE][ACCS_PAGE] = v2
      site_map[site][x][ABSOLUTE][ACCS_LINE] = v3

  pkl_file = get_site_map_pickle(bench, size, config, args, it)
  pklf = open(pkl_file, 'wb')
  pickle.dump(site_map, pklf, protocol=pickle.HIGHEST_PROTOCOL)

  pkl_file = get_page_map_pickle(bench, size, config, args, it)
  pklf = open(pkl_file, 'wb')
  pickle.dump(page_map, pklf, protocol=pickle.HIGHEST_PROTOCOL)

  pkl_file = get_huge_page_map_pickle(bench, size, config, args, it)
  pklf = open(pkl_file, 'wb')
  pickle.dump(huge_page_map, pklf, protocol=pickle.HIGHEST_PROTOCOL)

  pkl_file = get_gb_page_map_pickle(bench, size, config, args, it)
  pklf = open(pkl_file, 'wb')
  pickle.dump(gb_page_map, pklf, protocol=pickle.HIGHEST_PROTOCOL)

  pkl_file = get_page_map_size_pickle(bench, size, config, args, it)
  pklf = open(pkl_file, 'wb')
  pickle.dump( (len(page_map.keys()), len(huge_page_map.keys()),
                len(gb_page_map.keys())), pklf,
               protocol=pickle.HIGHEST_PROTOCOL
             )

def get_site_map(bench, size, config, args, it, clean=False):
  pkl_file = get_site_map_pickle(bench, size, config, args, it)
  if os.path.exists(pkl_file) and not clean:
    pklf = open(pkl_file, 'rb')
    site_map = pickle.load(pklf)
    pklf.close()
  else:
    print("rebuilding site map ... ", end='', flush=True)
    build_site_map(bench, size, config, args, it)
    pklf = open(pkl_file, 'rb')
    site_map = pickle.load(pklf)
    pklf.close()
    print("done.")

  return site_map

def get_page_map(bench, size, config, args, it, clean=False):
  pkl_file = get_page_map_pickle(bench, size, config, args, it)
  if os.path.exists(pkl_file) and not clean:
    pklf = open(pkl_file, 'rb')
    page_map = pickle.load(pklf)
  else:
    print("rebuilding page map ... ", end='', flush=True)
    build_site_map(bench, size, config, args, it)
    pklf = open(pkl_file, 'rb')
    page_map = pickle.load(pklf)
    pklf.close()
    print("done.")

  return page_map

def get_huge_page_map(bench, size, config, args, it, clean=False):
  pkl_file = get_huge_page_map_pickle(bench, size, config, args, it)
  if os.path.exists(pkl_file) and not clean:
    pklf = open(pkl_file, 'rb')
    huge_page_map = pickle.load(pklf)
    pklf.close()
  else:
    print("rebuilding huge page map ... ", end='', flush=True)
    build_site_map(bench, size, config, args, it)
    pklf = open(pkl_file, 'rb')
    huge_page_map = pickle.load(pklf)
    pklf.close()
    print("done.")
  return huge_page_map

def get_gb_page_map(bench, size, config, args, it, clean=False):
  pkl_file = get_gb_page_map_pickle(bench, size, config, args, it)
  if os.path.exists(pkl_file) and not clean:
    pklf = open(pkl_file, 'rb')
    gb_page_map = pickle.load(pklf)
    pklf.close()
  else:
    print("rebuilding gb page map ... ", end='', flush=True)
    build_site_map(bench, size, config, args, it)
    pklf = open(pkl_file, 'rb')
    gb_page_map = pickle.load(pklf)
    pklf.close()
    print("done.")
  return gb_page_map

def get_proc_rss(bench, size, config, args, it):
  stdout_file = get_stdout_file(bench, size, config, args, it)
  outf = open(stdout_file)
  rss = 0
  for line in outf:
    if re.match("(\s)+Maximum(\s)resident", line):
      rss = (int(line.split()[5])*1024.0)
      break
  return rss

def get_page_map_sizes(bench, size, config, args, it, clean):
  pkl_file = get_page_map_size_pickle(bench, size, config, args, it)
  if os.path.exists(pkl_file):
    pklf = open(pkl_file, 'rb')
    sizes = pickle.load(pklf)
    pklf.close()
  else:
    page_map      = get_page_map(bench, size, config, args, it, False)
    huge_page_map = get_huge_page_map(bench, size, config, args, it, False)
    gb_page_map   = get_gb_page_map(bench, size, config, args, it, False)
    sizes = (len(page_map.keys()), len(huge_page_map.keys()),
             len(gb_page_map.keys()))
    pklf = open(pkl_file, 'wb')
    pickle.dump(sizes, pklf, protocol=pickle.HIGHEST_PROTOCOL)
    pklf.close()

  return sizes

def record_guidance(site_map, hots, colds, perkey, valkey, wgtkey,
  total_val, total_wgt, target, guidekey, upper, lower, swaptier):

  hotset_val = hotset_wgt = 0
  for site in hots:
    hotset_val += site_map[site][perkey][ABSOLUTE][valkey]
    hotset_wgt += site_map[site][perkey][ABSOLUTE][wgtkey]
    site_map[site][guidekey] = upper if not swaptier else lower

  coldset_val = coldset_wgt = 0
  for site in colds:
    coldset_val += site_map[site][perkey][ABSOLUTE][valkey]
    coldset_wgt += site_map[site][perkey][ABSOLUTE][wgtkey]
    site_map[site][guidekey] = lower if not swaptier else upper

  coldval_pct = float(coldset_val) / (total_val)
  coldwgt_pct = float(coldset_wgt) / (total_wgt)
  hotval_pct  = float(hotset_val)  / (total_val)
  hotwgt_pct  = float(hotset_wgt)  / (total_wgt)

  if wgtkey == TOUCHED:
    total_wgt   = MB_scale(total_wgt)
    hotset_wgt  = MB_scale(hotset_wgt)
    coldset_wgt = MB_scale(coldset_wgt)
    target      = MB_scale(target)
  elif valkey == TOUCHED:
    total_val   = MB_scale(total_val)
    hotset_val  = MB_scale(hotset_val)
    coldset_val = MB_scale(coldset_val)

  target_rat = (target/total_wgt) if total_wgt != 0.0 else 0.0

  print ("total_val:    %-12d" % (total_val))
  print ("hotset_val:   %-12d %-4.3f" % (hotset_val,  hotval_pct))
  print ("coldset_val:  %-12d %-4.3f" % (coldset_val, coldval_pct))

  print ("")
  print ("total_wgt:    %-12d" % (total_wgt))
  print ("target_wgt:   %-12d %-4.3f" % (target, target_rat))
  print ("hotset_wgt:   %-12d %-4.3f" % (hotset_wgt,  hotwgt_pct))
  print ("coldset_wgt:  %-12d %-4.3f" % (coldset_wgt, coldwgt_pct))


  total_accs = total_rss = 0
  for site in site_map.keys():
    total_accs += site_map[site][perkey][ABSOLUTE][ACCESSES]
    total_rss  += site_map[site][perkey][ABSOLUTE][TOUCHED]

  hot_accs = hot_rss = hot_ddr = hot_pmm = 0
  for site in hots:
    hot_accs += site_map[site][perkey][ABSOLUTE][ACCESSES]
    hot_ddr  += site_map[site][perkey][ABSOLUTE][DDR_ACCS]
    hot_pmm  += site_map[site][perkey][ABSOLUTE][PMM_ACCS]
    hot_rss  += site_map[site][perkey][ABSOLUTE][TOUCHED]

  cold_accs = cold_rss = cold_ddr = cold_pmm = 0
  for site in colds:
    cold_accs += site_map[site][perkey][ABSOLUTE][ACCESSES]
    cold_ddr  += site_map[site][perkey][ABSOLUTE][DDR_ACCS]
    cold_pmm  += site_map[site][perkey][ABSOLUTE][PMM_ACCS]
    cold_rss  += site_map[site][perkey][ABSOLUTE][TOUCHED]

  hot_accs_pct  = float(hot_accs) / (total_accs)
  hot_ddr_pct   = float(hot_ddr)  / (total_accs)
  hot_pmm_pct   = float(hot_pmm)  / (total_accs)
  hot_rss_pct   = float(hot_rss)  / (total_rss)
  hot_miss_pct  = float(hot_pmm)  / (hot_accs)

  cold_accs_pct = float(cold_accs) / (total_accs)
  cold_ddr_pct  = float(cold_ddr)  / (total_accs)
  cold_pmm_pct  = float(cold_pmm)  / (total_accs)
  cold_rss_pct  = float(cold_rss)  / (total_rss)
  cold_miss_pct = float(cold_pmm)  / (cold_accs)

  print ("")
  print ("hotset stats (most %s with %.1f%% of %s)" % \
         (valkey, (target_rat*100.0), wgtkey))
  print ("%9s%9s%9s%9s%9s" % ("accs", "rss", "ddr", "pmm", "miss"))
  print ("%9.3f%9.3f%9.3f%9.3f%9.3f" % (hot_accs_pct, hot_rss_pct,\
         hot_ddr_pct, hot_pmm_pct, hot_miss_pct))

  print ("")
  print ("coldset stats (coldest %s in other %.1f%% of %s)" % \
         (valkey, (100.0-(target_rat*100.0)), wgtkey))
  print ("%9s%9s%9s%9s%9s" % ("accs", "rss", "ddr", "pmm", "miss"))
  print ("%9.3f%9.3f%9.3f%9.3f%9.3f" % (cold_accs_pct, cold_rss_pct,\
         cold_ddr_pct, cold_pmm_pct, cold_miss_pct))
  print ("")

def compute_knapsack(site_map, perkey, valkey, wgtkey, cap,
  sigfigs=5, absolute=False, upper=0, lower=1, swaptier=False):
  
  VAL   = 0
  WGT   = 1
  SITE  = 2

  vals = []
  for site in site_map.keys():
    val = site_map[site][perkey][ABSOLUTE][valkey]
    wgt = site_map[site][perkey][ABSOLUTE][wgtkey]
    vals.append((val, wgt, site))

  total_val = sum( [ v[VAL] for v in vals ] )
  total_wgt = sum( [ v[WGT] for v in vals ] )
  if not absolute:
    target = ( total_wgt * (cap / 100.0) )
  else:
    target = cap

  wincs  = (10**sigfigs)
  cutoff = (target / total_wgt)
  wgt_vals = [ (v[VAL], int((float(v[WGT]) / total_wgt) * wincs), v[SITE]) \
               for v in vals ]

  wgt_vals.sort(key=lambda tup: tup[WGT], reverse=True)

  sig_wgts   = [ x for x in wgt_vals if x[WGT] > 0 ]
  insig_wgts = wgt_vals[len(sig_wgts):]

  wgt_incs = range(int(cutoff*wincs))

  sites = {}
  for v in vals:
    sites[v[SITE]] = (v[VAL], v[WGT])

  m = []
  m.append([])
  for j in wgt_incs:
    m[0].append(0)

  for i,wgt in enumerate(sig_wgts,start=1):
    m.append([])
    for j,inc in enumerate(wgt_incs):
      if wgt[WGT] <= inc:
        m[i].append(max(m[i-1][j], m[i-1][inc-wgt[WGT]] + sites[wgt[SITE]][VAL]))
      else:
        m[i].append(m[i-1][j])
    #if i % 10 == 0:
    #  print ("  m[%d][%d] = %d" % (i,j,m[i][j]))

  hots = []
  i = len(sig_wgts)
  j = (len(wgt_incs)-1)
  while i > 0:
    if m[i][j] != m[i-1][j]:
      hots.append(sig_wgts[i-1][SITE])
      j -= sig_wgts[i-1][WGT]
    i -= 1

  for wgt in insig_wgts:
    hots.append(wgt[SITE])

  colds = [ x[SITE] for x in vals if not x[SITE] in hots ]

  guidekey = (knapsack_key%(perkey,valkey,wgtkey,cap))
  record_guidance(site_map, hots, colds, perkey, valkey, wgtkey, \
                  total_val, total_wgt, target, guidekey, \
                  upper, lower, swaptier)


def compute_hotset(site_map, perkey, valkey, wgtkey, cap,
  absolute=False, upper=0, lower=1, swaptier=False):

  VAL   = 0
  WGT   = 1
  SITE  = 2
  hskey = (hotset_key%(perkey,valkey,wgtkey,cap))

  vals = []
  for site in site_map.keys():
    val = site_map[site][perkey][ABSOLUTE][valkey]
    wgt = site_map[site][perkey][ABSOLUTE][wgtkey]
    vals.append((val, wgt, site))

  total_val = sum( [ v[VAL] for v in vals ] )
  total_wgt = sum( [ v[WGT] for v in vals ] )
  if not absolute:
    target = ( total_wgt * (cap / 100.0) )
  else:
    target = cap

  vals.sort(key=lambda tup: tup[0], reverse=True)
  
  hots = []
  hot_wgt = 0.0
  for val in vals:
    hots += [val[2]]
    hot_wgt += val[1]
    if hot_wgt > target:
      break

  colds = [ x[SITE] for x in vals if not x[SITE] in hots ]

  tmpvkey  = valkey
  if valkey in [ACCS_SITE, ACCS_PAGE, ACCS_LINE]:
    tmpvkey = ACCESSES

  guidekey = (hotset_key%(perkey,valkey,wgtkey,cap))
  record_guidance(site_map, hots, colds, perkey, tmpvkey, wgtkey, \
                  total_val, total_wgt, target, guidekey, upper, \
                  lower, swaptier)

def compute_rr_hotset(site_map, perkey, valkey, wgtkey, cap,
  absolute=False, upper=0, lower=1):

  VAL   = 0
  WGT   = 1
  SITE  = 2
  hskey = (rrhot_key%(perkey,valkey,wgtkey))

  vals = []
  for site in site_map.keys():
    val = site_map[site][perkey][ABSOLUTE][valkey]
    wgt = site_map[site][perkey][ABSOLUTE][wgtkey]
    vals.append((val, wgt, site))

  total_val = sum( [ v[VAL] for v in vals ] )
  total_wgt = sum( [ v[WGT] for v in vals ] )

  vals.sort(key=lambda tup: tup[0], reverse=True)

  guidekey = (rrhot_key%(perkey,valkey,wgtkey))
  for cur,val in enumerate(vals):
    site_map[val[2]][guidekey] = (cur % (lower-upper+1))
  
