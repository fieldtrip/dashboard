#!/usr/bin/env bash
#
# This script takes a FieldTrip revision and schedules all tests in that
# revision for execution on the torque compute cluster.
#
# Use as either one of these
#   schedule-batch.sh <FIELDTRIPDIR> <LOGDIR> <MATLABCMD>
#   schedule-batch.sh <FIELDTRIPDIR> <LOGDIR>
#   schedule-batch.sh <FIELDTRIPDIR>
#   schedule-batch.sh
#

set -u -e  # exit on error or if variable is unset

# ensure that other team members can read the results
umask 0022

DASHBOARDDIR=$(dirname $(readlink -f $0))

# load some bash helper functions
source tobytes.sh
source togb.sh
source toseconds.sh
source tohms.sh

# this overhead is added to the job requirements
MEMOVERHEAD=2000000000
WALLTIMEOVERHEAD=1800

if [ "$#" -ge 1 ]; then
FIELDTRIPDIR=$1
else
FIELDTRIPDIR=$HOME/matlab/fieldtrip
fi

REVISION=$(cd $FIELDTRIPDIR && git rev-parse --short HEAD)
BRANCH=$(cd $FIELDTRIPDIR && git rev-parse --abbrev-ref HEAD)

if [ "$#" -ge 2 ]; then
LOGDIR=$2
else
LOGDIR=$DASHBOARDDIR/logs/$REVISION
(cd $DASHBOARDDIR/logs && rm -rf latest && ln -s $REVISION latest)
fi

if [ "$#" -ge 3 ]; then
MATLABCMD=$3
else
MATLABCMD="/opt/matlab/R2018b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread"
fi

if [[ $MATLABCMD == *"matlab"* ]]; then
QSUB="$HOME/bin/qsub -q matlab"
# QSUB="qsub -q matlab"
# QSUB="qsub -q matlab -l nodes=dccn-c019.dccn.nl,nodes=dccn-c020.dccn.nl"
# QSUB="qsub -q matlab -l nodes=1:ppn=8,nodes=dccn-c006.dccn.nl,nodes=dccn-c007.dccn.nl,nodes=dccn-c019.dccn.nl,nodes=dccn-c020.dccn.nl,nodes=dccn-c021.dccn.nl,nodes=dccn-c027.dccn.nl,nodes=dccn-c028.dccn.nl,nodes=dccn-c033.dccn.nl,nodes=dccn-c034.dccn.nl"
# QSUB="qsub -q matlab -l nodes=1:ppn=8"
# QSUB="qsub -q matlab -l nodes=1:intel"
# QSUB="qsub -q matlab -l nodes=amd"
# QSUB="qsub -q matlab -l nodes=dccn-c006.dccn.nl,nodes=nodes=dccn-c007.dccn.nl,nodes=dccn-c019.dccn.nl,nodes=dccn-c021.dccn.nl,nodes=dccn-c027.dccn.nl,nodes=dccn-c028.dccn.nl,nodes=dccn-c033.dccn.nl,nodes=dccn-c034.dccn.nl"
# QSUB="qsub -q matlab -l nodes=1:ppn=8"
elif [[ $MATLABCMD == *"octave"* ]]; then
QSUB="qsub -q batch"
else
>&2 echo Error: unknown MATLABCMD $MATLABCMD
fi

mkdir -p $LOGDIR
echo $BRANCH   > $LOGDIR/branch
echo $REVISION > $LOGDIR/revision

# keep track of all the jobs that are in this batch
rm -rf $LOGDIR/batch

for TEST in `find $FIELDTRIPDIR -path "*test/test_*.m"` ; do

  # this should be formatted in the matlab files as
  # % WALLTIME 4:00:00
  # % MEM 1gb
  WALLTIME=`grep WALLTIME $TEST | cut -d ' ' -f 3`
  MEM=`grep MEM $TEST | cut -d ' ' -f 3`

  # set the mem and walltime if the matlab files do not specify them
  if [ -z "$WALLTIME" ] ; then WALLTIME="12:00:00" ; fi
  if [ -z "$MEM" ] ; then MEM="16gb" ; fi

  WALLTIME=$( toseconds $WALLTIME )
  WALLTIME=$(( $WALLTIME + $WALLTIMEOVERHEAD ))
  WALLTIME=$( tohms $WALLTIME )

  MEM=$( tobytes $MEM )
  MEM=$(( $MEM + $MEMOVERHEAD ))
  MEM=$( togb $MEM )

  # the following lines allow for a temporary override
  # WALLTIME=23:59:00
  # MEM=16gb

# Create temp file for job submission with so-called "here document":
BASHSCRIPT=`mktemp $LOGDIR/test_XXXXXXXX.sh`
# ---------------------------------------------------------------------------
cat > $BASHSCRIPT <<EOF
#!/usr/bin/env bash
#
% This BASH script will be automatically removed when the job has been scheduled.
#
# The script to start MATLAB and execute the specific test should be called as
#   run-test.sh <TESTSCRIPT> <FIELDTRIPDIR> <LOGDIR> <MATLABCMD>
#
$DASHBOARDDIR/run-test.sh $TEST $FIELDTRIPDIR $LOGDIR \'$MATLABCMD\'
EOF
# ---------------------------------------------------------------------------

  # extract test name from filename
  TESTNAME=${TEST%.*}
  TESTNAME=${TESTNAME##*/}

  # run test job on Torque
  job=$($QSUB -h -l walltime=$WALLTIME,mem=$MEM -N $TESTNAME -o $LOGDIR/$TESTNAME.txt -e $LOGDIR/$TESTNAME.err $BASHSCRIPT)
  echo $job >> $LOGDIR/batch

  # remove temp file again
  rm $BASHSCRIPT
done

# Create temp file for job submission with so-called "here document":
BASHSCRIPT=`mktemp $LOGDIR/test_XXXXXXXX.sh`
DEPEND=`paste -s -d : $LOGDIR/batch`
# ---------------------------------------------------------------------------
cat > $BASHSCRIPT <<EOF
#!/usr/bin/env bash
#
#PBS -l mem=250mb,walltime=00:10:00
#PBS -W depend=afterany:$DEPEND
#PBS -N run-release
#PBS -o $LOGDIR/run-release.txt -e $LOGDIR/run-release.err

$DASHBOARDDIR/run-release.sh $REVISION
EOF
# ---------------------------------------------------------------------------
$QSUB $BASHSCRIPT || echo FAILED to submit run-release
rm $BASHSCRIPT

for job in `cat $LOGDIR/batch` ; do qrls $job ; done

