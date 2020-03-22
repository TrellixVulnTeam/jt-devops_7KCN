#!/bin/bash
rpm_path=/root/haproxy-1.6.8.tar.gz
path=`echo ${rpm_path} |awk '{print substr($1,1,length($1)-7) }'`
setup_path=/usr/local/haproxy
config_file=/root/haproxy.cfg
user=haproxy
yum -y install gcc 
if [ ! -e ${rpm_path} ];then
  echo "${rpm_path} is not exists,please download it"
  exit 2
else
if [ -e  ${config_file} ];then
  echo "${config_file} is not exits"
  exit 3
fi
  groupadd $user
  useradd -g $user -M -s /sbin/nologin $user 
  tar -xf ${rpm_path} && cd ${path} && \
  make TARGET=linux2628 ARCH=x86_64 PREFIX=${setup_path} && \
  make install PREFIX=${setup_path}  && \
  echo "haproxy setup successful"
fi
if [ -e  ${config_file} ];then
  echo "${config_file} is not exits"
  exit 3
fi
ln -s ${setup_path}/sbin/haproxy   /sbin/haproxy  && \
ln -s ${setup_path}/etc/haproxy.cfg /etc/haproxy.cfg && \
mkdir ${setup_path}/etc  && \
cp ${config_file} ${setup_path}/etc  && \
haproxy  -f    ${setup_path}/etc/haproxy.cfg
if [ $? -eq 0 ];then
  echo "you need modify config file.."
  exit 4
fi 
sleep 3
ps -ef|grep -v grep |grep haproxy |grep -v `basename $0` &> /dev/null
if [ $? -eq 0 ];then
  echo "haproxy start successful"
  rm -rf ${path} 
else 
  echo "haproxy setup successsful, but start failed.perhaps you need ${config_file} or modify ${config_file}"
fi
