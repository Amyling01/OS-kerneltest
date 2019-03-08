#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2014-09-12 22:05
# 
# Filename: perf_v1r3c00_bench_tc002.sh
# 
# Description: ����perf bench sched pipe
#   1. perf bench sched pipe -l 1000 �����ں˹ܵ�����
#   2. ������ܱ����Ƿ���ȷ
# 
#======================================================

msg(){
	kind=$1
	shift
	echo "[$kind] $*"
}

RET=0
setenv(){
	EXE=
	TDIR=./
	OUTFILE=$TDIR/perf-bench-report

	#clean all old data
	cd $TDIR
	rm -rf perf.data* 
}

dotest(){
	#perf bench 
	perf bench sched pipe -l 1000 > $OUTFILE 2>&1
	if [ $? -ne 0 ];then
		msg FAIL "perf bench sched pipe -l 1000 failed"
		RET=$((RET+1))
	fi

	#check bench report
	cat $OUTFILE | grep "sched/pipe" || RET=$((RET+1))
	cat $OUTFILE | grep "/op" || RET=$((RET+1))
	cat $OUTFILE | grep "ops/" || RET=$((RET+1))
	cat $OUTFILE | grep "Total time.*[[:digit:]].*[sec]" || RET=$((RET+1))
	if [ $RET -ne 0 ];then
		msg FAIL "check bench report failed"
	fi
}
cleanup(){
	rm -rf $OUTFILE perf.data*
}

setenv && dotest
cleanup
exit $RET
