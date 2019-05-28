#!/usr/bin/env bash
#
# This job should run as the last one of the complete batch to summarise the results
#

REVISION=$1
LOGDIR=$2

# make it robust for running as a cron job
GREP=/usr/bin/grep
AWK=/usr/bin/awk
LS=/usr/bin/ls

# run this one directory up from the actual revision results
# this includes the revision in the email
cd $LOGDIR/..
$GREP FAILED $REVISION/*.txt | mail -r r.oostenveld@donders.ru.nl -s "FAILED test in latest FieldTrip batch" r.oostenveld@donders.ru.nl

