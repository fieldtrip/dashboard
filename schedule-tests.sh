#!/usr/bin/env bash
# Arguments FIELDTRIPDIR RESULTDIR
set -u -e  # exit on error or if variable is unset
QSUB="qsub -q matlab -l walltime=4:00:00,mem=6gb"

FIELDTRIP=`readlink -e $1`
RESULTDIR=$2 

FTTESTPATH=`readlink -e $(dirname $0)`

mkdir -p $RESULTDIR

for TEST in `find $FIELDTRIP -path "*test/test*.m"` ; do
  # Create temp file for job submission with so-called "here document":
  TMP=`mktemp`
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
  # cat $TMP
  $QSUB -N $TESTNAME \
    -o $RESULTDIR/$TESTNAME.txt -e $RESULTDIR/$TESTNAME.err \
    $TMP

  # remove temp file again
  rm $TMP  
done
