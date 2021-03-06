#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505 # 
# Last modified: 2014-05-22 17:13
# 
# Filename: perf_v1r3c00_addsymbol_tc005.sh
# 
# Description:  perf -S功能，text_load_addr地址是有效10进制/16进制地址
#   1. 启动无符号的（strip）二进制可执行文件启动进程
#   2. 进程中调用另一模块的函数wrap_calc()
#   3. 在wrap_calc中调用另一模块的其他三个函数func_a,func_b,func_c
#   4. 获取进程线程tid
#   5. 使用perf record -t TID -S  obj.o,起始地址/中间地址/靠后地址,len 对进程采集数据
#   6. 使用perf report查看性能报告
#   7. 检查报告中是否包含func_a,func_b,func_c这三个符号
# 
#======================================================


source ./perf_addsymbol_conf
RET=0
exe=tc_obj_01

setenv(){
	curScriptName=${0%.*}
	reportFile=${curScriptName}.report
	[ -f ./${reportFile} ] && rm -rf ./${reportFile}

	old_pid=`ps -eo pid,comm | grep -v "grep" | grep "$exe" | awk '{print $1}'`
	[ "x$old_pid" != "x" ] && kill_proc $old_pid

	./$exe &
	TID=$!
}

dotest(){
	obj_name="./tc_obj_01.o"
	start_addr_16=`cat tc_obj_01.list | grep "func_b" | awk '{print $2}'`
	size_10=10

	# 1. 起始地址
	perf record -t $TID -S $obj_name,$start_addr_16,$size_10 &
	perf_pid=$!

	#wait for sampling
	sleep 10
	kill -SIGINT $perf_pid
	sleep 2 
	ps ax |grep -v "grep" | grep "$perf_pid"
	if [ $? -eq 0 ];then
		kill -9 $perf_pid
		echo "[ERROR] terminate the perf program failed!"
		return $((RET+1))
	fi

	# get & check the report
	perf report > ./${reportFile} 2>&1
	cat ./${reportFile} | grep "func_a" && return $((RET+1))
	cat ./${reportFile} | grep "func_b" || return $((RET+1))
	cat ./${reportFile} | grep "func_c" || return $((RET+1))

	if [ $RET -eq 0 ];then
		echo "[PASS] -S $obj_name,$start_addr_16,$size_10 pass !"
	fi



}

cleanup(){
	[ -f ./${reportFile} ] && rm -rf ./${reportFile}
	[ -f perf.data ] && rm -rf perf.data*
	old_pid=`ps -eo pid,comm | grep -v "grep" | grep "$exe" | awk '{print $1}'`
	[ "x$old_pid" != "x" ] && kill_proc $old_pid
}
exit 0
setenv && dotest
RET=$?
cleanup
exit $RET
