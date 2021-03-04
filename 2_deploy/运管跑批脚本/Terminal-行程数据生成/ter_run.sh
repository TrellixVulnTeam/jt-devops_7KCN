#!/bin/bash
number=$1

if [ -z ${number} ];then
  exit 1
fi

nohup java -Xms2048m -Xmx2048m -jar platform-provider-terminal-1.0.15.BUILD-SNAPSHOT-${number}.jar  --spring.config.local=application.yml  --spring.profiles.active=local > ter${number}.log  2>&1 &
