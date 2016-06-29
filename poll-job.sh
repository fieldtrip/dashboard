#!/usr/bin/env bash
set -u -e  # exit on error or if variable is unset
FTTESTPATH=`readlink -e $(dirname $0)`
REVPREFIX="r"
LOGPATH=$FTTESTPATH/logs
REVPATH=$FTTESTPATH/revs
LOCALCOPY=$FTTESTPATH/trunk
NBACK=3
HISTFILE=$FTTESTPATH/tested.txt

# initialize files if needed
touch $HISTFILE
mkdir -p $LOGPATH $REVPATH

# First, cleanup by removing revisions older than a one day:
echo Finding old checkouts to remove...
OLDREVS=`find $REVPATH -maxdepth 1 -type d  -ctime +0 -name "$REVPREFIX*"`
echo Removing $OLDREVS...
rm -rf $OLDREVS

# find latest revision
echo Getting latest revision...
pushd $LOCALCOPY >/dev/null
svn update
head=`svn info | grep Revision | cut -d ' ' -f 2`
popd >/dev/null

# find untested revision
for rev in $(eval echo "{$head..$[$head - $NBACK + 1]}"); do
  echo Probing revision $rev...
  revdir=$REVPATH/$REVPREFIX$rev
  logdir=$LOGPATH/$REVPREFIX$rev

  if ! (grep -q $rev $HISTFILE); then
    echo Revision $rev has not been tested.

    # remove dirs in case of error
    trap "echo Snap :\(; rm -rf $revdir $logdir; exit 1" ERR  
    mkdir -p $logdir

    # create cheap checkout (this should be necessary, see git-svn)
    echo Emulating fresh checkout in $revdir...
    rm -rf $revdir
    cp -rl $LOCALCOPY $revdir
    pushd $revdir >/dev/null
    svn update -r $rev
    popd >/dev/null

    # schedule tests
    echo Scheduling tests...
    $FTTESTPATH/schedule-tests.sh $revdir $logdir

    # record scheduling of tests for this revision
    echo $rev >> $HISTFILE
    exit 0
  fi
done
echo No revisions found for testing.
