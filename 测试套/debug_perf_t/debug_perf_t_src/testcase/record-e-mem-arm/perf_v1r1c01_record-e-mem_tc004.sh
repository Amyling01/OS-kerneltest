#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc004.sh
##- @Author: y00197803
##- @Date: 2013-5-04
##- @Precon: 1.֧��perf����
##-          2.֧��perf���ݶϵ�
##- @Brief: perf���ݶϵ������д��ع�����֤
##- @Detail: 1.�����û�̬��������
##-          2.ִ��perf���������Գ���ı������ж�д���
##-          4.ִ��perf��report�����֤�����Ƿ񴥷�perf��¼��ص���Ϣ
##- @Expect: 1.��ַ1�Ķ������Ч
##-          2.��ַ1��д�����Ч
##-          3.��ַ1�Ŀ�ִ�м����Ч
##- @Level: Level 2
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

    cd ${TCTMP}
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    #monitor addr of read_only
    perf record -e mem:0x${addr_ro}:r3 -f ${cmd} > addr_ro_3-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_ro}:r5 -f ${cmd} > addr_ro_5-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_ro}:r6 -f ${cmd} > addr_ro_6-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_ro}:r7 -f ${cmd} > addr_ro_7-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_wo}:w3 -f ${cmd} > addr_wo_3-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_wo}:w5 -f ${cmd} > addr_wo_5-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_wo}:w6 -f ${cmd} > addr_wo_6-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_wo}:w7 -f ${cmd} > addr_wo_7-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_wo}:rw3 -f ${cmd} > addr_rw_3-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_wo}:rw5 -f ${cmd} > addr_rw_5-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_wo}:rw6 -f ${cmd} > addr_rw_6-${temp_num}.err 2>&1
    sleep 0.1
    perf record -e mem:0x${addr_wo}:rw7 -f ${cmd} > addr_rw_7-${temp_num}.err 2>&1

    filelist=`ls *.err`
    for filei in $filelist;do
        check_in_file "to list available events" $filei
    done
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
