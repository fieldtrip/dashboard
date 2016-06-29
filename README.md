# FieldTrip - Dashboard for automated testing and quality control

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
- all tests can be run for every revision
- all tests can be run for different MATLAB and Octave versions
- the summary of results is displayed in a dashboard-like fasion

## What is being tested
MATLAB scripts in subdirectories ending with 'test' in the FieldTrip
repository. All test scripts (or more precisely: test functions) should
run through without errors, or should throw a MATLAB error.

## Requirements
To run the tests, of course a MATLAB installation is needed. The dashboard scripts are
designed to run on the DCCN mentat cluster, and the scripts assume a Unix/Linux
environment. Further, the following software is needed:
- MATLAB
- xUnit

## How it works
The **schedule-tests.sh** bash script identifies all test scripts in a specific FieldTrip directory. For each test script, a temporary bash script is created that

1. prints some diagnostic information
2. starts MATLAB with the specific FT function to test, wrapped in xUnit
3. prints some diagnostic information
4. this bash script is scheduled to be executed on the Torque cluster
5. MATLAB starts on a compute node and writes log information to screen, which is captured in stdout/stderr

Upon job completion, the stdout/stderr files are copied from the compute node. The stdoud log file contains either the string "PASSED" or "FAILED" and can be parsed

The scheduling of the jobs (on the basis of new revisions),
the parsing of the log files, and the reporting on the wiki
and through email were all part of the dashboard code. With the
recent migration from SVN to Git, these aspects of the dashboard
have become defunct and will have to be reimplemented. See
http://bugzilla.fieldtriptoolbox.org/show_bug.cgi?id=3066
