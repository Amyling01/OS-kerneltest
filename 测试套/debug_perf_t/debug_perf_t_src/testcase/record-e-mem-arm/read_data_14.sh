#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: read_data_14.sh
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.not support -e mem:0x$addr:r8 now
##- @Brief: functions for perf record -e mem test
##- @Detail: 
#######################################################################*/
source ./record-e-mem_common.sh
source ./record-e-mem_common.sh
exit_if_not_support

func=./read_data_14
variable=read_data2
addr=`readelf $func -a|grep $variable|awk '{print $2}'`
echo 0x$addr

perf record -e mem:0x$addr:r8 -f $func 1
perf report|grep memval
if [ $? -ne 0 ];then
	{
		echo perf read val error
		exit 1
	}
else
	{
		echo "test passed"
		exit 0
	}
fi
perf report|grep memblock
if [ $? -ne 0 ];then
	{
		echo perf read val error
		exit 1
	}
else
	{
		echo "test passed"
		exit 0
	}
fi
