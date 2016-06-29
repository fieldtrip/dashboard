#!/usr/bin/env bash
#
# this script gathers all test results into a pickle and a json file
#

set -e -u
FTTESTPATH=`readlink -e $(dirname $0)`
LOGPATH=$FTTESTPATH/logs
echo LOGPATH=$LOGPATH

cd $LOGPATH

# List warm (revisions that are probably being tested) and old (revisions that have been tested a while ago):
WARMREVS=`find $LOGPATH -maxdepth 1 -mindepth 1 -type d -name "r????" -ctime -1`
OLDREVS=`find $LOGPATH -maxdepth 1 -mindepth 1 -type d -name "r????" -ctime +5  | sort | head -n -5`

echo WARMREVS=$WARMREVS
echo OLDREVS=$OLDREVS

# The logs can take up quit some space; some test functions generate as much as
# 4 MB. To conserve space, we compress log file from older revisions:
for REV in $OLDREVS
do
  tar --absolute-names -czf $REV.tar.gz $REV && rm -r $REV
  # The --absolute-names is needed to suppress a warning that triggers mail.
done

# The warm revisions could still be running. We keep parsing these logs:
for REV in $WARMREVS
do
  echo Parsing $REV...
  find $REV -type f -name "*.txt" -print0 |\
      xargs -0 $FTTESTPATH/parse-logs.py -p $REV.pickle -j $REV.json
done
