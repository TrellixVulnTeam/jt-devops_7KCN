#!/bin/bash

i=$1
[[ -z $1 ]] && { echo "[ERROR] lack one parameter"; exit 1; }
[[ -z test-0.0.1-SNAPSHOT-${i}.jar ]] && { echo "[ERROR] change number of jar"; exit 1; }
nohup java -jar -Xms2048m -Xmx2048m test-0.0.1-SNAPSHOT-${i}.jar --spring.config.local=application.yml > test${i}.log  2>&1 &
