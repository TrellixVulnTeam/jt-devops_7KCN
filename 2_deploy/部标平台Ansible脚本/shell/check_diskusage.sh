#!/bin/bash
IP=`ifconfig eth0|awk -F '[ ]+' 'NR==2{print $3}'`
Hostname=$HOSTNAME
Time=`date +'%F %R'`
Standard=70
Mailto="wushaoyu95@163.com"
Log=/data/jtb/logs/check_space
Gendir_size=`df -h |grep "/$"|awk 'gsub(/%/,"",$5){print $5}'`
Datadir_size=`df -h |grep "/data"|awk 'gsub(/%/,"",$5){print $5}'`

[[ -d ${Log} ]] || mkdir -p ${Log}
cat > ${Log}/disk.log <<EOF
Hostname: $Hostname
Ip: $IP
Time: $Time
Message: [WARN] Disk usage is large then ${Standard}%,please clean it up!!!
Company: 
EOF


for i in `echo ${Gendir_size}  ${Datadir_size}`;do
  if [ $i -ge ${Standard} ];then
   df -h |grep "/$"|awk '{print}' >> ${Log}/disk.log
   df -h |grep "/data"|awk '{print}' >>  ${Log}/disk.log
   cat ${Log}/disk.log | mail -s "Problem:Disk Usage is larget than ${Standard}%"  ${Mailto}
   break
  fi
done
