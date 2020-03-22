#!/bin/bash
ES_DIR=/var/log/elasticsearch/
LOG_DIR=/data/jtb/logs/es/

if [ ! -d ${LOG_DIR } ];then
    mkdir -p ${LOG_DIR}
fi

find ${ES_DIR}  -mtime +5 -exec mv {} ${LOG_DIR}  \;
