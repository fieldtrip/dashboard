#!/usr/bin/env python
import glob, sys, os.path, re
from fttest import TestResult


def parse_log(fname):
  '''Parse log file containing SVN info and MATLAB xUNIT output.
  
  Returns
  -------
  out : tuple (revision, committer, outcome, duration)
  '''
  f = open(fname)
  try:
    contents = '\n'.join(f.readlines())
  finally:
    f.close()

  # Find revision
  revision = ''
  match = re.search(r'Revision: (\d+)', contents)
  if match: 
    revision = match.group(1)

  # Find committer
  committer = ''
  match = re.search(r'Last Changed Author: (\w+)', contents)
  if match:
    committer = match.group(1)

  # Find concluding line of xUnit for MATLAB:
  match = re.search(r'(PASSED|FAILED) in (.+) seconds', contents)
  if match:
    outcome, duration = match.group(1), float(match.group(2))
  else:
    outcome, duration = 'unknown', float('nan')

  return (revision, committer, outcome.lower(), duration)


if __name__ == '__main__':
  from optparse import OptionParser  # use argparse for Python >= 2.7
  import pickle

  # handle options
  parser = OptionParser()
  parser.add_option('-p', '--pickle')
  parser.add_option('-j', '--json')
  (options, args) = parser.parse_args()

  # parse logs
  test_results = []
  for fname in args:
    rev, committer, outcome, duration = parse_log(fname)
    if not (rev and committer):
      continue
    test_results.append(TestResult(rev, fname, committer, outcome, duration))

  # potentially write results to disk
  if options.pickle: 
    try:
      f = open(options.pickle, 'wb')
      pickle.dump(test_results, f)
    finally:
      f.close()
  if options.json: 
    try:
      # Python 2.4 does not have JSON yet. So, we manually format some output.
      # Note that this is an ugly hack, and might not be fully JSON compatible:
      f = open(options.json, 'w')
      f.write('[\n')
      for r in test_results:
        f.write(
          ('\t{"revision" : "%s", "test_name" : %s, "committer" : "%s", ' + \
            '"outcome" : "%s", "duration" : %.2f},\n') % 
          (r.revision, r.test_name, r.committer, r.outcome, r.duration))
      f.write(']\n')

    finally:
      f.close()
