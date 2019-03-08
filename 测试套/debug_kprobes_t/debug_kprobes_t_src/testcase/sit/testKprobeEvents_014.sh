#!/bin/bash

ls /sys/kernel/debug/tracing > /dev/null
if [ $? -ne 0 ];then
	 mount -t debugfs nodev /sys/kernel/debug
fi

ls /sys/kernel/debug/tracing > /dev/null
if [ $? -ne 0 ];then
        echo "not support ftrace\n"
        exit 1
fi

list=`find /sys/kernel/debug/tracing/events/kprobes/ -name "enable"`
for item in $list
do
        echo 0 > $item
done
echo > /sys/kernel/debug/tracing/kprobe_events

do_fork="_do_fork"
if [ "$(uname -r)" \< "4.2" ];then
do_fork="do_fork"
fi

RET=0

for num in `seq 0 1 100`
do
	###register kprobes
	echo "p:mykprobe $do_fork" > /sys/kernel/debug/tracing/kprobe_events
	cat /sys/kernel/debug/tracing/kprobe_events | grep "p:kprobes/mykprobe $do_fork"
	if [ $? -ne 0 ];then
		echo "register kprobes fail\n"
		RET=$(($RET+1))
	fi
	echo 'r:myretprobe do_sys_open' >> /sys/kernel/debug/tracing/kprobe_events
	cat /sys/kernel/debug/tracing/kprobe_events | grep "r:kprobes/myretprobe do_sys_open"
	if [ $? -ne 0 ];then
        	echo "register kprobes fail\n"
                RET=$(($RET+1))
	fi

	###unregister kprobes
	echo > /sys/kernel/debug/tracing/kprobe_events
	ls /sys/kernel/debug/tracing/events/kprobes | grep "mykprobe" || \
	ls /sys/kernel/debug/tracing/events/kprobes | grep "myretprobe"
	if [ $? -eq 0 ];then
		echo "unregister kprobes fail\n"
                RET=$(($RET+1))
	fi
done

exit $RET

