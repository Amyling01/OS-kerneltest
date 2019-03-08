#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc001.sh
##- @Author: y00197803
##- @Date: 2013-5-04
##- @Precon: 1.֧��perf����
##-          2.֧��perf���ݶϵ�
##- @Brief: perf���ݶϵ������д��ع�����֤
##- @Detail: 1.�����û�̬��������
##-          2.ִ��perf���������Գ���ı������ж�д���
##-          3.��ַ1ֻ���ж�����,��ַ2ֻ����д����,��ַ3д���ֵ��ԭֵ��ͬ,��ַ4�������κβ���,��ַ5�Ƚ��ж�����Ҳ����д����,��ַ6��ִ�е��ĺ�����ַ,��ַ7��δִ�е��ĺ�����ַ
##-          3.1��ص�ַ1�Ķ�����
##-          3.2��ص�ַ1��д����
##-          3.3��ص�ַ1�Ŀ�ִ�в���
##-          3.4��ص�ַ2�Ķ�����
##-          3.5��ص�ַ2��д����
##-          3.6��ص�ַ3��д����
##-          3.7��ص�ַ4�Ķ���д����д����
##-          3.8��ص�ַ5�Ķ�д����
##-          3.9��ص�ַ6,7�Ŀ�ִ�в���
##-          4.ִ��perf��report�����֤�����Ƿ񴥷�perf��¼��ص���Ϣ
##- @Expect: 1.��ַ1�Ķ������Ч
##-          2.��ַ1��д�����Ч
##-          3.��ַ1�Ŀ�ִ�м����Ч
##-          4.��ַ2�Ķ������Ч
##-          5.��ַ2��д�����Ч
##-          6.��ַ3��д�����Ч
##-          7.��ַ4�Ķ���д����д�����Ч
##-          8.��ַ5�Ķ�д�����Ч
##-          9.��ַ6��ִ�в�����Ч,��ַ7��ִ�в�����Ч
##-          9.������Ч�ļ�أ�perf report����������ȷ����Ч�ļ��perf report������
##- @Level: Level 1
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
    tmp_file=usr_gvar_addr.tmp
    step1=step1.tmp
    step2=step2.tmp

    # linux 3.11 delete 'perf record -f'
    # commit: 4a4d371a4dfbd3b84a7eab8d535d4c7c3647b09e
    # patch name: perf record: Remove -f/--force option
    perf_vcmp 3 11
    if [ $? -eq 1 ];then
           opt=""
    else
           opt="-f"
    fi

    cd ${TCTMP}
}

######################################################################
##- @Description: 
######################################################################
get_record_para_rw_addr()
{
    [ -e $tmp_file ] && rm -rf $tmp_file
    [ -e $step1 ] && rm -rf $step1
    [ -e $step2 ] && rm -rf $step2
    ${TCBIN}./${USE_HUGE}common_record-e-mem_3 &
    PID=$!
    cmd="-p $PID"
    while([ ! -e $step1 ])
    do
        sleep 1
    done
    addr_ro=`cat $tmp_file | sed -n '1p'`
    addr_wo=`cat $tmp_file | sed -n '2p'`
    addr_write_same=`cat $tmp_file | sed -n '3p'`
    addr_nothing=`cat $tmp_file | sed -n '4p'`
    addr_rw=`cat $tmp_file | sed -n '5p'`
    addr_func_unused=`cat $tmp_file | sed -n '6p'`
    addr_func_write=`cat $tmp_file | sed -n '7p'`
}

