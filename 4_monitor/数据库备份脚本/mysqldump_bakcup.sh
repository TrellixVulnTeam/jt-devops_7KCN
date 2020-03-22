#!/bin/bash
USER=root
PASS=gzhXR6d@k*42FV
BACKUP_DIR=/data/backup
TIME=`date +%Y%m%d`
NAME=Allbak.sql
LOG=/data/backup/backup.log


#目前数据量较小，暂时使用mysqldump备份
backup_mysql () {
 begin_time=`date +%F-%R`
 echo "Begin backup mysql at ${begin_time}" >> ${LOG}
 mysqldump -u${USER} -p${PASS} -A > ${BACKUP_DIR}/${NAME}
 retval=$?
 if [ ${retval} -eq 0 ];then
   echo "Backup successful" >> ${LOG}
 else
   echo "Backup failed" >> ${LOG}
   exit 2
 fi
 end_time=`date +%F-%R`
 echo "Finsh backup mysql at ${end_time}" >> ${LOG}
 cd ${BACKUP_DIR} && \
 tar -czf mysqlbak_${TIME}.tar.gz  ${NAME} && rm -f ${NAME}
}

backup_mysql
echo "" >> ${LOG}

