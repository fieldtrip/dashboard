#!/bin/sh

cd $HOME/fieldtrip/dashboard || exit

REVISION=`ls -d logs/r????? | tail -n 1 | cut -d / -f 2`
echo $REVISION
mkdir -p history
rm -f history/*.txt
grep -l FAILED logs/$REVISION/* | cut -d / -f 3 > failed.txt
for file in `cat failed.txt` ; do grep 'PASSED\|FAILED' logs/r10???/$file > history/$file ; done