######################################################################
##- @Description:
######################################################################
dotest()
{
    #monitor addr of read_only
    #perf record -o addr_ro_r-${temp_num}.data -e mem:${addr_ro}:r $opt ${cmd} 2>/dev/null
    #sleep 0.1
    #perf report -i addr_ro_r-${temp_num}.data > addr_ro_r-${temp_num}.report1
    if [ ! -z "`uname -m | grep 86`" ];then
        get_record_para_rw_addr
        touch $step2
        perf record -o addr_ro_w-${temp_num}.data -e mem:${addr_ro}:w $opt ${cmd} 2>/dev/null
        sleep 1
        perf report -i addr_ro_w-${temp_num}.data > addr_ro_w-${temp_num}.report0
    fi
    get_record_para_rw_addr
    touch $step2
    perf record -o addr_ro_rw-${temp_num}.data -e mem:${addr_ro}:rw $opt ${cmd} 2>/dev/null
    sleep 1
    perf report -i addr_ro_rw-${temp_num}.data > addr_ro_rw-${temp_num}.report1
    get_record_para_rw_addr
    touch $step2
    perf record -o addr_ro_x-${temp_num}.data -e mem:${addr_ro}:x $opt ${cmd} 2>/dev/null
    sleep 1
    perf report -i addr_ro_x-${temp_num}.data > addr_ro_x-${temp_num}.report0
    #monitor addr of write_only
    #perf record -o addr_wo_r-${temp_num}.data -e mem:${addr_wo}:r $opt ${cmd} 2>/dev/null
    #sleep 0.1
    #perf report -i addr_wo_r-${temp_num}.data > addr_wo_r-${temp_num}.report0
    if [ ! -z "`uname -m | grep 86`" ];then
        get_record_para_rw_addr
        touch $step2
        perf record -o addr_wo_w-${temp_num}.data -e mem:${addr_wo}:w $opt ${cmd} 2>/dev/null
        sleep 1
        perf report -i addr_wo_w-${temp_num}.data > addr_wo_w-${temp_num}.report1
    fi
    get_record_para_rw_addr
    touch $step2
    perf record -o addr_wo_rw-${temp_num}.data -e mem:${addr_wo}:rw $opt ${cmd} 2>/dev/null
    sleep 1
    perf report -i addr_wo_rw-${temp_num}.data > addr_wo_rw-${temp_num}.report1
    #monitor addr of read_write
    get_record_para_rw_addr
    touch $step2
    perf record -o addr_rw-${temp_num}.data -e mem:${addr_rw}:rw $opt ${cmd} 2>/dev/null
    sleep 1
    perf report -i addr_rw-${temp_num}.data > addr_rw-${temp_num}.report1
    #monitor addr of write_same
    if [ ! -z "`uname -m | grep 86`" ];then
        get_record_para_rw_addr
        touch $step2
        perf record -o addr_write_same-${temp_num}.data -e mem:${addr_write_same}:w $opt ${cmd} 2>/dev/null
        sleep 1
        perf report -i addr_write_same-${temp_num}.data > addr_write_same-${temp_num}.report1
    fi
    #monitor addr of nothing
    #perf record -o nothing_r-${temp_num}.data -e mem:${addr_nothing}:r $opt ${cmd} 2>/dev/null
    #sleep 0.1
    #perf report -i nothing_r-${temp_num}.data > nothing_r-${temp_num}.report0
    if [ ! -z "`uname -m | grep 86`" ];then
	get_record_para_rw_addr
        touch $step2
        perf record -o nothing_w-${temp_num}.data -e mem:${addr_nothing}:w $opt ${cmd} 2>/dev/null
        sleep 1
        perf report -i nothing_w-${temp_num}.data > nothing_w-${temp_num}.report0
    fi
    get_record_para_rw_addr
    touch $step2
    perf record -o nothing_rw-${temp_num}.data -e mem:${addr_nothing}:rw $opt ${cmd} 2>/dev/null
    sleep 1
    perf report -i nothing_rw-${temp_num}.data > nothing_rw-${temp_num}.report0
    #monitor addr of func_do_write
    get_record_para_rw_addr
    touch $step2
    perf record -o addr_func_write-${temp_num}.data -e mem:${addr_func_write}:x $opt ${cmd} 2>/dev/null
    sleep 1
    perf report -i addr_func_write-${temp_num}.data > addr_func_write-${temp_num}.report1
    #monitor addr of func_unused
    get_record_para_rw_addr
    touch $step2
    perf record -o addr_func_unused-${temp_num}.data -e mem:${addr_func_unused}:x $opt ${cmd} 2>/dev/null
    sleep 1
    perf report -i addr_func_unused-${temp_num}.data > addr_func_unused-${temp_num}.report0

    #check report files have content
    has_content `ls *.report1`

    check_val_read=`get_check_val 00 00 00 0${DEF_VAL_INT}`
    check_val_write=`get_check_val 00 00 00 0${W_VAL_INT}`
    #check addr:r of read_only
    #check_in_file "memval:   0x${DEF_VAL_INT}" addr_ro_r-${temp_num}.report1
    #check_in_file "memblock" addr_ro_r-${temp_num}.report1
    #check_in_file "===> ${addr_ro}: $check_val_read" addr_ro_r-${temp_num}.report1
    #check addr:rw of read_only
    check_in_file "Samples: 1" addr_ro_rw-${temp_num}.report1
    check_in_file "func_do_read" addr_ro_rw-${temp_num}.report1
    check_in_file "Event" addr_ro_rw-${temp_num}.report1
    #check addr:w of write_only
    if [ ! -z "`uname -m | grep 86`" ];then
        check_in_file "Samples: 1" addr_wo_w-${temp_num}.report1
        check_in_file "func_do_write" addr_wo_w-${temp_num}.report1
        check_in_file "Event" addr_wo_w-${temp_num}.report1
    fi
    #check addr:rw of write_only
    check_in_file "Samples: 1" addr_wo_rw-${temp_num}.report1
    check_in_file "func_do_write" addr_wo_rw-${temp_num}.report1
    check_in_file "Event" addr_wo_rw-${temp_num}.report1
    #check addr:w of read_write
    check_in_file "Samples: 2" addr_rw-${temp_num}.report1
    check_in_file "func_do_write" addr_rw-${temp_num}.report1
    check_in_file "func_do_read" addr_rw-${temp_num}.report1
    check_in_file "Event" addr_rw-${temp_num}.report1
    #check addr:w of write_same
    if [ ! -z "`uname -m | grep 86`" ];then
        check_in_file "Samples: 1" addr_write_same-${temp_num}.report1
        check_in_file "func_do_write" addr_write_same-${temp_num}.report1
        check_in_file "Event" addr_write_same-${temp_num}.report1
    fi
    #check addr:x of func_do_write
    check_in_file "Samples: 1" addr_func_write-${temp_num}.report1
    check_in_file "func_do_write" addr_func_write-${temp_num}.report1
    check_in_file "Event" addr_func_write-${temp_num}.report1
    #check report files do not have content
    has_content `ls *.report0`
   
    #check addr:w of read_only
    if [ ! -z "`uname -m | grep 86`" ];then
        ret=`grep "Samples" addr_ro_w-${temp_num}.report0`
        if [ $ret -ne 0 ];then
            RC=$((RC + 1))
        fi
    fi
    #check addr:x of read_only
    [ ! -z "`grep "Samples" addr_ro_x-${temp_num}.report0`" ] && RC=$((RC + 1))
    #check addr:rw of nothing
    [ ! -z "`grep "Samples" nothing_rw-${temp_num}.report0`" ] && RC=$((RC + 1))
    #check addr:x of func_unused
    [ ! -z "`grep "Samples" addr_func_unused-${temp_num}.report0`" ] && RC=$((RC + 1))
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
