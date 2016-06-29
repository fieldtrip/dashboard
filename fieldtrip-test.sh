#!/bin/sh

TEST=$HOME/fieldtrip/test
XUNIT=$HOME/fieldtrip/test/matlab_xunit_3/xunit
TRUNK=$HOME/fieldtrip/release/trunk

CHANGELIST=`mktemp`
TESTLIST=`mktemp`

cd $TRUNK && svn update
if [ -n "$1" ]; then
REVISION=$1
else
SVNINFO=`mktemp`
svn info -r HEAD > $SVNINFO
REVISION=`awk '/^Revision/ {print $2}' $SVNINFO`
fi

if [ -f "$TEST"/revision/"$REVISION" ] ; then
echo revision is known, aborting
exit
fi

svn info -r $REVISION    > $TEST/revision/$REVISION
svn -v log -r $REVISION >> $TEST/revision/$REVISION
cd $TEST

# compile all changed files
awk '/ *M/ {print $2}' $TEST/revision/$REVISION > $CHANGELIST

# compile all test scripts
find $TRUNK -name test\*.m > $TESTLIST

# compare the changed files against the test scripts
for change     in `cat $CHANGELIST`; do
for testscript in `cat $TESTLIST`; do
change=`basename $change .m`
if ( grep -q "TEST.*$change" $testscript ); then
echo TEST $testscript >> $TEST/revision/$REVISION 
fi
done
done

# update the test list
awk '/^TEST/ {print $2}' $TEST/revision/$REVISION > $TESTLIST
USER=`awk '/^Last Changed Author/ {print $4}' $TEST/revision/$REVISION`

for testscript in `cat $TESTLIST`; do
testpath=`dirname $testscript`
testname=`basename $testscript .m`
mfilename=rev"$REVISION"_"$testname"

# construct the MATLAB script
cat > $HOME/$mfilename.m << EOF
try
restoredefaultpath
clear variables
clear functions
clear global
addpath $TRUNK
addpath $XUNIT
ft_defaults
prevpath = pwd;
cd $testpath
delete /tmp/$mfilename.txt
diary /tmp/$mfilename.txt
retval = runtests('$testname');
diary off
cd(prevpath);
if retval==false
msg = sprintf('$testscript failed\n\nsee http://code.google.com/p/fieldtrip/source/detail?r=$REVISION and the attached file\n\n');
mailto('r.oostenveld@donders.ru.nl', 'error in revision $REVISION by $USER ', msg, '/tmp/$mfilename.txt');
else
% it can be considered  not to send an email in this case
msg = sprintf('$testscript succeeded\n\nsee http://code.google.com/p/fieldtrip/source/detail?r=$REVISION and the attached file\n\n');
mailto('r.oostenveld@donders.ru.nl', 'no problem in revision $REVISION by $USER ', msg, '/tmp/$mfilename.txt');
end % if
catch
mailto('r.oostenveld@donders.ru.nl', 'failed to test revision $REVISION by $USER ', msg);
msg = sprintf('$testscript did not run properly\n\nsee http://code.google.com/p/fieldtrip/source/detail?r=$REVISION and the attached file\n\n');
end % try
exit
EOF

# schedule the MATLAB script for execution
# cd $HOME
# qsub -q short << EOF
# matlab2010b -nojvm -nosplash -nodisplay -r $mfilename
# EOF

done
