#!/usr/bin/env bash
#
# This script takes a fieldtrip revision and schedules all tests that are in that revision for execution on torque.
#
# Use as
#  schedule-tests.sh <FIELDTRIPDIR> <RESULTDIR>
#

set -u -e  # exit on error or if variable is unset

FIELDTRIP=`readlink -e $1`
RESULTDIR=$2 

FTTESTPATH=`readlink -e $(dirname $0)`

QSUB="qsub -q matlab -l nodes=1:intel"

mkdir -p $RESULTDIR

for TEST in `find $FIELDTRIP -path "*test/test*.m"` ; do

  echo $TEST
  # this should be formatted in the matlab files as
  # % WALLTIME 4:00:00
  # % MEM 1gb
  WALLTIME=`grep WALLTIME $TEST | cut -d ' ' -f 3`
  MEM=`grep MEM $TEST | cut -d ' ' -f 3`

  # set a loose mem and walltime if the matlab files do not specify them
  if [ -z "$WALLTIME" ] ; then WALLTIME="16:00:00" ; fi
  if [ -z "$MEM" ] ; then MEM="16gb" ; fi

# temporary override
# WALLTIME=16:00:00
# MEM=8gb

  # Create temp file for job submission with so-called "here document":
  TMP=`mktemp /home/mrphys/roboos/fieldtrip/dashboard/tmp/test_XXXXXXXX.sh`
  # ---------------------------------------------------------------------------
  cat > $TMP <<EOF
#!/usr/bin/env bash
$FTTESTPATH/run-test.sh $FIELDTRIP $TEST
EOF
  # ---------------------------------------------------------------------------

  # extract test name from filename
  TESTNAME=${TEST%.*}
  TESTNAME=${TESTNAME##*/}

  # run test job on Torque
  $QSUB -l walltime=$WALLTIME,mem=$MEM -N $TESTNAME -o $RESULTDIR/$TESTNAME.txt -e $RESULTDIR/$TESTNAME.err $TMP

  # remove temp file again
  rm $TMP  
done
