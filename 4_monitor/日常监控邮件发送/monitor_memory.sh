#!/bin/bash

usage=`free -m |awk 'NR==2{print $3}'`
stand=13000
#stand=9000

mail_to="15071244227@139.com,wushaoyu95@163.com"

hour=`date| awk -F  '[: ]+'  '{print $5}'`

base_name=`basename $0`

base_dir="/data/jtb/jt-gateway/jt-gateway-1078_app1/"
base_pid=`ps -ef|grep 1078|grep -v grep|grep -v ${base_name}|awk '{print $2}'`

echo ${base_pid}



whether_reboot_1078 () {
    if [ ${usage} -gt ${stand} ];then
        if [ ${hour} -gt 0 ] && [ ${hour} -lt 8 ];then
            cd ${base_dir}  && \
            kill -9 ${base_pid}  && \
            sh run.sh
            sleep 30
            #echo "in reboot stop"
            ss -tnulp|grep 60002
            retval=$?
            if [ $retval -eq 0 ];then
                 echo "`date` 1078重启成功"  | mail -s "省内前置机1078重启1次,重启成功"   ${mail_to}
            else
                 echo "`date` 1078重启失败!!!!!!!"  | mail -s "省内前置机1078重启1次,重启失败"   ${mail_to}
            fi
        else
            echo -e "省内前置机内存使用情况:\n`date`\n`free -m`" | mail -s "省内前置机内存较高,请留意"  ${mail_to}
        fi
    fi
}

#whether_reboot_1078
