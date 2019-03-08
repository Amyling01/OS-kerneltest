#!/bin/sh

set -x
source ../../../conf/testconf
source ./init.sh
RET=0

tmp_file="_tmp_data"
min=0
avg=0
max=0

function set_env()
{
    #pull images 
    do_init
    if [ $? -ne 0 ];then
        echo "prepare test: FAIL"
        return 1
    fi  
    #create dockers
    docker_name="pause_test"
    docker run -tid --net=none --name ${docker_name} ${ubuntu_image} /bin/sh
    if [ $? -ne 0 ];then
        echo "Create docker:FAIL"
        return 1
    fi
}

function clean_env()
{
    #delete dockers 
    docker rm -f `docker ps -qa` > /dev/null 2>&1
    #delete docker images
    do_uninit

}

function do_test()
{
    set_env || return 1


    for i in $(seq 1 $loop_num)
    do
        t1=`date +%s.%N`
        docker pause ${docker_name}
        t2=`date +%s.%N`
        getTiming ${t1} ${t2} >> $tmp_file
        
        #unpause docker
        docker ps | grep Paused | grep ${docker_name}
        if [ $? -ne 0 ];then
            echo "${i}th pause docker[${docker_name}]:FAIL"
            return 1
        fi
        docker unpause ${docker_name}
        docker ps | grep -v Paused | grep ${docker_name}
        if [ $? -ne 0 ];then
            echo "${i}th unpause docker[${docker_name}]:FAIL"
            return 1
        fi  
        #clear system buff
        echo 3 > /proc/sys/vm/drop_caches
        sleep 3  
    done

    min=`calc_min_value $tmp_file`
    avg=`calc_avg_value $tmp_file`
    max=`calc_max_value $tmp_file`

}

do_test || RET=1
clean_env

mkdir -p /tmp/cloudran
cp $tmp_file /tmp/cloudran/pause_latency

echo "min=$min ms" >  $cloudran_report_path
echo "max=$max ms" >> $cloudran_report_path
echo "avg=$avg ms" >> $cloudran_report_path


exit $RET   
