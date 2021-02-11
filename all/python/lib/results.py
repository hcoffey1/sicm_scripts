from lib.globals import *
from lib.postprocess import *

def get_stat_results_dict(benches=[], cfgs=[], iters=1, stat=FOM):

  results = dict()
  for bench, cfg_name, it in expiter(benches, cfgs, iters):

    bn,sz    = bench.split("-")
    cfg,args = cfg_name.split(":")

    if not bench in results:
      results[bench] = dict()

    if not cfg_name in results[bench]:
      results[bench][cfg_name] = dict()

    results[bench][cfg_name][it] = dict()

    rdict = results[bench][cfg_name][it]
    if stat in [FOM,PEAK_RSS,RUN_TIME]:
      outfile  = get_stdout_file(bn, sz, cfg, args, it)
      parse_time(bn, outfile, rdict)
    elif stat in numastat_stats:
      numafile = get_numastat_file(bn, sz, cfg, args, it)
      parse_numastat(numafile, rdict)
    elif stat in pcm_stats:
      pcmfile = get_pcm_memory_file(bn, sz, cfg, args, it)
      parse_pcm(pcmfile, rdict)

  return results

def get_stat_report_strs(benches, cfgs, iters=5, stat=FOM, \
  absolute=False, cis=False, style=MEAN):

  if cis and iters < 2:
    cis = False

  results = get_stat_results_dict(benches, cfgs, iters, stat)

  if not absolute:
    basecfg = cfgs[0]

  report_strs = dict()
  averages    = dict()
  for expcfg in cfgs:
    averages[expcfg] = []

  for bench in results.keys():
    report_strs[bench] = dict()

    if not absolute:
      basevals   = [ results[bench][basecfg][i][stat] for i in \
                     results[bench][basecfg].keys() ]
      if None in basevals:
        basemean = basemedian = basestd = None
      else:
        basemean   = mean(basevals) 
        basemedian = median(basevals) 
        basestd    = stdev(basevals) if len(basevals) > 1 else 0.0

    for expcfg in results[bench].keys():
      expvals   = [ results[bench][expcfg][i][stat] for i in \
                     results[bench][expcfg].keys() ]

      if None in expvals:
        expmean = expmedian = expstd = None
      else:
        #print (expvals)
        expmean   = mean(expvals)
        expmedian = median(expvals)
        expstd    = stdev(expvals) if len(expvals) > 1 else 0.0

      if cis:
        if absolute:
          ci = get95CI(expmean, expmean, expstd, expstd, iters)
        else:
          ci = get95CI(basemean, expmean, basestd, expstd, iters)
          ci /= expmean

      val = None
      if expmean != None:
        if not absolute:
          if style == MEAN:
            val = (float(expmean) / basemean) if basemean > 0.0 else None
          else:
            val = (float(expmedian) / basemedian) if basemedian > 0.0 else None
        else:
          val = (float(expmean)) if style == MEAN else (float(expmedian))

      if val == None:
        report_strs[bench][expcfg] = "N/A" if not cis else ("N/A", "N/A")
      else:
        if absolute:
          if "ratio" in stat:
            report_strs[bench][expcfg] = ("%4.3f" % val) if not cis else \
                                         (("%4.3f" % val), (("%4.3f" % ci)).rjust(6))
          else:
            report_strs[bench][expcfg] = ("%5.1f" % val) if not cis else \
                                         (("%5.1f" % val), (("%5.1f" % ci)).rjust(6))
        else:
          report_strs[bench][expcfg] = ("%4.3f" % val) if not cis else \
                                       (("%4.3f" % val), (("%4.3f" % ci)).rjust(6))

      if val != None:
        averages[expcfg].append(val)

  report_strs["average"] = dict()
  for expcfg in cfgs:
    val = None
    if (len(averages[expcfg]) > 0):
      if not absolute:
        val = safe_geo_mean(averages[expcfg])
      else:
        val = mean(averages[expcfg])

    if val == None:
      report_strs["average"][expcfg] = "N/A" if not cis else ("N/A", "-".rjust(6))
    else:
      if absolute:
        if "ratio" in stat:
          report_strs["average"][expcfg] = ("%4.3f" % val) if not cis else \
                                           (("%4.3f" % val), ("-".rjust(6)))
        else:
          report_strs["average"][expcfg] = ("%5.1f" % val) if not cis else \
                                           (("%5.1f" % val), ("-".rjust(6)))
      else:
        report_strs["average"][expcfg] = ("%4.3f" % val) if not cis else \
                                         (("%4.3f" % val), ("-".rjust(6)))
                                      
  return report_strs



