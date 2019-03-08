#!/bin/sh

#================================
#1002 ???????????????
#1003 ????????????????rm??????????????anic??
#1011 ??????????????????????????
#1013 ???????????anic???
#2002 ?????????????????
#2003 ????????????????rm??????????????anic??
#2011 ??????????EUR?????????????????
#2013 ???????????anic
#3001 ???????????oftlockup
#3002 ???2?$?????EUR????????pu R???)
#3003 ??EUR??????EUR????
#================================

basedir=$(cd `dirname $0`;pwd)
topdir=$(cd `dirname $0`;cd ../../;pwd)
source $topdir/config/hi1213_arm64le.conf

testcases="1002 1011 1013 2002 2011 2013 3001 3002 3003"
for testcase in $testcases
do
    logfile=$basedir/run.log.kpgen.$testcase
    rm -rf $logfile
    echo "testcase begin: $(date)" >> $logfile
    sh $basedir/kdump_kpgen.sh $testcase >> $logfile 2>&1
    echo "testcase finish: $(date)" >> $logfile
    sleep 30
done
echo "testcases finish, logs are all in $basedir"
