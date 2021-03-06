#!/usr/bin/env bash
#
# This script checks whether all tests passed in the latest batch,
# and then merges the master with the release branch.
#
# Use as
#   run-release.sh
# to check and merge the latest revision that was executed, or
#   run-release.sh <REVISION>
# for a specific revision.
#
# This script is scheduled for execution on the torque cluster by schedule-batch.sh
#

# make it robust for running as a cron job
GREP=/usr/bin/grep
AWK=/usr/bin/awk
LS=/usr/bin/ls
GIT=/usr/bin/git
MAIL=/usr/bin/mail

# ensure that other team members can read the results
umask 0022

TRUNK=$HOME/fieldtrip/release/fieldtrip
DASHBOARDDIR=$HOME/fieldtrip/dashboard

REVISION=$1

if [ -z "$REVISION" ] ; then
# determine the revision of the latest version that ran
REVISION=$(cat $DASHBOARDDIR/logs/latest/revision)
fi

# stop here if the revision cannot be determined
[ -z "$REVISION" ] && exit 1

LOGDIR=$DASHBOARDDIR/logs/$REVISION
BRANCH=$(cat $LOGDIR/branch)
FAILED=$($GREP FAILED $LOGDIR/*.txt | wc -l)
PASSED=$($GREP PASSED $LOGDIR/*.txt | wc -l)

# execute grep one directory up from the actual revision results, this includes the revision in the email body
# cd $LOGDIR/..
# $GREP FAILED $REVISION/*.txt | $MAIL -r r.oostenveld@donders.ru.nl -s "FAILED tests in latest FieldTrip batch" r.oostenveld@donders.ru.nl
# $GREP PASSED $REVISION/*.txt | $MAIL -r r.oostenveld@donders.ru.nl -s "PASSED tests in latest FieldTrip batch" r.oostenveld@donders.ru.nl

if [ "$BRANCH" == "master" ]; then
if [ $FAILED -eq 0 ]; then
if [ $PASSED -gt 600 ]; then

echo merging $LATEST into release

cd $TRUNK && $GIT checkout master && $GIT pull upstream master && $GIT checkout release
$GIT log -1 $REVISION || exit 1
$GIT merge $REVISION
$GIT push upstream release

fi
fi
fi

