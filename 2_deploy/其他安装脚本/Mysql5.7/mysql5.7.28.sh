#!/bin/bash

set -o nounset

#MYSQL_URL="http://112.33.33.37:63030/jt-platform-package/mysql-${MYSQL_VERSION}-linux-glibc2.12-x86_64.tar.gz"

MYSQL_VERSION="5.7.28"
INSTALL_DIR=/data/jtb/infra
MYSQL_USER=mysql
MYSQL_URL="https://downloads.mysql.com/archives/get/p/23/file/mysql-${MYSQL_VERSION}-linux-glibc2.12-x86_64.tar.gz"


add_mysql_user () {
    local result=$(id ${MYSQL_USER})
    [[ -z $result ]] && groupadd ${MYSQL_USER} && \
    useradd -r -g ${MYSQL_USER}  ${MYSQL_USER}
}

download_mysql () {
    [[ -f ~/mysql-${MYSQL_VERSION}-linux-glibc2.12-x86_64.tar.gz ]] && \
        echo "[INFO]Begin download mysql-${MYSQL_VERSION}..." && \
        wget -O ~/mysql-${MYSQL_VERSION}-linux-glibc2.12-x86_64.tar.gz   ${MYSQL_URL}
    echo "[INFO]Begin tar mysql package..."
    tar -xf ~/mysql-${MYSQL_VERSION}-linux-glibc2.12-x86_64.tar.gz  -C  ${INSTALL_DIR} 
    cd ${INSTALL_DIR} 
    mv mysql-${MYSQL_VERSION}-linux-glibc2.12-x86_64  mysql 
    mkdir ${INSTALL_DIR}/mysql/data
    chown -R ${MYSQL_USER}:${MYSQL_USER} ${INSTALL_DIR}/mysql 
}


configure_mysql () {
    cd ${INSTALL_DIR}/mysql && \
    cp support-files/mysql.server   /etc/init.d/mysqld
    local result=$(echo ${MYSQL_HOME})
    [[ -z $result ]] &&  \
        echo "export MYSQL_HOME=${INSTALL_DIR}/mysql" >> /etc/profile && \
        echo "export PATH='$PATH':${MYSQL_HOME}/bin" >> /etc/profile   && \
        source /etc/profile
    echo "MYSQL enviroment configure successful..."
    cat > /etc/my.cnf << EOF
    [mysqld]
    datadir=${INSTALL_DIR}/mysql/data
    basedir=${INSTALL_DIR}/mysql
    port=3306
    socket=${INSTALL_DIR}/mysql/mysql.sock
    explicit_defaults_for_timestamp
    max_connections=2000
EOF
}


initiaze_mysql () {
    cd ${INSTALL_DIR}/mysql && \
    echo "[INFO]Begin initialize mysql,notice mysql init password will print at screen.."
    ./bin/mysqld --initialize --user=mysql --basedir=${INSTALL_DIR}/mysql  --datadir=${INSTALL_DIR}/mysql/data
    systemctl start mysqld
    systemctl status mysqld
}

main () {
    add_mysql_user
    download_mysql
    configure_mysql
    initiaze_mysql
}

main
