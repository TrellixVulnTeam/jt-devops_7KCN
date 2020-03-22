#!/bin/bash
RPM_PATH=/root/MySQL-5.6.34-1.el7.x86_64.rpm-bundle.tar
SETUP_ROOT=/data/jtb/infra
SETUP_PATH=/data/jtb/infra/mysql
DIR=/usr/share/mysql
PORT=3306
USER=mysql
setup_mysql () {
  if [ ! -e ${SETUP_ROOT} ];then
    mkdir -p ${SETUP_ROOT}
  fi
  groupadd ${USER}
  useradd -g ${USER} -M -s /sbin/nologin ${USER}
  tar -xf ${RPM_PATH} && mv  ${RPM_PATH} /tmp
  yum -y install autoconf && \
  yum -y localinstall MySQL-* && \
  cp -f ${DIR}/my-default.cnf  /etc/my.cnf  && \
  cp ${DIR}/mysql.server   /etc/init.d/mysqld  && \
  line=`grep -n "mysqld" /etc/my.cnf |awk -F: '{print $1}'` && \
  echo "Begin  config /etc/my.cnf..."
  sed -i "${line}a pid-file=${SETUP_PATH}/${HOSTNAME}.pid" /etc/my.cnf &&\
  sed -i "${line}a log-error=${SETUP_PATH}/${HOSTNAME}.err" /etc/my.cnf &&\
  sed -i "${line}a socket=${SETUP_PATH}/mysql.sock" /etc/my.cnf &&\
  sed -i "${line}a port=${PORT}" /etc/my.cnf &&\
  sed -i "${line}a datadir=${SETUP_PATH}" /etc/my.cnf && \
  echo "/etc/my.cnf has modify finished"
}

start_mysql () {
  sed -i "s;/var/lib;${SETUP_ROOT};" /usr/bin/mysql_install_db && \
  /usr/bin/mysql_install_db --defaults-file=/etc/my.cnf --user=${USER} --group=${USER} --datadir=${SETUP_PATH} && \
  /etc/init.d/mysqld start && \
  sleep 3 && \
  netstat -ntulp|grep ${PORT} > /dev/null 2>&1
  retval=$?
  if [ ${retval} -eq 0 ];then
    echo "mysql start successful"
    rm -rf /var/lib/mysql/*   && \
    rm -f ~/MySQL-* && \
    rm -f /tmp/MySQL-5.6.34-1.el7.x86_64.rpm-bundle.tar
    ln -s ${SETUP_PATH}/mysql.sock  /var/lib/mysql/mysql.sock
  else
    echo "mysql start failed,please check config file"
  fi
}

setup_mysql &&\
start_mysql
