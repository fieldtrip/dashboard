# FieldTrip dashboard

This repository contains the code we use for testing the FieldTrip code base using the unit and integration tests in [fieldtrip/test](https://github.com/fieldtrip/fieldtrip/tree/master/test). The aim of the dashboard is to provide rapid feedback to developers on the quality of their
commits.

### Design considerations

-   test scripts should be easy to contribute by users
-   some tests are fast, whereas others take a long time to run
-   some tests require the loading of (non-shared) data on disk
-   test scripts should be easy to execute by developers and users alike
-   test results should be provided shortly after a GitHub commit
-   all tests can be executed for every revision and/or branch
-   all tests can be executed for different MATLAB and Octave versions
-   all tests can be executed for different operating systems
-   the dashboard scripts are designed to run on the DCCN compute cluster

## What is being tested

All MATLAB scripts (technically functions) with the name `test_xxx.m` that are
located in the [fieldtrip/test](https://github.com/fieldtrip/fieldtrip/tree/master/test)
directory are considered for execution. Test scripts must indicate on
the `WALLTIME` and `MEM` lines what their requirements are for execution
on the DCCN cluster. Test scripts may indicate on the `DEPENDENCY`
line on which FieldTrip functions they specifically depend. This
allows filtering the test scripts to find the relevant ones upon a change to a
specific FieldTrip function.

## How it works

The `run-test.sh` script executes a single test in MATLAB. The
`schedule-batch.sh` script runs all test scripts for a single version of MATLAB.
The `schedule-matlabs.sh` script runs all test scripts for all versions of
MATLAB.

The general procedure is that for each test script a temporary Bash script is created.

1.  the Bash script is scheduled for execution on the DCCN cluster
2.  it creates a temporary MATLAB script that sets the path, prints some diagnostics and runs the specific test in a try-catch statement
3.  it starts MATLAB with that temporary MATLAB script
4.  if an error is detected it will print "FAILED", otherwise it prints "PASSED"
5.  the output is captured in stdout/stderr files

When running the whole batch of test scripts, the stdout/stderr output of all
jobs is collected in a log file directory. The collection of log files are
parsed using a cron job and the developers receive an email with the summary of
the "FAILED" scripts.

## How to add a test

Adding a test script involves that you add an m-file to the `fieldtrip/test` directory
that starts like this:

    function test_ft_examplefunction

    % WALLTIME 00:10:00
    % MEM 3gb
    % DEPENDENCY ft_examplefunction ft_checkdata ft_plot_mesh

    % here comes your code, it should give an error if the test fails
    ...

Although we refer to it as a script, technically it should be a function and hence start with the function definition on the 1st line corresponding to the m-file name. You should call it `test_xxx.m` if you want to run it automatically, or `inspect_xxx.m` if it requires visual inspection (e.g. when plotting something, or when testing a graphical user interface).

It should have three commented–out lines at the top that start with `WALLTIME`, `MEM` and `DEPENDENCY`. The wall time and memory are used to schedule the job on the compute cluster. If you know that your test runs for 30 minutes, please specify about 45 minutes, i.e. don't make it too tight. Also the memory should not be too tight. If you are not sure, just specify something on the conservative side; we can always adjust it at a later moment. The dependency list can be used to search (e.g. using `grep`) and execute specific tests that relate to some FieldTrip function. If your new test script is critically dependent on some FieldTrip function, please add it to the `DEPENDENCY` list as shown in the example above for *ft_checkdata* and *ft_plot_mesh*.
