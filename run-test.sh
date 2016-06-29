#!/usr/bin/env bash
#
# Use as
#  run-test.sh  <fieldtripdir> <testscript>
#
# The output of this script is captured and displayed on the wiki

set -u -e  # exit on error or if variable is unset
FIELDTRIP=`readlink -f $1`
TESTFILE=`readlink -f $2`

MATLAB="/opt/matlab2011b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread"
MATLAB="/opt/cluster/matlab2012a -nodesktop -nosplash -nodisplay"
XUNIT=`readlink -f /home/common/matlab/xunit`

TEST=`basename $TESTFILE .m`
TESTDIR=`dirname $TESTFILE`
TEMPFILE=`mktemp -t ft_test_runner_XXXX`.m  # needs to be valid MATLAB function name.

# Create temporary m-file in-line, using what is called an 'here document' in
# Bash:
cat > $TEMPFILE <<EOF
%-------------------------------------------------------------------------------
% This is an automatically generated m-file to run a specific test. It would
% seem obvious to directly run a command in matlab with 'matlab -r "eval(...)',
% but non-trivial commands don't seem to survive the transition to MATLAB
% (another bug?).

try
  restoredefaultpath;
  addpath $XUNIT; % for running and discovering unit tests.
  addpath $FIELDTRIP; 
  ft_defaults; which ft_defaults
  global ft_default; ft_default = [];

  cd $TESTDIR;
  runtests $TEST;
catch err
  err
end

% path % display path for debugging purposes --- can be enabled.
exit;
%-------------------------------------------------------------------------------
EOF

echo "<code>"  # for DocuWiki formatting
(cd $TESTDIR; svn info)
cd $(dirname $TEMPFILE)
# all output of this script is captured in the log message
# cat ${TEMPFILE}

MFUN=${TEMPFILE##*/}  # remove dir
MFUN=${MFUN%.*}   # remove extension
$MATLAB -r $MFUN

echo "</code>"  # for DocuWiki formatting
rm $TEMPFILE
