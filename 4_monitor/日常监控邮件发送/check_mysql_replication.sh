#!/bin/bash
USER=root
PASS=gzhXR6d@k*42FV
LOG=/tmp/check_mysql_stauts.log
MAIL_TO="15071244227@139.com,wushaoyu95@163.com"
MAILTO="wushaoyu95@163.com"


check_status() {
  #status=$(mysql -u${USER} -p${PASS} -e "show slave status\G" |egrep "Slave_SQL_Running:|Slave_IO_Running:")
  status_sql=$(mysql -u${USER} -p${PASS} -e "show slave status\G" |grep "Slave_SQL_Running:")
  status_io=$(mysql -u${USER} -p${PASS} -e "show slave status\G" |grep "Slave_IO_Running:")
  echo ${status_sql} > ${LOG}
  echo ${status_io} >> ${LOG}
  sql_status=$(awk 'NR==1{print $2}' ${LOG}) 
  io_status=$(awk 'NR==2{print $2}' ${LOG})
  if [[ ${sql_status} == "Yes" ]] && [[ ${io_status} == "Yes" ]] ;then
     echo "[OK]Mysql Replication IS Good.." >> ${LOG}
     echo -e "This mail from 112.35.6.145(测试环境)\n$(cat ${LOG})" |mail -s "[OK]Mysql Replication IS Good.."  ${MAILTO}
  else
     echo  "[WARN]Mysql Replication IS Problem.." >> ${LOG}
     echo -e "This mail from 112.35.6.145(测试环境)\n$(cat ${LOG})" |mail -s "[WARN]Mysql Replication IS Problem"  ${MAIL_TO}
  fi
}


check_status
