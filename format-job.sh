#!/usr/bin/env bash
#
# this script converts the test results into a text file and sends it to the wiki
#

set -e -u
FTTESTPATH=`readlink -e $(dirname $0)`
LOGPATH=$FTTESTPATH/logs
DASHBOARDDIR=~/public/dashboard

mkdir -p $DASHBOARDDIR/dashboard
cd $DASHBOARDDIR;
$FTTESTPATH/format-report.py    $LOGPATH/*.pickle > report.txt
$FTTESTPATH/format-report.py -w $LOGPATH/*.pickle > dashboard.txt

# Move latest log dirs to dashboard dir
find $LOGPATH -maxdepth 1 -name "r*" -type d \
  | sort | tail -n 5 | \
  xargs -I {} cp -r {} $DASHBOARDDIR/dashboard

# Make dashboard readable
chmod -R +rX dashboard*

# Clean up dashboard dir
find $DASHBOARDDIR/dashboard -maxdepth 1 -name "r*" | sort | head -n -5 | \
  xargs -I {} rm -r {}

rsync -arpv --delete $DASHBOARDDIR/dashboard* roboos@fieldtrip:/var/www/fieldtrip.fcdonders.nl/data/pages/development/

