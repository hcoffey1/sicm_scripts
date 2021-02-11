#!/usr/bin/env python3

from lib.globals import *
from lib.postprocess import *
from lib.results import *
import string

#############################################################################
# REPORTING
#############################################################################
site_report_fmt = {
  "abs_base" : (
  ( ("%10s", "site-MB"),   ("%10d",  (PER_SITE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "site-accs"), ("%12d",  (PER_SITE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%10s", "page-MB"),   ("%10d",  (PER_PAGE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "page-accs"), ("%12d",  (PER_PAGE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%9s", "rss-rat"),    ("%9.3f", (PER_SITE, ACC_RATIO, TOUCHED),            None) ),
  ( ("%9s", "acc-rat"),    ("%9.3f", (PER_SITE, ACC_RATIO, ACCESSES),           None) ),
  #( ("%12s", "ddr-accs"),  ("%12d",  (PER_SITE, ABSOLUTE, DDR_ACCS),            None) ),
  #( ("%12s", "pmm-accs"),  ("%12d",  (PER_SITE, ABSOLUTE, PMM_ACCS),            None) ),
  #( ("%9s",  "hit-rat"),   ("%9.3f", (PER_SITE, ABSOLUTE, HIT_RATIO),           None) ),
  #( ("%9s",  "mis-rat"),   ("%9.3f", (PER_SITE, ABSOLUTE, MISS_RATIO),          None) ),
  #( ("%10s", "line-MB"),   ("%10d",  (PER_LINE, ABSOLUTE, TOUCHED),         MB_scale) ),
  #( ("%12s", "line-accs"), ("%12d",  (PER_LINE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%9s",  "accs/pg"),   ("%9.3f", (PER_SITE, ABSOLUTE, ACCS_PAGE),            None) ),
  #( ("%9s",  "accs/ln"),   ("%9.3f", (PER_SITE, ABSOLUTE, ACCS_LINE),            None) ),
  ),
  "acc_ratio_base" : (
  ( ("%10s", "site-MB"),   ("%10d",  (PER_SITE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "site-accs"), ("%12d",  (PER_SITE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%9s", "rss-rat"),    ("%9.3f", (PER_SITE, ACC_RATIO, TOUCHED),            None) ),
  ( ("%9s", "acc-rat"),    ("%9.3f", (PER_SITE, ACC_RATIO, ACCESSES),           None) ),
  ),
  "page_dist" : (
  ( ("%10s", "site-MB"),   ("%10d",  (PER_SITE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "site-accs"), ("%12d",  (PER_SITE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%10s", "page-MB"),   ("%10d",  (PER_PAGE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "page-accs"), ("%12d",  (PER_PAGE, ABSOLUTE, ACCESSES),            None) ),
  #( ("%9s",  "rss-rat"),   ("%9.3f", (PER_SITE, ACC_RATIO, TOUCHED),            None) ),
  #( ("%9s",  "acc-rat"),   ("%9.3f", (PER_SITE, ACC_RATIO, ACCESSES),           None) ),
  ( ("%9s",  "rss-rat"),   ("%9.3f", (PER_SITE, RSS_RATIO, TOUCHED),            None) ),
  ( ("%9s",  "acc-rat"),   ("%9.3f", (PER_SITE, RSS_RATIO, ACCESSES),           None) ),
  ( ("%9s",  "page-d99"),  ("%9.3f", (PER_PAGE, ACC_STATS, DIST, 99), None) ),
  ( ("%9s",  "page-d95"),  ("%9.3f", (PER_PAGE, ACC_STATS, DIST, 95), None) ),
  ( ("%9s",  "page-d90"),  ("%9.3f", (PER_PAGE, ACC_STATS, DIST, 90), None) ),
  ( ("%9s",  "page-d80"),  ("%9.3f", (PER_PAGE, ACC_STATS, DIST, 80), None) ),
  ( ("%9s",  "page-d70"),  ("%9.3f", (PER_PAGE, ACC_STATS, DIST, 70), None) ),
  ( ("%9s",  "page-d60"),  ("%9.3f", (PER_PAGE, ACC_STATS, DIST, 60), None) ),
  ( ("%9s",  "page-d50"),  ("%9.3f", (PER_PAGE, ACC_STATS, DIST, 50), None) ),
  ),
  "line_dist" : (
  ( ("%10s", "site-MB"),         ("%10d",  (PER_SITE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "site-accs"),       ("%12d",  (PER_SITE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%10s", "line-MB"),         ("%10d",  (PER_LINE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "line-accs"),       ("%12d",  (PER_LINE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%9s",  "line-d99"),        ("%9.3f", (PER_LINE, ACC_STATS, DIST, 99), None) ),
  ( ("%9s",  "line-d95"),        ("%9.3f", (PER_LINE, ACC_STATS, DIST, 95), None) ),
  ( ("%9s",  "line-d90"),        ("%9.3f", (PER_LINE, ACC_STATS, DIST, 90), None) ),
  ( ("%9s",  "line-d80"),        ("%9.3f", (PER_LINE, ACC_STATS, DIST, 80), None) ),
  ( ("%9s",  "line-d70"),        ("%9.3f", (PER_LINE, ACC_STATS, DIST, 70), None) ),
  ( ("%9s",  "line-d60"),        ("%9.3f", (PER_LINE, ACC_STATS, DIST, 60), None) ),
  ( ("%9s",  "line-d50"),        ("%9.3f", (PER_LINE, ACC_STATS, DIST, 50), None) ),
  ),
  "guide_report" : (
  ( ("%10s", "site-MB"),   ("%10d",  (PER_SITE, ABSOLUTE,  TOUCHED),          MB_scale) ),
  ( ("%9s",  "MB-rat"),    ("%9.3f", (PER_SITE, ACC_RATIO, TOUCHED),             None) ),
  ( ("%12s", "site-accs"), ("%12d",  (PER_SITE, ABSOLUTE,  ACCESSES),             None) ),
  ( ("%9s",  "acc-rat"),   ("%9.3f", (PER_SITE, ACC_RATIO, ACCESSES),            None) ),
#  ( ("%12s", "ddr-accs"),  ("%12d",  (PER_SITE, ABSOLUTE, DDR_ACCS),            None) ),
#  ( ("%12s", "pmm-accs"),  ("%12d",  (PER_SITE, ABSOLUTE, PMM_ACCS),            None) ),
#  ( ("%9s",  "hit-rat"),   ("%9.3f", (PER_SITE, ABSOLUTE, HIT_RATIO),           None) ),
#  ( ("%9s",  "mis-rat"),   ("%9.3f", (PER_SITE, ABSOLUTE, MISS_RATIO),          None) ),
#  ( ("%9s",  "accs-rat"),  ("%9.3f", (PER_SITE, PMM_RATIO, ACCESSES),           None) ),
#  ( ("%9s",  "rss-rat"),   ("%9.3f", (PER_SITE, PMM_RATIO, TOUCHED),            None) ),
  ),
}

def report_site_stats(site_map, stats, sort_keys, lines=0, \
  guidekey=None, swaptier=False):
  
  sorted_sites = {k: v for k, v in \
    sorted(site_map.items(), key=lambda item: get_val(item[1], sort_keys), \
           reverse=True)}

  if guidekey:
    first_fmt = "%-6s%6s%6s"
    first_pts = ("rank", "site", "tier")
  else:
    first_fmt = "%-6s%6s"
    first_pts = ("rank", "site")

  header_fmt = ( first_fmt + "".join([x[0][0] for x in stats]) )
  header_pts = ( first_pts + tuple([x[0][1] for x in stats]) )
  line_fmt   = "".join([x[1][0] for x in stats])
  line_keys  = [x[1][1] for x in stats]
  line_fn    = [x[1][2] for x in stats]

  print(header_fmt % header_pts)
  for i,site in enumerate(sorted_sites,start=1):
    if lines and i > lines:
      break

    vals = []
    for keys,fn in zip(line_keys,line_fn):
      try:
        val = get_val(site_map[site], keys)
      except:
        print (site)
        print (keys)
        print (len(site_map[site][keys[0]][keys[1]][keys[2]]))
        raise(SystemExit(1))
      val = get_val(site_map[site], keys)
      vals.append( ( val if fn == None else fn(val) ) )

    print(("%-6d%6d" % (i, site)),end='')
    if guidekey:
      print(("%6d" % site_map[site][guidekey]), end='')
    print(line_fmt % tuple(vals))

def print_page_map_line(page_rec, line_fmt, line_pts, do_sites=False):
  print(line_fmt % line_pts, end='')
  if do_sites:
    sites = list(page_rec[2])
    print(("%8d " % sites[0]), end='')
    for site in sites[1:4]:
      print(("%6d " % site), end='')
    if (len(sites) > 4):
      print("    (%d total)" % len(sites), end='')
  print("")

def page_map_report_helper(page_map, page_size, sort_type, style,
  step_type, lines, total_rss, total_pages, total_huge_pages, sum_accs,
  sum_ddr, sum_pmm, cutoff, accum):

  if sort_type == PAGE_ADDR:
    sorted_pages = {k: v for k, v in \
      sorted(page_map.items(), key=lambda item: (item[0]))}
  elif sort_type == ACCESSES:
    sorted_pages = {k: v for k, v in \
      sorted(page_map.items(), key=lambda item: (item[1][0] + item[1][1]), \
             reverse=True)}
  elif sort_type == DDR_ACCS:
    sorted_pages = {k: v for k, v in \
      sorted(page_map.items(), key=lambda item: (item[1][0]), \
             reverse=True)}
  elif sort_type == PMM_ACCS:
    sorted_pages = {k: v for k, v in \
      sorted(page_map.items(), key=lambda item: (item[1][1]), \
             reverse=True)}
  else:
    print("Invalid sort type: %s" % sort_type)
    return


  if style == SAMPLE_PAGES:
    if lines == 0:
      print("Error: SAMPLE_PAGES requires positive line number")
      raise (SystemExit(1))

    if step_type == PAGE_ADDR:
      step_idx = 0
    elif step_type == ACCESSES:
      step_idx = 1
    elif step_type == DDR_ACCS:
      step_idx = 2
    elif step_type == PMM_ACCS:
      step_idx = 3


  header_fmt = ( "%-6s%12s%12s%12s%12s%12s%12s%12s%12s" )
  header_pts = ( "rank", "rss-MB", "rss-rat", "page-rat", "huge-rat",
                 "accs-rat", "ddr-rat", "pmm-rat", "accum-rat" )
  #line_fmt   = ( "%-6d%12.1f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f%12.6f" )
  line_fmt   = ( "%-6d%12.1f%12.6f%12.6f%12.6f%12d%12d%12d%12.6f" )

  i = cur_tot = cur_ddr = cur_pmm = cur_rss = cur_pgs = 0
  ith_tot = ith_ddr = ith_pmm = 0
  if style == SAMPLE_PAGES:
    next_step = (1.0/lines)
  end = len(sorted_pages)
  done = False

  print(header_fmt % header_pts)
  for pidx,page in enumerate(sorted_pages):
    if style == ALL_PAGES and lines and i > lines:
      break

    tot_accs = (page_map[page][0] + page_map[page][1])
    ddr_accs = page_map[page][0]
    pmm_accs = page_map[page][1]

    cur_pgs += 1
    cur_rss += page_size
    cur_tot += tot_accs
    cur_ddr += ddr_accs
    cur_pmm += pmm_accs
    rss_mb   = (float(cur_rss)/(1024.0*1024.0))

    ith_tot += tot_accs
    ith_ddr += ddr_accs
    ith_pmm += pmm_accs

    tot_rat  = float(cur_tot) / sum_accs if sum_accs != 0 else 0.0
    ddr_rat  = float(cur_ddr) / sum_accs if sum_accs != 0 else 0.0
    pmm_rat  = float(cur_pmm) / sum_accs if sum_accs != 0 else 0.0

    ith_tot_rat = float(ith_tot) / sum_accs if sum_accs != 0 else 0.0
    ith_ddr_rat = float(ith_ddr) / sum_accs if sum_accs != 0 else 0.0
    ith_pmm_rat = float(ith_pmm) / sum_accs if sum_accs != 0 else 0.0

    rss_rat  = float(cur_rss) / total_rss        if total_rss        != 0 else 0.0
    page_rat = float(cur_pgs) / total_pages      if total_pages      != 0 else 0.0
    huge_rat = float(cur_pgs) / total_huge_pages if total_huge_pages != 0 else 0.0
    #line_pts = (i, hex(page), rss_rat, tot_accs, tot_rat, ddr_accs, ddr_rat, pmm_accs, pmm_rat)
    if accum == True:
      line_pts = (i, rss_mb, rss_rat, page_rat, huge_rat, tot_rat, ddr_rat,
                  pmm_rat, tot_rat)
    else:
      line_pts = (i, rss_mb, rss_rat, page_rat, huge_rat, ith_tot,
                  ith_ddr, ith_pmm, tot_rat)
      #line_pts = (i, rss_mb, rss_rat, page_rat, huge_rat, ith_tot_rat,
      #            ith_ddr_rat, ith_pmm_rat, tot_rat)

    page_step = page_rat
    tot_step  = tot_rat
    ddr_step  = float(cur_ddr) / sum_ddr if sum_ddr != 0 else 0.0
    pmm_step  = float(cur_pmm) / sum_pmm if sum_pmm != 0 else 0.0

    step_rec = (page_step, tot_step, ddr_step, pmm_step)

    if style == ALL_PAGES:
      print_page_map_line(page_map[page], line_fmt, line_pts)
      ith_tot = ith_ddr = ith_pmm = 0
      i += 1
    elif style == SAMPLE_PAGES:
      if step_rec[step_idx] > next_step:
        print_page_map_line(page_map[page], line_fmt, line_pts)
        ith_tot = ith_ddr = ith_pmm = 0
        next_step += (1.0 / lines)
        i += 1
      if pidx == (end-1):
        print_page_map_line(page_map[page], line_fmt, line_pts)
    elif style == AGG_PAGES:
      if ( ((pidx+1) % (64*1024)) == 0 ):
        print_page_map_line(page_map[page], line_fmt, line_pts)
        ith_tot = ith_ddr = ith_pmm = 0
        i += 1
        if done:
          break
      if pidx == (end-1):
        print_page_map_line(page_map[page], line_fmt, line_pts)
      if cutoff != 0.0 and tot_rat > cutoff:
        done = True
    else:
      raise (SystemExit(1))
  print("")

def get_page_distro_bucket(ddr_accs, pmm_accs, max_rat):

  if pmm_accs == 0:
    return 0

  accs_rat = float(ddr_accs) / pmm_accs if pmm_accs !=0 else 0.0
  for idx,rat in enumerate(reversed(range(max_rat+1)), start=1):
    if accs_rat > (2**rat):
      return idx

  if ddr_accs == 0:  
    return ( (2*(max_rat+1)) + 1 )

  pmm_rat = float(pmm_accs) / ddr_accs if ddr_accs !=0 else 0.0
  for idx,rat in enumerate(range(1,max_rat+1), start=idx):
    if pmm_rat < rat:
      return idx

  return idx

def page_distro_report_helper(page_map, page_size, total_rss,
  total_pages, sum_accs, sum_ddr, sum_pmm, max_rat):

  header_fmt = ( "%-12s%12s%12s%12s%12s%12s%12s" )
  header_pts = ( "ddr : pmm", "pages", "page-rss", "page-rat",
                 "rss-rat", "accs", "acc-rat" )
  line_fmt   = ( "%-12s%12d%12d%12.6f%12.6f%12d%12.6f" )

  nr_buckets  = ((2*(max_rat+1)) + 3)
  page_histo  = [ 0 for x in range( nr_buckets ) ]
  accs_histo  = [ 0 for x in range( nr_buckets ) ]

  row_headers = [ "pmm == 0" ] + \
                [ ( ">%4d : 1"  % (2**x)) for x in reversed(range(max_rat+1)) ] +\
                [ ( "1 : <%4d"  % (2**x)) for x in range(1,max_rat+1) ] +\
                [ ( "1 : >%4d" % (2**max_rat)) ] +\
                [ "ddr == 0", "cold" ]

  for page in page_map:
    tot_accs = (page_map[page][0] + page_map[page][1])
    ddr_accs = page_map[page][0]
    pmm_accs = page_map[page][1]

    bkt_idx  = get_page_distro_bucket(ddr_accs, pmm_accs, max_rat)
    page_histo[bkt_idx] += 1
    accs_histo[bkt_idx] += tot_accs

  cold_pages = (( int(total_rss) // page_size) - len(page_map.keys()))
  for page in range(cold_pages):
    page_histo[(nr_buckets-1)] += 1

  total_rss /= (1024*1024)
  print(header_fmt % header_pts)
  for row_idx,rec in enumerate(zip(page_histo, accs_histo)):
    pages, accs = rec
    page_rss    = ( (pages * page_size) / (1024*1024) )
    page_rat    = float(pages)    / total_pages if total_pages != 0 else 0.0
    rss_rat     = float(page_rss) / total_rss   if total_rss   != 0 else 0.0
    accs_rat    = float(accs)     / sum_accs    if sum_accs    != 0 else 0.0

    line_vals   = ( row_headers[row_idx], pages, page_rss, page_rat,
                    rss_rat, accs, accs_rat)

    print(line_fmt % line_vals)
  print("")

def report_page_map(page_map, page_type, sort_type, style=ALL_PAGES, \
  step_type=ACCESSES, lines=0, total_rss=0, total_pages=0, \
  total_huge_pages=0, cutoff=0.0, max_rat=0, accum=False):

  if page_type == PAGES:
    page_size = (1<<PAGE_SHIFT)
  elif page_type == HUGE_PAGES:
    page_size = (1<<HUGE_PAGE_SHIFT)
#  elif page_type == GB_PAGES:
#    page_size = (1<<GB_PAGE_SHIFT)
  else:
    print ("invalide page type: %s" % page_type)
    raise (SystemExit(1))

  sum_accs = sum ([(x[0] + x[1]) for x in page_map.values()])
  if sort_type == ACCESSES:
    sum_ddr = sum_pmm = sum_accs
  else:
    sum_ddr = sum ([(x[0]) for x in page_map.values()])
    sum_pmm = sum ([(x[1]) for x in page_map.values()])

#  header_fmt = ( "%-6s%12s%9s%12s%9s%12s%9s%12s%9s%8s" )
#  header_pts = ( "rank", "page", "rss-MB", "rss-rat", "accs", "tot-rat", \
#                 "ddr", "ddr-rat", "pmm", "pmm-rat", "sites" )
#  line_fmt   = ( "%-6d%12s%12s%9.3f%12d%9.3f%12d%9.3f%12d%9.3f" )

  if style == PAGE_DISTRO:
    page_distro_report_helper(page_map, page_size, total_rss,
    total_pages, sum_accs, sum_ddr, sum_pmm, max_rat)
  else:
    page_map_report_helper(page_map, page_size, sort_type, style,
    step_type, lines, total_rss, total_pages, total_huge_pages, sum_accs,
    sum_ddr, sum_pmm, cutoff, accum)

def stat_report(benches, configs, iters, stat, absolute, ci95, style):

  print( ("%s %s (%d iters)" %
           ( ("Absolute" if absolute else "Relative"), \
             stat, iters )
       ) )

  print("")
  cfg_map = {}
  for a,cfg in zip(string.ascii_lowercase, configs):
    cfg_map[cfg] = a
    print (" %s : %s" % (a, cfg))
  print("")

  print (("%-18s" % "bench"), end='')
  for cfg in configs:
    print (("%16s" % cfg_map[cfg]), end='')
  print("")

  rstrs = get_stat_report_strs(benches, configs, iters, stat, absolute,
          ci95, style)

  for bench in benches + ["average"]:
    print (("%-18s" % bench), end='')
    for cfg in configs:
      if absolute:
        if ci95:
          print ( ("%16s" % ("%s %s" % ( rstrs[bench][cfg]))), end='')
        else:
          print ( ("%16s" % rstrs[bench][cfg] ), end='')
      else:
        if ci95:
          print ( ("%16s" % ("%s %s" % ( rstrs[bench][cfg]))), end='')
        else:
          print ( ("%16s" % rstrs[bench][cfg] ), end='')
    print("")
  print("")

