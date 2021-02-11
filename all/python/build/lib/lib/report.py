#!/usr/bin/env python3

from lib.globals import *
from lib.postprocess import *

#############################################################################
# REPORTING
#############################################################################
site_report_fmt = {
  "abs_base" : (
  ( ("%10s", "site-MB"),   ("%10d",  (PER_SITE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "site-accs"), ("%12d",  (PER_SITE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%10s", "page-MB"),   ("%10d",  (PER_PAGE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "page-accs"), ("%12d",  (PER_PAGE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%12s", "ddr-accs"),  ("%12d",  (PER_SITE, ABSOLUTE, DDR_ACCS),            None) ),
  ( ("%12s", "pmm-accs"),  ("%12d",  (PER_SITE, ABSOLUTE, PMM_ACCS),            None) ),
  ( ("%9s",  "hit-rat"),   ("%9.3f", (PER_SITE, ABSOLUTE, HIT_RATIO),           None) ),
  ( ("%9s",  "mis-rat"),   ("%9.3f", (PER_SITE, ABSOLUTE, MISS_RATIO),          None) ),
  #( ("%10s", "line-MB"),   ("%10d",  (PER_LINE, ABSOLUTE, TOUCHED),         MB_scale) ),
  #( ("%12s", "line-accs"), ("%12d",  (PER_LINE, ABSOLUTE, ACCESSES),            None) ),
  #( ("%9s",  "accs/pg"),   ("%9.3f", (PER_SITE, ABSOLUTE, ACCS_PAGE),            None) ),
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
  ( ("%10s", "site-MB"),   ("%10d",  (PER_SITE, ABSOLUTE, TOUCHED),         MB_scale) ),
  ( ("%12s", "site-accs"), ("%12d",  (PER_SITE, ABSOLUTE, ACCESSES),            None) ),
  ( ("%12s", "ddr-accs"),  ("%12d",  (PER_SITE, ABSOLUTE, DDR_ACCS),            None) ),
  ( ("%12s", "pmm-accs"),  ("%12d",  (PER_SITE, ABSOLUTE, PMM_ACCS),            None) ),
  ( ("%9s",  "hit-rat"),   ("%9.3f", (PER_SITE, ABSOLUTE, HIT_RATIO),           None) ),
  ( ("%9s",  "mis-rat"),   ("%9.3f", (PER_SITE, ABSOLUTE, MISS_RATIO),          None) ),
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
    first_pts = ("rank", "site", "+/-")
  else:
    first_fmt = "%-6s%6s"
    first_pts = ("rank", "site")

  header_fmt = ( first_fmt + "".join([x[0][0] for x in stats]) )
  header_pts = ( first_pts + tuple([x[0][1] for x in stats]) )
  line_fmt   = "".join([x[1][0] for x in stats])
  line_keys  = [x[1][1] for x in stats]
  line_fn    = [x[1][2] for x in stats]

  if swaptier:
    pos = "+"
    neg = "-"
  else:
    pos = "-"
    neg = "+"

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
      print("%6s" % (pos if site_map[site][guidekey] else neg), end='')
    print(line_fmt % tuple(vals))

def report_page_map(page_map, sort_type, lines):

  if sort_type == ACCESSES:
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

  header_fmt = ( "%-6s%12s%12s%12s%s" )
  header_pts = ( "rank", "page", "ddr", "pmm", "sites" )
  line_fmt   = ( "%-6d%12s%12d%12d" )

  print(header_fmt % header_pts)
  for i,page in enumerate(sorted_pages,start=1):
    if lines and i > lines:
      break

    print(line_fmt % (i, hex(page), page_map[page][0],
          page_map[page][1]), end='')
    for site in page_map[page][2]:
      print(("%6d " % site), end='')
    print("")
  print("")

