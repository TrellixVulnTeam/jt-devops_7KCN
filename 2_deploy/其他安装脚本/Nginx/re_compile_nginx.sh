#!/bin/bash
today_time=`date +%Y%m%d`
nginx_tar=/home/admin/nginx-1.14.2.tar.gz
nginx_path=/data/jtb/infra/nginx
user=nginx
if [ ! -e ${nginx_tar} ];then
   echo "nginx-1.14.2.tar.gz is not exists,please download it"
   exit 1
fi

service nginx stop
  RETVAL=$?
  if [ ${RETVAL} -eq 0 ];then
     mv ${nginx_path} ${nginx_path}_bak${today_time}
     tar -xf ${nginx_tar} && cd  ~/nginx-1.14.2 
     ./configure --prefix=${nginx_path} --user=$user --group=$user  --with-stream  --with-http_ssl_module  --with-http_stub_status_module  --with-stream_ssl_module  && \
     make && make install
  else
     exit 2
  fi
service nginx test  && \
cp ${nginx_path}_bak${today_time}/conf/nginx.conf ${nginx_path}/conf && \
${nginx_path}/sbin/nginx && \
echo "Nginx is start successful" && \ 
service nginx status && \
echo "Nginx compile successful" && \
rm -rf  ~/nginx-1.14.2
