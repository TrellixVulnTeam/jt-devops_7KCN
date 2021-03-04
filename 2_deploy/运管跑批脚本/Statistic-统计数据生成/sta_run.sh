#!/bin/bash
number=$1

if [ -z ${number} ];then
  exit 1
fi

nohup java -Xms2048m -Xmx2048m -jar gateway-calc-statistics-1.1.0.BUILD-SNAPSHOT-${number}.jar  --spring.config.local=application.yml  --spring.profiles.active=local > statis${number}.log  2>&1 &
