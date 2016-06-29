import re
import os.path

FT_BUGZILLA = 'http://bugzilla.fcdonders.nl/show_bug.cgi?id=%s'
OUTCOMES = ['passed', 'failed', 'unknown']

class TestResult:
  def __init__(self, revision, fname, committer, outcome, duration):
    self.revision = int(revision)
    self.fname = fname
    self.committer = committer
    assert outcome in OUTCOMES, \
      'Invalid test outcome: "%s". Should be one of %s.' % \
      (outcome, ', '.join(OUTCOMES))
    self.outcome = outcome
    self.duration = duration

  @property
  def test_name(self):
    '''Extract test name from filename.'''
    return os.path.splitext(os.path.basename(self.fname))[0]

  @property
  def bug_id(self):
    '''Extract bug name from a filename.'''
    m = re.search(r'bug(\d+)', self.fname)
    if m:
      return int(m.group(1))
    return ''

  @property
  def bug_url(self):
    return FT_BUGZILLA % self.bug_id

  def __str__(self):
    return '%(rev)s:%(tn)s by %(com)s %(outcome)s in %(duration).2f sec.' % \
      dict(rev=self.revision, tn=self.test_name, com=self.committer,
        outcome=self.outcome, duration=self.duration)
