#!/bin/bash
number=$1

if [ -z ${number} ];then
  exit 1
fi

nohup java -Xms2048m -Xmx2048m -jar platform-provider-terminal-1.0.7.BUILD-SNAPSHOT-${number}.jar  --spring.config.local=application-local.yml  --spring.profiles.active=local > /dev/null  2>&1 &
