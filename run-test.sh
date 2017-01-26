#!/usr/bin/env bash
#
# This script creates and executes a temporary matlab script for a specific revision and specific test.
#
# Use as
#  run-test.sh <FIELDTRIPDIR> <TESTSCRIPT> <MATLABCMD>
#
# It is executed by schedule-test.sh

source /opt/optenv.sh
module load openmeeg

set -u -e  # exit on error or if variable is unset
FIELDTRIP=`readlink -f $1`
TEST=`readlink -f $2`

if [ "$#" -ge 3 ]; then
MATLABCMD=$3
else
MATLABCMD="/opt/matlab/R2012b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread"
fi

if [[ $MATLABCMD == *"matlab"* ]]; then
XUNIT=`readlink -f /home/common/matlab/xunit`
elif [[ $MATLABCMD == *"octave"* ]]; then
XUNIT=`readlink -f $HOME/matlab/xunit-octave`
else
>&2 echo Error: unknown MATLABCMD $MATLABCMD
fi

# the FieldTrip test script test to be executed is passed with the full path
TESTDIR=`dirname $TEST`
TESTCALL=`basename $TEST .m`

# Create temp file for job submission with so-called "here document":
TESTSCRIPT=`mktemp $HOME/fieldtrip/dashboard/scripts/test_XXXXXXXX.m`
cat > $TESTSCRIPT <<EOF
%-------------------------------------------------------------------------------
% This is an automatically generated m-file to run a specific test. It would
% seem obvious to directly run a command in matlab with 'matlab -r "eval(...)',
% but non-trivial commands don't seem to survive the transition to MATLAB
% (another bug?).

try

  restoredefaultpath
  addpath $FIELDTRIP 
  addpath $FIELDTRIP/test

  ft_defaults
  global ft_default
  ft_default = [];

  cd $TESTDIR
  ft_test run $TESTCALL

catch err
  disp(err)
end

exit
%-------------------------------------------------------------------------------
EOF

MDIR=`dirname ${TESTSCRIPT}`
MFUN=${TESTSCRIPT##*/}  # remove dir
MFUN=${MFUN%.*}         # remove extension
# $HOME/bin/shmwait 15  # start different instances 10 seconds apart

if [[ $MATLABCMD == *"matlab"* ]]; then
$MATLABCMD -r "cd $MDIR ; $MFUN"
elif [[ $MATLABCMD == *"octave"* ]]; then
$MATLABCMD ${TESTSCRIPT}
else
>&2 echo Error: unknown MATLABCMD $MATLABCMD
fi

# remove the temp file, not the actual FieldTrip test script
rm $TESTSCRIPT

