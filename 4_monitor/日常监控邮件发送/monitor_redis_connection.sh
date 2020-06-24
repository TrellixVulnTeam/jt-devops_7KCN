#!/bin/bash

PORT=6379
STAND=16000
IP=192.168.0.6

MAIL_TO="wushaoyu95@163.com"

POD_NAME="jt-platform-provider-terminal"


main () {
    number=`ssh ${IP} netstat -anp|grep 6379|wc -l`
    pod_list=`kubectl get pods -o wide |grep jt-platform-provider-terminal|awk '{print $1}'` 
    if [ ${number} -gt ${STAND} ];then
        for item in $pod_list;do
            kubectl delete pod $item
            sleep 30
        done
        echo -e "`date +'%F-%R'`\n云图Redis连接数异常,目前连接数为:${number},已重启完毕"  | mail -s "云图安行Redis连接数异常!!!"  ${MAIL_TO}
    fi
}

main
