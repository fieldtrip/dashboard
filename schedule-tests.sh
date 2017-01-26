#!/usr/bin/env bash
#
# This script takes a fieldtrip revision and schedules all tests that are in that revision for execution on torque.
#
# Use as either one of these
#  schedule-tests.sh <FIELDTRIPDIR> <LOGDIR> <MATLABCMD>
#  schedule-tests.sh <FIELDTRIPDIR> <LOGDIR>
#  schedule-tests.sh <FIELDTRIPDIR>
#

set -u -e  # exit on error or if variable is unset

TEMPDIR=$HOME/`date +'%FT%H:%M:%S'`

DASHBOARDDIR=`readlink -e $(dirname $0)`
FIELDTRIPDIR=${1:-${HOME}/matlab/fieldtrip}
LOGDIR=${2:-${TEMPDIR}}

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

  # temporary override
  # WALLTIME=23:59:00
  # MEM=8gb

# Create temp file for job submission with so-called "here document":
TESTSCRIPT=`mktemp $HOME/fieldtrip/dashboard/scripts/test_XXXXXXXX.sh`
# ---------------------------------------------------------------------------
cat > $TESTSCRIPT <<EOF
#!/usr/bin/env bash
$DASHBOARDDIR/run-test.sh $FIELDTRIPDIR $TEST \'$MATLABCMD\'
EOF
# ---------------------------------------------------------------------------

  # extract test name from filename
  TESTNAME=${TEST%.*}
  TESTNAME=${TESTNAME##*/}

  # run test job on Torque
  $QSUB -l walltime=$WALLTIME,mem=$MEM -N $TESTNAME -o $LOGDIR/$TESTNAME.txt -e $LOGDIR/$TESTNAME.err $TESTSCRIPT

  # remove temp file again
  rm $TESTSCRIPT  
done

