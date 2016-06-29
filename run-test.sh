#!/usr/bin/env bash
#
# This script creates a temporary matlab script for a specific revision and specific test.
#
# Use as
#  run-test.sh  <fieldtripdir> <testscript>
#

set -u -e  # exit on error or if variable is unset
FIELDTRIP=`readlink -f $1`
TESTSCRIPT=`readlink -f $2`

LICENSE="-c $HOME/etc/matlab2012b.lic"

if [ -d /scratch/opt/matlab2012b ] ; then
MATLAB="/scratch/opt/matlab2012b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread $LICENSE"
else
#MATLAB="/opt/cluster/matlab2012b -nodesktop -nosplash -nodisplay"
MATLAB="/opt/matlab2012b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread $LICENSE"
fi

XUNIT=`readlink -f /home/common/matlab/xunit`

TEST=`basename $TESTSCRIPT .m`
TESTDIR=`dirname $TESTSCRIPT`
TEMPFILE=`mktemp $HOME/fieldtrip/dashboard/tmp/test_XXXXXX.m`

# Create temporary m-file in-line, using what is called an 'here document' in
# Bash:
cat > $TEMPFILE <<EOF
%-------------------------------------------------------------------------------
% This is an automatically generated m-file to run a specific test. It would
% seem obvious to directly run a command in matlab with 'matlab -r "eval(...)',
% but non-trivial commands don't seem to survive the transition to MATLAB
% (another bug?).

try
  [status, result] = system('date +%c\ %Z\ %s');
  fprintf('MATLAB script starts %s\n', result);

  restoredefaultpath
  addpath $XUNIT      % for running and discovering unit tests.
  addpath $FIELDTRIP 

  ft_defaults
  which ft_defaults

  global ft_default
  ft_default = [];

  memtic
  cd $TESTDIR
  runtests $TEST
  memtoc

  % display path for debugging purposes --- can be enabled.
  % path

  [status, result] = system('date +%c\ %Z\ %s');
  fprintf('MATLAB script ends %s\n', result);

catch err
  err
end

exit
%-------------------------------------------------------------------------------
EOF

echo "<code>"  # for DocuWiki formatting
cd $TESTDIR && svn info # this is needed in parse-logs.py
cd $(dirname $TEMPFILE)
# all output of this script is captured in the log message
# cat ${TEMPFILE}

MFUN=${TEMPFILE##*/}  # remove dir
MFUN=${MFUN%.*}       # remove extension
# $HOME/bin/shmwait 15  # start different instances 10 seconds apart
$MATLAB -r $MFUN

echo "</code>"  # for DocuWiki formatting
rm $TEMPFILE

