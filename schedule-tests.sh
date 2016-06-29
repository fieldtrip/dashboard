#!/usr/bin/env bash
#
# This script takes a fieldtrip revision and schedules all tests that are in that revision for execution on torque.
#
# Use as
#  schedule-tests.sh <FIELDTRIPDIR> <RESULTDIR> <MATLABCMD>
#

set -u -e  # exit on error or if variable is unset

FTTESTPATH=`readlink -e $(dirname $0)`
FIELDTRIP=`readlink -e $1`
RESULTDIR=$2 

if [ "$#" -ge 3 ]; then
MATLABCMD=$3 
else
MATLABCMD="/opt/matlab/R2012b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread"
fi

if [[ $MATLABCMD == *"matlab"* ]]; then
# QSUB="qsub -q matlab"
# QSUB="qsub -q matlab -l nodes=dccn-c019.dccn.nl,nodes=dccn-c020.dccn.nl"
# QSUB="qsub -q matlab -l nodes=1:ppn=8,nodes=dccn-c006.dccn.nl,nodes=dccn-c007.dccn.nl,nodes=dccn-c019.dccn.nl,nodes=dccn-c020.dccn.nl,nodes=dccn-c021.dccn.nl,nodes=dccn-c027.dccn.nl,nodes=dccn-c028.dccn.nl,nodes=dccn-c033.dccn.nl,nodes=dccn-c034.dccn.nl"
# QSUB="qsub -q matlab -l nodes=1:ppn=8"
# QSUB="qsub -q matlab -l nodes=1:intel"
# QSUB="qsub -q matlab -l nodes=amd"
# QSUB="qsub -q matlab -l nodes=dccn-c006.dccn.nl,nodes=nodes=dccn-c007.dccn.nl,nodes=dccn-c019.dccn.nl,nodes=dccn-c021.dccn.nl,nodes=dccn-c027.dccn.nl,nodes=dccn-c028.dccn.nl,nodes=dccn-c033.dccn.nl,nodes=dccn-c034.dccn.nl"
QSUB="qsub -q matlab -l nodes=1:ppn=8"
elif [[ $MATLABCMD == *"octave"* ]]; then
QSUB="qsub -q batch"
else
>&2 echo Error: unknown MATLABCMD $MATLABCMD
fi


mkdir -p $RESULTDIR

for TEST in `find $FIELDTRIP -path "*test/test*.m"` ; do

  echo $TEST
  # this should be formatted in the matlab files as
  # % WALLTIME 4:00:00
  # % MEM 1gb
  WALLTIME=`grep WALLTIME $TEST | cut -d ' ' -f 3`
  MEM=`grep MEM $TEST | cut -d ' ' -f 3`

  # set a loose mem and walltime if the matlab files do not specify them
  if [ -z "$WALLTIME" ] ; then WALLTIME="23:59:00" ; fi
  if [ -z "$MEM" ] ; then MEM="16gb" ; fi

  # temporary override
  WALLTIME=23:59:00
  # MEM=8gb

  # Create temp file for job submission with so-called "here document":
  TMP=`mktemp $HOME/fieldtrip/dashboard/tmp/test_XXXXXXXX.sh`
  # ---------------------------------------------------------------------------
  cat > $TMP <<EOF
#!/usr/bin/env bash
$FTTESTPATH/run-test.sh $FIELDTRIP $TEST $MATLABCMD
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
