#!/bin/sh

REVISION=xxxx
USER=roboos

TRUNK=/home/coherence/roboos/tmp/fieldtrip-clean
XUNIT=/home/coherence/roboos/fieldtrip/test/matlab_xunit_3/xunit

mfilename=`basename $1 .m`
testname=`basename $1 .m`
testpath=`dirname $1`

echo creating $HOME/$mfilename.m

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
% mailto('j.schoffelen@donders.ru.nl', 'error in revision $REVISION by $USER ', msg, '/tmp/$mfilename.txt');
else
% it can be considered  not to send an email in this case
msg = sprintf('$testscript succeeded\n\nsee http://code.google.com/p/fieldtrip/source/detail?r=$REVISION and the attached file\n\n');
mailto('r.oostenveld@donders.ru.nl', 'no problem in revision $REVISION by $USER ', msg, '/tmp/$mfilename.txt');
% mailto('j.schoffelen@donders.ru.nl', 'no problem in revision $REVISION by $USER ', msg, '/tmp/$mfilename.txt');
end % if
catch
mailto('r.oostenveld@donders.ru.nl', 'failed to test revision $REVISION by $USER ', msg);
msg = sprintf('$testscript did not run properly\n\nsee http://code.google.com/p/fieldtrip/source/detail?r=$REVISION and the attached file\n\n');
end % try
exit
EOF

