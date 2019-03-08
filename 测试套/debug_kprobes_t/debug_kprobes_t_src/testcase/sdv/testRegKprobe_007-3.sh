#!/bin/bash

. conf.sh

KO=testRegKprobe_007-3.ko
grep_dmesg1="register_kprobe pass"
echo_mesg1="register_kprobe failed!"

set_up
insmod_success testKprobes_008-A.ko || exit 1
insmod_success $KO || exit 1

if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1
rmmod_ko testKprobes_008-A.ko || exit 1

exit 0
