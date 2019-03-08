#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc007.sh
##- @Author: y00197803
##- @Date: 2013-5-15
##- @Precon: 1.֧��perf����
##-          2.֧��perf���ݶϵ�
##- @Brief: ��֤perf recordͬʱ���5���ϵ�(arm��x86��ֻ��4��PMU�Ĵ���)
##- @Detail: 1.�����û�̬��������
##-          2.��ر����޷���ض���4���ϵ�
##- @Expect: ��ر���
##- @Level: Level 3
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
. ${TCBIN}./record-e-mem_common.sh
######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    prepare_tmp_recordemem
    cmd="${USE_HUGE}common_record-e-mem_1"
    program=${TCBIN}./${USE_HUGE}common_record-e-mem_1
    addr_ro=`get_monitor_addr ${program} read_only`
    addr_wo=`get_monitor_addr ${program} write_only`
    addr_rw=`get_monitor_addr ${program} read_write`
    addr_write_same=`get_monitor_addr ${program} write_same`
    addr_nothing=`get_monitor_addr ${program} nothing`
    cd ${TCTMP}
}
######################################################################
##-@ Description:  main function
######################################################################
dotest()
{
    perf record -e mem:0x${addr_ro}:r -e mem:0x${addr_wo}:w -e mem:0x${addr_rw}:rw -e mem:0x${addr_nothing}:r -e mem:0x${addr_write_same}:w $cmd 2>perf_record.err
    check_ret_code $? 1
    check_in_file "perfcounter syscall returned with" perf_record.err
}

######################################################################
##-@ Description:  main function
######################################################################
cleanenv()
{
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv
