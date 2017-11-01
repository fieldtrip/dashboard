#!/usr/bin/env bash
#
# This script takes the FieldTrip version from my home directory and runs all tests on it for different MATLAB versions.
#

FIELDTRIPDIR=$HOME/matlab/fieldtrip
REV=`cd $FIELDTRIPDIR && git rev-parse --short HEAD`
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2017b '/opt/matlab/R2017b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2017a '/opt/matlab/R2017a/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2016b '/opt/matlab/R2016b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2016a '/opt/matlab/R2016a/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2015b '/opt/matlab/R2015b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2015a '/opt/matlab/R2015a/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2014b '/opt/matlab/R2014b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2014a '/opt/matlab/R2014a/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2013b '/opt/matlab/R2013b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2013a '/opt/matlab/R2013a/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2012b '/opt/matlab/R2012b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2012a '/opt/matlab/R2012a/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2011b '/opt/matlab/R2011b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2011a '/opt/matlab/R2011a/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2010b '/opt/matlab/R2010b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2010a '/opt/matlab/R2010a/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2009b '/opt/matlab/R2009b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2009a '/opt/matlab/R2009a/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
./schedule-tests.sh ${FIELDTRIPDIR} /home/mrphys/roboos/fieldtrip/dashboard/logs/${REV}-R2008b '/opt/matlab/R2008b/bin/matlab -nodesktop -nosplash -nodisplay -singleCompThread'
