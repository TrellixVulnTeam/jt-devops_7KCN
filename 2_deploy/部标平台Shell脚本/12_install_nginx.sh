#!/bin/bash
today_time=`date +%Y%m%d`
nginx_tar=/root/nginx-1.14.2.tar.gz
nginx_path=/data/jtb/infra/nginx
version=1.14.2
user=nginx
if [ ! -e ${nginx_tar} ];then
   echo "nginx-${version}.tar.gz is not exists,please download it"
   exit 1
fi
echo "Begin setup nginx..."
groupadd ${user}
useradd -g ${user} -M -s /sbin/nologin ${user}
yum -y install gcc zlib-devel pcre-devel openssl openssl-devel
tar -xf ${nginx_tar} && cd  ~/nginx-${version}
./configure --prefix=${nginx_path} --user=$user --group=$user --with-stream --with-http_ssl_module --with-http_stub_status_module --with-stream_ssl_module
make && make install
cp ${nginx_path}/conf/nginx.conf   ${nginx_path}/conf/nginx.conf.bak  && \
ln -sf ${nginx_path}/sbin/nginx   /sbin/nginx    && \
nginx
retval=$?
if [ ${retval} -eq 0 ];then 
  echo -e "\033[1;32mnginx is setup successful\033[0m"
else 
  echo -e "\033[1;31mnginx is setup failed\033[0m"
fi
rm -rf ~/nginx-${version}
