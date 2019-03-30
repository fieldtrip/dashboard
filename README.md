# FieldTrip dashboard

This repository contains the code we use for testing the FieldTrip code base.
The aim is to provide rapid feedback to developers on the quality of their
commits.

### Design considerations

- test scripts should be easy to contribute by users
- some tests are fast, whereas others take a long time to run
- some tests require the loading of (non-shared) data on disk
- test scripts should be easy to execute by developers and users alike
- test results should be provided shortly after a GitHub commit
- all tests can be executed for every revision and/or branch
- all tests can be executed for different MATLAB and Octave versions
- all tests can be executed for different operating systems
- the dashboard scripts are designed to run on the DCCN compute cluster

## What is being tested

All MATLAB scripts (technically functions) with the name test_xxx.m that are
located in the `fieldtrip/test` directory are considered for execution. Test
scripts must indicate on the _WALLTIME_ and _MEM_ lines what their requirements
are for execution on the DCCN cluster. Test scripts may indicate on the
_DEPENDENCY_ line on which FieldTrip functions they specifically depend. This
allows filtering the test scripts to find the relevant ones upon a change to a
specific FieldTrip function.

## How it works

The **schedule-tests.sh** script identifies all test scripts. For each test
script, a temporary Bash script is created.

4. the Bash script is scheduled for execution on the DCCN cluster
5. it creates a temporary MATLAB script that sets the path, prints some diagnostics and runs the specific test in a try-catch statement
6. it starts MATLAB with that temporary MATLAB script
7. if an error is detected it will print "FAILED", otherwise it prints "PASSED"
8. the output is captured in stdout/stderr files

The stdout/stderr output of all jobs is collected in a log file directory. The
log files are parsed using a cron job and the developers receive an email with
the summary of the "FAILED" scripts.

## Dashboard database

The dashboard in principle only requires MATLAB scripts (technically functions)
for execution, which can also easily be executed on the MATLAB command line to
test manually.

To provide better summaries of test results on different versions of MATLAB,
different operating systems, and different FieldTrip versions, we capture the
results in a dashboard database. This happens automatically by executing the
test script (technically function) with the `ft_test` function. The results of
all tests can be queried using `ft_test`, returning a table that shows all
details.

Using the dashboard scripts, all test scripts will be executed. On the MATLAB
command line the `ft_test` function can be used run all tests, to select
specific tests based on requirements (files on disk, memory, walltime,
dependencies), or to select a single test. In all cases the results will be
written to the dashboard database.
