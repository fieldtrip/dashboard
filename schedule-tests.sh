#!/usr/bin/env bash
#
# This script takes a FieldTrip revision and schedules all tests in that
# revision for execution on the torque compute cluster.
#
# Use as either one of these
#   schedule-tests.sh <FIELDTRIPDIR> <LOGDIR> <MATLABCMD>
#   schedule-tests.sh <FIELDTRIPDIR> <LOGDIR>
#   schedule-tests.sh <FIELDTRIPDIR>
#

set -u -e  # exit on error or if variable is unset

if [ "$#" -ge 1 ]; then
FIELDTRIPDIR=$1
else
FIELDTRIPDIR=$HOME/matlab/fieldtrip
fi

if [ "$#" -ge 2 ]; then
LOGDIR=$2
else
LOGDIR=$HOME/`date +'%FT%H:%M:%S'`
fi

if [ "$#" -ge 3 ]; then
MATLABCMD=$3 
else
MATLABCMD="/opt/matlab/R2016b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread"
fi

if [[ $MATLABCMD == *"matlab"* ]]; then
QSUB="qsub -q matlab"
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

DASHBOARDDIR=$(dirname $(readlink -f $0))
mkdir -p $LOGDIR

for TEST in `find $FIELDTRIPDIR -path "*test/test_*.m"` ; do

  # this should be formatted in the matlab files as
  # % WALLTIME 4:00:00
  # % MEM 1gb
  WALLTIME=`grep WALLTIME $TEST | cut -d ' ' -f 3`
  MEM=`grep MEM $TEST | cut -d ' ' -f 3`

  # set a loose mem and walltime if the matlab files do not specify them
  if [ -z "$WALLTIME" ] ; then WALLTIME="23:59:00" ; fi
  if [ -z "$MEM" ] ; then MEM="16gb" ; fi

  # the following lines allow for a temporary override
  # WALLTIME=23:59:00
  # MEM=8gb

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
  $QSUB -l walltime=$WALLTIME,mem=$MEM -N $TESTNAME -o $LOGDIR/$TESTNAME.txt -e $LOGDIR/$TESTNAME.err $BASHSCRIPT

  # remove temp file again
  rm $BASHSCRIPT  
done

