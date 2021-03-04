#!/bin/bash

set -o nounset


MQ_VERSION="5.15.9"
JDK_NAME="jdk-8u201-linux-x64.tar.gz"
ACTIVE_MQ_URL="http://112.33.33.37:63030/jt-platform-package/apache-activemq-${MQ_VERSION}-bin.tar.gz" 
JDK_URL="http://112.33.33.37:63030/jt-platform-package/${JDK_NAME}"
INSTALL_DIR=/data/jtb/infra


install_jdk () {
    local result=$(echo ${JAVA_HOME})
    [[ -z $result ]] && \
        echo "[INFO]Begin download jdk1.8.201..." && \
        wget -O  ~/${JDK_NAME}   ${JDK_URL} && \
        tar -xf ~/${JDK_NAME} -C  /usr/local  && \
        echo "export JAVA_HOME=/usr/local/jdk1.8.0_201" >> /etc/profile && \
        echo "export PATH=$PATH:${JAVA_HOME}/bin"
        echo "[INFO]Jave enviroment is configure successful.."
}



install_active_mq () {
    [[ ! -f ~/apache-activemq-${MQ_VERSION}-bin.tar.gz ]] && \
        echo "[INFO]Begin download activemq package.." && \
        wget -O  ~/apache-activemq-${MQ_VERSION}-bin.tar.gz ${ACTIVE_MQ_URL}
    tar -xf ~/apache-activemq-${MQ_VERSION}-bin.tar.gz   -C  ${INSTALL_DIR}
    cd ${INSTALL_DIR} && \
    mv  apache-activemq-${MQ_VERSION}  activemq
 
}

as_service () {
    cat > /etc/systemd/system/activemq.service << EOF
[Unit]
Description=dble
After=network.target

[Service]
Type=forking
ExecStart=${INSTALL_DIR}/activemq/bin/activemq start
ExecReload=${INSTALL_DIR}/activemq/bin/activemq restart
ExecStop=${INSTALL_DIR}/activemq/bin/activemq stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload && systemctl restart activemq
    systemctl status activemq
}


main () {
    install_jdk
    install_active_mq && \
    as_service
}

main
