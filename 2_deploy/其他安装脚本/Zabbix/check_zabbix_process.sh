#!/bin/bash
name=`basename $0`
ps_out=`ps -ef|grep -v grep |grep $1|grep -v $name`
if [ $? -eq 0 ];then
  echo 1
else 
  echo 0
fi