# Gets a dict of results for the ddr_bandwidth configs
def get_ddr_bandwidth_results(benches, cfgs):
  profcfg_results = dict()
  bandwidth_profile_results = dict()
  for bench in benches:
    profcfg_results[bench] = dict()
    bandwidth_profile_results[bench] = dict()
    for cfg_name in cfgs:
      cfg.read_cfg(cfg_name)
      # Get the results for the profcfg
      profcfg_results[bench][cfg_name] = dict()
      bandwidth_profile_results[bench][cfg_name] = dict()

      profcfg_results_dir = get_results_dir(bench, cfg.current_cfg['runcfg']['profcfg'], 0)
      parse_bench(bench, cfg.current_cfg['runcfg']['profcfg'], profcfg_results_dir, profcfg_results[bench][cfg_name])
      bandwidth_profile_dir = results_dir + bench + '/' + cfg_name + '/'

      # Get the bandwidth of the baseline run
      refres = None
      idirs    = [ x+'/' for x in glob(bandwidth_profile_dir+"*") ]
      for x in idirs:
        if x.endswith('i0/'):
          refres = dict()
          parse_pcm(x, refres)
          #print("refres: avg: %5.2f max: %5.2f" % \
          #      (refres[AVG_DDR4_BANDWIDTH], refres[MAX_DDR4_BANDWIDTH]))
      for idir in idirs:
        site = tuple([int(idir.split('/')[-2].strip('i'))])
        bandwidth_profile_results[bench][cfg_name][site[0]] = dict()
        parse_pcm(idir, bandwidth_profile_results[bench][cfg_name][site[0]], refres=refres)

  return (profcfg_results, bandwidth_profile_results)


def parse_numastat(results_dir, results):
  node0 = 0
  node1 = 0
  results['node0_memory'] = []
  results['node1_memory'] = []
  fd = open(results_dir + 'numastat -m.txt', 'r')
  first = True

  used = re.compile('MemUsed\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)')
  for line in fd:
    used_ret = used.match(line)
    if used_ret:
      if first:
        results[BASELINE_NODE0_MEMORY] = float(used_ret.group(1))
        results[BASELINE_NODE1_MEMORY] = float(used_ret.group(2))
        first = False
      else:
        results['node0_memory'].append(float(used_ret.group(1)) - results[BASELINE_NODE0_MEMORY])
        results['node1_memory'].append(float(used_ret.group(2)) - results[BASELINE_NODE1_MEMORY])
  results[AVG_NODE0_MEMORY] = sum(results['node0_memory']) / len(results['node0_memory'])
  results[AVG_NODE1_MEMORY] = sum(results['node1_memory']) / len(results['node1_memory'])
  results[MAX_NODE0_MEMORY] = max(results['node0_memory'])
  results[MAX_NODE1_MEMORY] = max(results['node1_memory'])
  results[NUMASTAT_INTERVALS] = len(results['node0_memory'])


def get_first_mem(results_dir):
  fd = open(results_dir + 'memory.txt', 'r')
  sys_bandwidth = re.compile('[\r\s]*\|--\s+System Memory Throughput\(MB/s\):\s+([\d\.]+)')
  vals = []
  for line in fd:
    line = line.rstrip()
    sys_bandwidth_ret = sys_bandwidth.match(line)
    if sys_bandwidth_ret:
      vals.append(float(sys_bandwidth_ret.group(1)))
    if len(vals) > 2:
      break
  return (sum(vals) / len(vals))


