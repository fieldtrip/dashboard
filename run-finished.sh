#!/usr/bin/env bash
#
# This job should be scheduled as the final job to summarize the results of the batch
#
# This script is scheduled for execution on the torque cluster by schedule-batch.sh
#

REVISION=$1
DASHBOARDDIR=$(dirname $(readlink -f $0))
LOGDIR=$DASHBOARDDIR/logs/$REVISION

# make it robust for running as a cron job
GREP=/usr/bin/grep
AWK=/usr/bin/awk
LS=/usr/bin/ls

# execute grep one directory up from the actual revision results
# this includes the revision in the email body
cd $LOGDIR/..
$GREP FAILED $REVISION/*.txt | mail -r r.oostenveld@donders.ru.nl -s "FAILED tests in latest FieldTrip batch" r.oostenveld@donders.ru.nl
$GREP PASSED $REVISION/*.txt | mail -r r.oostenveld@donders.ru.nl -s "PASSED tests in latest FieldTrip batch" r.oostenveld@donders.ru.nl