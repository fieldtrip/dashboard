#!/usr/bin/env python
import glob, sys, os.path, re, logging, operator
from fttest import TestResult
from pprint import pprint

FT_GOOGLECODE = 'http://code.google.com/p/fieldtrip/source/detail?r=%s'
FT_BUGZILLA = 'http://bugzilla.fcdonders.nl/show_bug.cgi?id=%s'
TXT_TEMPLATE = \
  '%(revision)6s %(test_name)30s %(bug_id)8s %(outcome)10s %(duration)8s'
DOCUWIKI_HEADER = '<sortable 4>\n^Revision ^ Test ^ Bugzilla ^ Status ^  Duration ^ History ^'
DOCUWIKI_TEMPLATE = '|%(revision)s | %(test_name)s | %(bug)s | %(outcome)s |  %(duration)s| %(history)s|'
WIKI_LOGURL = 'http://fieldtrip.fcdonders.nl/development/dashboard/r%(revision)s/%(testname)s'
DOCUWIKI_FOOTER = "</sortable>"

log = logging.getLogger(__name__)


def bad_revisions(revisions, status_strings):
  '''Find revisions that are problematic.

  Problematic revisions are revisions that change a test from PASSED to a
  different status
  '''
  revisions, status_strings = zip(*sorted(zip(revisions, status_strings)))
  bad = [revisions[i] for (i, s) in enumerate(status_strings) 
    if s != 'PASSED' and status_strings[i-1] == 'PASSED' and i != 0]
  return bad


def status_char(test):
  '''Convert status string to character for spark-line visualisation.'''
  mapping = {'passed' : '+', 'failed' : '-', 'unknown' : '?'}
  if test:
    return mapping.get(test.outcome, '!')
  return '!'


def ascii_history(results):
  '''Collect the test-result history for a collection of results.'''
  revs, test_names = zip(*results.keys())
  revs = sorted(set([int(r) for r in revs if r != 'unknown']))
  test_names  = sorted(set(test_names))

  hist = {}
  for tn in test_names:
    hist[tn] = ''.join(
      [status_char(results.get((r, tn))) for r in revs])

  return revs, test_names, hist


def format_docuwiki(dic):
  def link(name, target):
    if name and target:
      return '[[%s|%s]]' % (target, name)
    return ''


  return DOCUWIKI_TEMPLATE % dict(
    revision=link(dic.revision, FT_GOOGLECODE % dic.revision),
    test_name=test.test_name, 
    bug=link(dic.bug_id, dic.bug_url),
    outcome=link(test.outcome,
      WIKI_LOGURL % dict(revision=dic.revision, testname=dic.test_name)),
    duration=test.duration,
    history=test.history)


def format_txt(test):
  '%(revision)6s %(test_name)30s %(bug_id)8s %(outcome)10s %(duration)8s'
  return TXT_TEMPLATE % dict(
    revision=test.revision, 
    test_name=test.test_name, 
    bug_id=test.bug_id, 
    outcome=test.outcome,
    duration=test.duration)


if __name__ == '__main__':
  from optparse import OptionParser  # use argparse for Python >= 2.7
  import pickle

  # handle options
  parser = OptionParser()
  parser.add_option('-w', '--wiki', action='store_true', default=False)
  parser.add_option('-v', '--verbose', action='store_true', default=False)
  (options, args) = parser.parse_args()

  if options.verbose:
    logging.basicConfig(level=logging.DEBUG)
  else:
    logging.basicConfig(level=logging.INFO)

  # load parsed logs
  test_results = []
  for fname in args:
    f = open(fname, 'rb')
    try:
      p = pickle.load(f)
      test_results.extend(p)
    except ValueError, EOFError:
      log.warning('Could not load %s!' % fname)
    f.close()

  # add index for easy lookups
  def f(tr):
    return (tr.revision, tr.test_name), tr

  tests = dict(f(t) for t in test_results)
  revs, test_names, hist = ascii_history(tests)


  # format output
  if options.wiki:
    print DOCUWIKI_HEADER

  for tn in test_names:
    for r in revs[::-1]:
      test = tests.get((r, tn))
      if test:
        test.history = hist[tn][-10:]

        if options.wiki:
          print format_docuwiki(test)
        else:
          print format_txt(test)
        break  # continue with next test
  if options.wiki:
    print DOCUWIKI_FOOTER


#-------------------------------------------------------------------------------
# run with nosetests:

def test_bad_revisions():
  P, U, F = 'PASSED', 'FAILED', 'UNKNOWN'
  statuses = [F, P, P, F, U, F, F, P, U, P, P]
  revisions = [str(r) for r in range(len(statuses))]
  assert bad_revisions(revisions, statuses) == ['3', '8']
