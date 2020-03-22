#!/bin/bash
USER=root
PASSWORD=edcsc1978
FILE=/etc/my.cnf
BACKUP_DIR=/data/backup
BACKUP_LOG=/data/backup/mysql_bakcup.log
TODAY=`date +'%Y%m%d'`

[[ -d ${BACKUP_DIR} ]] || mkdir ${BACKUP_DIR}
[[ -d ${BACKUP_DIR}/${TODAY} ]] || mkdir ${BACKUP_DIR}/${TODAY}

mysql_backup () {
 begin_time=`date +'%Y%m%d_%H%M%S'` && \
 echo "Start to backup mysql data at ${begin_time}" > ${BACKUP_LOG} && \
 /usr/bin/innobackupex --defaults-file=${FILE} --user=${USER}  --password=${PASSWORD} --stream=tar ${BACKUP_DIR}/${TODAY} 2>>${BACKUP_LOG} 1>${BACKUP_DIR}/${TODAY}/alldb.tar
 retval=$?
 end_time=`date +'%Y%m%d_%H%M%S'`
 if [ $retval -eq 0 ];then
   echo "Backup is finish! at ${end_time}" >> ${BACKUP_LOG}
 else
   echo "Backup is Fail! at ${end_time}" >> ${BACKUP_LOG}
 fi
}

mysql_backup
