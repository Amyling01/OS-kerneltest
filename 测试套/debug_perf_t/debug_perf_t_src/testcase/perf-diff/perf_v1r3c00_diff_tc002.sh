#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2014-09-04 15:41
# 
# Filename: perf_v1r3c00_diff_tc002.sh
# 
# Description: ����perf diff DataFileName1 DataFileName2
#	1. ����exe1��exe2�ֱ�ʹ��perf record -a -o $output�ɼ�����
#   2. �ֱ��Ӧ����exe1.data��exe2.data
#   3. ʹ��perf diff exe1.data exe2.data����perf-diff-report
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
	EXE1=tc_perf_diff_01
	EXE2=tc_perf_diff_02
	TDIR=./
	OUTFILE=$TDIR/perf-diff-report

	#clean all old data
	cd $TDIR
	rm -rf perf.data* 
}

dotest(){
	# sample first proc
	perf record -a -o ./${EXE1}.data ./$EXE1
	if [ $? -ne 0 ];then
		msg FAIL "perf record -a ./$EXE1 failed"
		RET=$((RET+1))
	fi

	# sample second proc
	perf record -a -o ./${EXE2}.data ./$EXE2
	if [ $? -ne 0 ];then
		msg FAIL "perf record -a ./$EXE2 failed"
		RET=$((RET+1))
	fi

	msg INFO "finish sampling"
	perf diff ./${EXE1}.data ${EXE2}.data > $OUTFILE 2>&1
	if [ $? -ne 0 ];then
		msg FAIL "perf diff failed"
		RET=$((RET+1))
	fi

	# check the diff report
	cat $OUTFILE | grep "Baseline.*Delta.*Shared\ Object.*Symbol" || RET=$((RET+1))
#	if [ `arch` != "aarch64" ];then
#		cat $OUTFILE | grep "+[[:digit:]]\{2,2\}\.[[:digit:]]\{2,2\}\%.*tc_perf_diff_02.*longa" || RET=$((RET+1))
#		cat $OUTFILE | grep "\-[[:digit:]]\{2,2\}\.[[:digit:]]\{2,2\}\%.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	else
		cat $OUTFILE | grep "+[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}\%.*tc_perf_diff_02.*longa" || RET=$((RET+1))
		cat $OUTFILE | grep "[[:digit:]]\{1,2\}\.[[:digit:]]\{1,2\}\%.*tc_perf_diff_01.*longa" || RET=$((RET+1))
#	fi
}
cleanup(){
	rm -rf $OUTFILE 
	rm -rf ./${EXE1}.data ./${EXE2}.data
}

setenv && dotest
cleanup
exit $RET
