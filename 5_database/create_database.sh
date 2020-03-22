#!/bin/bash
#Notice:before you execute this shell script,you need ensure the variable sqldir is exits,and modify the root password.
user=root
pass=gzhXR6d@k*42FV
sqldir=/root/tablesql
if [ ! -e ${sqldir} ];then
  echo "${sqldir} is not exits,please upload tablesql"
  exit 3
fi

for i in `seq 1 25`;do
   mysql -u${user} -p${pass} -e "create database "jtb_log_db$i""
   for j in 1 2 3 4 5;do 
     table=`ls $sqldir|sed -n "${j}p"`
     cd ${sqldir}
     mysql -u${user} -p${pass} jtb_log_db$i  < ./$table
   done
done
mysql -u${user} -p${pass} -e "create database car_mp;"