def parse_pcm(results_dir, results, refres=None):
  results[TOTAL_BANDWIDTH] = []
  results[DDR4_BANDWIDTH] = []
  results[MCDRAM_BANDWIDTH] = []
  fd = open(results_dir + 'memory.txt', 'r')
  sys_bandwidth = re.compile('[\r\s]*\|--\s+System Memory Throughput\(MB/s\):\s+([\d\.]+)')
  node_bandwidth = re.compile('[\r\s]*\|--\s+DDR4 Memory \(MB/s\)\s+:\s+([\d\.]+)\s+--\|\|--\s+MCDRAM \(MB/s\)\s+:\s+([\d\.]+)\s+--\|')

  startddr    = []
  startmcdram = []
  for line in fd:
    line = line.rstrip()
    sys_bandwidth_ret = sys_bandwidth.match(line)
    if sys_bandwidth_ret:
      results[TOTAL_BANDWIDTH].append(float(sys_bandwidth_ret.group(1)))
      # MRJ -- why is this done twice?
      #results[TOTAL_BANDWIDTH].append(float(sys_bandwidth_ret.group(1)))
      continue
    node_bandwidth_ret = node_bandwidth.match(line)
    if node_bandwidth_ret:
      results[DDR4_BANDWIDTH].append(float(node_bandwidth_ret.group(1)))
      results[MCDRAM_BANDWIDTH].append(float(node_bandwidth_ret.group(2)))
      if (len(startddr) < 3):
        startddr.append((float(node_bandwidth_ret.group(1))/1024.0))
      if (len(startmcdram) < 3):
        startmcdram.append((float(node_bandwidth_ret.group(2))/1024.0))
      continue
  results[SUM_TOTAL_BANDWIDTH]   = ( (sum(results[TOTAL_BANDWIDTH]) / 1024.0 ) )
  results[AVG_TOTAL_BANDWIDTH]   = ( (sum(results[TOTAL_BANDWIDTH]) / len(results[TOTAL_BANDWIDTH])) / 1024.0 )
  results[MAX_TOTAL_BANDWIDTH]   = ( max(results[TOTAL_BANDWIDTH]) / 1024.0 )
  results[AVG_MCDRAM_BANDWIDTH]  = ( (sum(results[MCDRAM_BANDWIDTH]) / len(results[MCDRAM_BANDWIDTH])) / 1024.0)
  results[MAX_MCDRAM_BANDWIDTH]  = ( max(results[MCDRAM_BANDWIDTH]) / 1024.0)
  results[AVG_DDR4_BANDWIDTH]    = ( (sum(results[DDR4_BANDWIDTH]) / len(results[DDR4_BANDWIDTH])) / 1024.0 )
  results[MAX_DDR4_BANDWIDTH]    = ( max(results[DDR4_BANDWIDTH]) / 1024.0 )
  if refres != None:
    refavg = refres[AVG_DDR4_BANDWIDTH]
    refmax = refres[MAX_DDR4_BANDWIDTH]
    adj_avg = results[AVG_DDR4_BANDWIDTH] - refavg
    adj_max = results[MAX_DDR4_BANDWIDTH] - refmax
    results[AVG_DDR4_BANDWIDTH] = max([0.0, adj_avg])
    results[MAX_DDR4_BANDWIDTH] = max([0.0, adj_max])
    #print ("%3.4f %3.4f" % (results[AVG_DDR4_BANDWIDTH], results[MAX_DDR4_BANDWIDTH]))


def get_peak_rss(bench, cfg_name, results):
  rss = re.compile('\tMaximum resident set size')

  results['default_peak_rss'] = []
  for fname in glob("%s%s/%s/i*/stdout0.txt"% (results_dir, bench, cfg_name)):
    fd = open(fname)
    for line in fd:
      if rss.match(line):
        results['default_peak_rss'].append(MB(KB2B(line.split()[-1])))
        break
  results['default_peak_rss'] = mean(results['default_peak_rss'])
  print ("peak_rss: %d" % results['default_peak_rss'])

def parse_time(bench, outfile, results):

  results[FOM]      = 0.0
  results[RUN_TIME] = 0.0
  results[PEAK_RSS] = 0.0

  fom_re   = time_re
  fom_func = (lambda line : ( 1.0/(convert_to_seconds(line.split()[-1])) ))
  if bench in fom_parse:
    fom_re, fom_func = fom_parse[bench]

  fd = open(outfile, 'r')
  for line in fd:
    if fom_re.match(line):
      results[FOM] = fom_func(line)
    if rss_re.match(line):
      results[PEAK_RSS] = MB(KB2B(line.split()[-1]))
    if time_re.match(line):
      results[RUN_TIME] = convert_to_seconds(line.split()[-1])

