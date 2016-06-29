#!/usr/bin/env bash
#
# This script creates and executes a temporary matlab script for a specific revision and specific test.
#
# Use as
#  run-test.sh <FIELDTRIPDIR> <TESTSCRIPT> <MATLABCMD>
#
# It is executed by schedule-test.sh

module load openmeeg

set -u -e  # exit on error or if variable is unset
FIELDTRIP=`readlink -f $1`
TESTSCRIPT=`readlink -f $2`

if [ "$#" -ge 3 ]; then
MATLABCMD=$3
else
MATLABCMD="/opt/matlab/R2012b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread"
fi

if [[ $MATLABCMD == *"matlab"* ]]; then
XUNIT=`readlink -f /home/common/matlab/xunit`
elif [[ $MATLABCMD == *"octave"* ]]; then
XUNIT=`readlink -f /home/mrphys/roboos/matlab/xunit-octave`
else
>&2 echo Error: unknown MATLABCMD $MATLABCMD
fi

TEST=`basename $TESTSCRIPT .m`
TESTDIR=`dirname $TESTSCRIPT`
TEMPFILE=`mktemp $HOME/fieldtrip/dashboard/tmp/test_XXXXXX.m`

# Create temporary m-file in-line, using what is called an 'here document' in bash
cat > $TEMPFILE <<EOF
%-------------------------------------------------------------------------------
% This is an automatically generated m-file to run a specific test. It would
% seem obvious to directly run a command in matlab with 'matlab -r "eval(...)',
% but non-trivial commands don't seem to survive the transition to MATLAB
% (another bug?).

try

  restoredefaultpath
  addpath $XUNIT      % for running and discovering unit tests.
  addpath $FIELDTRIP 

  ft_defaults
  which ft_defaults

  global ft_default
  ft_default = [];

  cd $TESTDIR
  runtests $TEST

catch err
  err
end

exit
%-------------------------------------------------------------------------------
EOF

echo "<code>"  # for DocuWiki formatting
# cd $TESTDIR && ( svn info || git show HEAD ) # this is needed in parse-logs.py
cd $TESTDIR && git log HEAD -n 1 
cd $(dirname $TEMPFILE)
# all output of this script is captured in the log message
# cat ${TEMPFILE}

MFUN=${TEMPFILE##*/}  # remove dir
MFUN=${MFUN%.*}       # remove extension
# $HOME/bin/shmwait 15  # start different instances 10 seconds apart

if [[ $MATLABCMD == *"matlab"* ]]; then
$MATLABCMD -r $MFUN
elif [[ $MATLABCMD == *"octave"* ]]; then
$MATLABCMD "$MFUN".m
else
>&2 echo Error: unknown MATLABCMD $MATLABCMD
fi

echo "</code>"  # for DocuWiki formatting
rm $TEMPFILE

