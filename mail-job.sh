#!/usr/bin/env bash

# the following line caused the script to fail (jan 2013), so disable
# set -e -u

DASHBOARDDIR=$HOME/public/dashboard

# sort -k3 $DASHBOARDDIR/report.txt | grep -v passed | \
#   mail -s "FieldTrip dashboard errors `date +%F`" \
#   fieldtrip-bugs@science.ru.nl \
#   -- -f r.oostenveld@donders.ru.nl

cd $DASHBOARDDIR

# files to use
REPORT=report.txt
REPORT_PREV=previous_report.txt
EMAIL=dashboardemail.txt
SUBJECT=dashboardemail_subject.txt

# get passed/failed/unknown for the two reports, store in temp files for manipulation later
FAILED=$(mktemp)
cat $REPORT | awk '{if ($4=="failed" || $3=="failed") print $2;}' >$FAILED
FAILED_PREV=$(mktemp)
cat $REPORT_PREV | awk '{if ($4=="failed" || $3=="failed") print $2;}' >$FAILED_PREV
PASSED=$(mktemp)
cat $REPORT | awk '{if ($4=="passed" || $3=="passed") print $2;}' >$PASSED
PASSED_PREV=$(mktemp)
cat $REPORT_PREV | awk '{if ($4=="passed" || $3=="passed") print $2;}' >$PASSED_PREV
UNKNOWN=$(mktemp)
cat $REPORT | awk '{if ($4=="unknown" || $3=="unknown") print $2;}' >$UNKNOWN
UNKNOWN_PREV=$(mktemp)
cat $REPORT_PREV | awk '{if ($4=="unknown" || $3=="unknown") print $2;}' >$UNKNOWN_PREV

# get differences
FAILED_NEW=$(cat $FAILED | grep -xvF -f $FAILED_PREV)
PASSED_NEW=$(cat $PASSED | grep -xvF -f $PASSED_PREV)
UNKNOWN_NEW=$(cat $UNKNOWN | grep -xvF -f $UNKNOWN_PREV)

# output e-mail
echo -e "See http://fieldtrip.fcdonders.nl/development/dashboard for details.\n" >$EMAIL
if [[ -n $FAILED_NEW ]]
then
	echo "The following tests have started failing since the last e-mail:" >>$EMAIL
	for f in $FAILED_NEW
	do
		echo "  $f" >>$EMAIL
	done
else
	echo "No tests have started failing since the last e-mail." >>$EMAIL
fi
echo >>$EMAIL

if [[ -n $PASSED_NEW ]]
then
	echo "The following tests have started passing since the last e-mail (well done!):" >>$EMAIL
	for f in $PASSED_NEW
	do
		echo "  $f" >>$EMAIL
	done
else
	echo "No tests have started passing since the last e-mail." >>$EMAIL
fi
echo >>$EMAIL

if [[ -n $UNKNOWN_NEW ]]
then
	echo "The following tests have gotten an unknown status since the last e-mail:" >>$EMAIL
	for f in $UNKNOWN_NEW
	do
		echo "  $f" >>$EMAIL
		echo >>$EMAIL
	done
fi

FAILED_ITEMS=$(cat $FAILED)
if [[ -n $FAILED_ITEMS ]]
then
	echo "Complete list of currently failing test scripts:" >>$EMAIL
	for f in $FAILED_ITEMS
	do
		echo "  $f" >>$EMAIL
	done
else
	echo "No tests are failing! Awesome." >>$EMAIL
fi
echo >>$EMAIL

UNKNOWN_ITEMS=$(cat $UNKNOWN)
if [[ -n $UNKNOWN_ITEMS ]]
then
	echo "Complete list of test scripts with currently unknown status:" >>$EMAIL
	for f in $UNKNOWN_ITEMS
	do
		echo "  $f" >>$EMAIL
	done
fi
echo >>$EMAIL

# generate subject line
SUBJECT="Dashboard: +$(echo $FAILED_NEW | wc -w) fails / +$(echo $PASSED_NEW | wc -w) passes; $(echo $FAILED_ITEMS | wc -w) total fails"

cat $EMAIL | mail -r r.oostenveld@donders.ru.nl -s "$SUBJECT" fieldtrip-bugs@science.ru.nl
cp $DASHBOARDDIR/report.txt  $DASHBOARDDIR/previous_report.txt

