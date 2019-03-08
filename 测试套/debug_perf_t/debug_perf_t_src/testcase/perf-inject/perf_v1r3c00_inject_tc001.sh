#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2014-09-12 21:34
# 
# Filename: perf_v1r3c00_inject_tc001.sh
# 
# Description: ����perf inject -v -b -i 
#	1. ʹ��perf record -e sched:sched_stat_sleep -e sched:sched_switch ./$exe�ɼ��¼�����
#   2. ʹ��perf inject -v -b -i perf.data -o perf.data.new��build-idע�뵽perf.data.new��
#   3. ʹ��perf diff����perf-diff-report
#   4. ���perf-diff-report����ȷ�ԣ�Ԥ������ʾ���ߵĲ�ͬ
# 
#======================================================

msg(){
	kind=$1
	shift
	echo "[$kind] $*"
}

RET=0
setenv(){
	EXE=tc_perf_inject_01
	TDIR=./
	OUTFILE=$TDIR/perf-inject-report
        PERFFILE=/tmp/perf.data
        PERFFILENEW=/tmp/perf.data.new
	#clean all old data
	cd $TDIR
	rm -rf $PERFFILE $PERFFILENEW
}

dotest(){
	#perf record 
	perf record -o $PERFFILE -e sched:sched_stat_sleep -e sched:sched_switch  ./$EXE
	if [ $? -ne 0 ];then
		msg FAIL "perf record -e sched:sched_stat_sleep -e sched:sched_switch  ./$EXE failed"
		RET=$((RET+1))
	fi

	#perf inject
	perf inject -v -b -i $PERFFILE -o $PERFFILENEW
	if [ $? -ne 0 ];then
		msg FAIL "perf inject -v -b -i perf.data -o perf.data.new failed"
		RET=$((RET+1))
	fi

	# perf inject -s 
	perf inject -v -b -s  -i $PERFFILE -o $PERFFILENEW
	if [ $? -ne 0 ];then
		msg FAIL "perf inject -v -b -s -i perf.data -o perf.data.new failed"
		RET=$((RET+1))
	fi
}
cleanup(){
	rm -rf $OUTFILE $PERFFILE $PERFFILENEW
}

setenv && dotest
cleanup
exit $RET
