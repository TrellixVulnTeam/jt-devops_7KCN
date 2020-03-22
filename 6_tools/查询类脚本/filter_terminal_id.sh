#!/bin/bash
list="014530802061 \
      014530802066 \
      014532151747 \
      014530784416 \
      014531013073 \
      014532021921 \
      014533768949"

for i in `seq 11 23`;do
  tar -xf  /data/jtb/jt-gateway-809-up/logs/console_20191121_${i}00.tar.gz -C /data/jtb/jt-gateway-809-up/logs/wsy/
  cd /data/jtb/jt-gateway-809-up/logs/wsy/
  for j in ${list};do
    grep ${j} console.log >> /data/jtb/jt-gateway-809-up/logs/wsy/grep.log
  done
  rm -f /data/jtb/jt-gateway-809-up/logs/wsy/console.log
done



for i in `seq -w 00 11`;do
  tar -xf  /data/jtb/jt-gateway-809-up/logs/console_20191122_${i}00.tar.gz -C /data/jtb/jt-gateway-809-up/logs/wsy/
  cd /data/jtb/jt-gateway-809-up/logs/wsy/  
  for j in ${list};do
    grep ${j} console.log >> /data/jtb/jt-gateway-809-up/logs/wsy/grep.log
  done
  rm -f /data/jtb/jt-gateway-809-up/logs/wsy/console.log
done

