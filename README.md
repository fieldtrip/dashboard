# FT-test: A test runner for FieldTrip

## Abstract
The purpose of dashboard is to provide rapid feedback to FieldTrip developers on
the quality of their commits as indicated by passing and failing test scripts.
As such, it is important to provide the results shortly after a commit.
Further, the developers have to be notified if their change causes failing
tests, and report of the test results should be easily accessible.


## Considerations
Some tests (e.g. `ft_connectivity_tutorial.m`) take a long time to complete.
This hinders rapid testing. One approach is to test with a job scheduler on a
computing cluster, the other is to disable slow tests, and allow for testing on
other platforms as well (e.g. Windows).

Since the aim is to support developers with reliable information, the test
results should be as accurate as possible. If historical results are to be
provided, this means *that all the test have to be run for every revision*.
Although a triggering mechanism exists to trigger relevant tests, a failure in
the detection of the dependencies might cause misinformation presented in the
test results.


### Design requirements
- All tests are run for every revision,
- results for a revision are available in a timely fashion (30 mins?),
- if a change causes new tests to fail, a mail is sent to the committer,
- test results are made available in a formatted table on the FT wiki.


## What is being tested
Test scripts in subdirectories ending with 'test' in the FieldTrip repository.


## Installation
### Requirements
To run the tests, of course a MATLAB installation is needed. FT-test is
designed to run on the DCCN mentat cluster, and the scripts assume a Unix/Linux
environment. Further, the following software is needed:
- MATLAB
- xUnit

### One step at at time
1. Test if the environment is setup correctly by running a single test:
    $ ./run-test.sh testfile FIELDTRIPDIR
2. Test if new revisions are detected and downloaded automatically.
3. Run a batch on the cluster.
4. Add the cronjobs for polling, parsing and reporting.


## How it works
### SVN polling
A svn-poll cronjob is checking for new SVN revisions. When a new revision is
detected:
1.  a new revision #### checked out on disk,
2.  the tests are scheduled to run, and results written to `r####-test-results`.

Revisions older than a day are deleted again; this is the window in which the tests have to be performed.


### Parsing the log files
A parsing cronjob is parsing the results in `r####-test-results` dirs not older
than a day, and storing the per-revision test results. This runs asynchronously
with the polling job, so that results can be made available when test complete.
After three days, the logs are compressed.


### Presenting the results
Finally, a presentation cronjob integrates over the test results _for multiple
revisions_, and creates a text report and a wiki-formatted report for the last
revision.

Also a daily report consisting of the non-passing tests is mailed to
fieldtrip-bugs@science.ru.nl.

# TODO
- Parsing of the results appears to be a bit slow. This might form a
  performance bottleneck in the future.
- The pickle format is very cumbersome. Find proper intermediate format
  (JSON?), work with that.
- Although parsing of the logs seems to work, it is a bit of a mess.
