#!/bin/bash
tar_path=/root/fastdfs-5.11.tar.gz
module_path=/root/fastdfs-nginx-module-1.20.tar.gz
lib_path=/root/libfastcommon-1.0.39.tar.gz
setup_path=/data/jtb/infra
fastdfs_path=/data/jtb/infra/fastdfs
ip=`ifconfig eth0 |awk 'NR==2{print $2}'`
NG_tar=/root/nginx-1.14.2.tar.gz
NG_path=/data/jtb/infra/nginx
NG_port=9001
SYMBOL_END="}"
SYMBOL_START="{"

if [ ! -e ${fastdfs_path} ];then
  mkdir -p ${fastdfs_path}
fi
if [ -z ${ip} ];then
  echo "You need get ip first"
  exit 2
fi
if [ ! -e ${NG_tar} ];then
  echo "nginx.tar.gz does not exist,please download it"
  exit 3
fi

setup_module () {
  echo "Begin setup depend rpm and module..."
  yum -y install libevent  gcc make cmake  gcc-c++  && \
  tar -xf ${lib_path} -C ${setup_path}  && \
  cd ${setup_path}/libfastcommon-1.0.39    && \
  ./make.sh   && \
  ./make.sh install && \
  ls -l /usr/lib/libfastcommon.so
  if [ $? -eq 0 ];then
     echo "module setup successful"
  else
     echo "module setup faild"
     exit 2
  fi
}

setup_fastdfs () {
   echo "Begin tar setup fastdfs..."
   tar -xf ${tar_path} -C ${setup_path} && \
   cd ${setup_path}/fastdfs-5.11  && \
   ./make.sh && \
   ./make.sh install
   if [ $? -eq 0 ];then
      echo "fastdfs compile successful"
   else
      echo "fastdfs compile failed"
   fi
}

setup_fastdfs_tracker () {
   echo "Begin  setup fastdfs_tracker..." && \
   cd /etc/fdfs && \
   cp -f tracker.conf.sample  tracker.conf
   if [ ! -e ${fastdfs_path}/tracker ];then
      mkdir ${fastdfs_path}/tracker
   fi
   sed -r -i "s;^(base_path=).*;\1${fastdfs_path}/tracker;" ./tracker.conf && \
   /etc/init.d/fdfs_trackerd start && \
   sleep 2  && \
   netstat -ntulp|grep 22122   #If you change this port,you also need modify port 22122  in setup_fastdfs_storage part.
   if [ $? -eq 0 ];then
     echo -e "\033[1;32mfdfs_trackerd start successful\033[0m"
     #systemctl enable fdfs_trackerd
   else 
     echo -e "\033[1;31mfdfs_trackerd start failed\033[0m"
     exit 2
   fi
}

setup_fastdfs_storage () {
   echo "Begin  setup fastdfs_storage..." && \
   cd /etc/fdfs && \
   cp storage.conf.sample storage.conf && \
   if [ ! -e ${fastdfs_path}/storage ];then
      mkdir ${fastdfs_path}/storage
   fi
   sed -r -i "s;^(base_path=).*;\1${fastdfs_path}/storage;" ./storage.conf  && \
   sed -r -i "s;^(store_path0=).*;\1${fastdfs_path}/storage;" ./storage.conf  && \
   sed -r -i "s;^(tracker_server=).*;\1${ip}:22122;"  ./storage.conf  && \
   /etc/init.d/fdfs_storaged start && \
   sleep 2 && \
   netstat -ntulp|grep 23000                        ##If you change this port,you also need modify port 22122  in /etc/fdfs/mod_fastdfs.conf
   retval=$?
   if [ ${retval} -eq 0 ];then
      echo -e "\033[1;32mfdfs_storage start successful\033[0m" && \
      #systemctl enable fdfs_storage  && \
      echo "You can try upload one picture to fastdfs to test"
   else
     echo -e "\033[1;31mfdfs_storage start failed\033[0m"
   fi
}

setting_fastdfs_client () {
   echo "Begin setting fastdfs client conf..." && \
   cd /etc/fdfs   && \
   cp -f client.conf.sample client.conf  && \
   sed -r -i "s;^(base_path=).*;\1${fastdfs_path}/tracker;" ./client.conf  && \
   sed -r -i "s;^(tracker_server=).*;\1${ip}:22122;" ./client.conf && \
   echo "setting fastdfs client conf successful"
}

setup_fastdfs_nginx_module () {
   echo "Begin setup fastdfs nginx module..." && \
   tar -xf ${module_path} -C ${setup_path}  && \
   cd ${setup_path}/fastdfs-nginx-module-1.20/src && \ 
   cp -f config  config.bak && \
   sed -i -r 's;^( )+(ngx_module_incs=).*;\2"/usr/include/fastdfs /usr/include/fastcommon/";' ./config && \
   #sed -i -r 's;^( )+(CORE_INCS=).*\2"'$CORE_INCS' /usr/include/fastdfs /usr/include/fastcommon/"' ./config  && \ 
   sed -i '15c CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"' ./config
   grep "local"  ./config  
   if [ $? -eq 0 ];then
     echo "fastdfs_nginx_module config file modify faild"
     exit 4
   else 
     echo "fastdfs nginx module setup successful" && \
     cp ./mod_fastdfs.conf  /etc/fdfs   && \
     sed -r -i "s;^(base_path=).*;\1${fastdfs_path}/storage;"  /etc/fdfs/mod_fastdfs.conf && \
     sed -r -i "s;^(store_path0=).*;\1${fastdfs_path}/storage;" /etc/fdfs/mod_fastdfs.conf && \
     sed -r -i "s;^(tracker_server=).*;\1${ip}:22122;" /etc/fdfs/mod_fastdfs.conf && \   #If you change this port,you also need modify port 22122  in setup_fastdfs_nginx_module part
     sed -r -i "s;^(url_have_group_name =).*;\1 false;" /etc/fdfs/mod_fastdfs.conf && \  #If you do'not need url have group name ,you should set this option false
     echo "modify nginx module config successful"
   fi
} 

setup_nginx () {
   echo "Begin setup nginx..." && \
   yum -y install gcc zlib-devel pcre-devel openssl openssl-devel  && \
   cd ~ && \
   tar -xf ${NG_tar}  && \
   cd ~/nginx-1.14.2 && \
   ./configure --prefix=${NG_path} --add-module=${setup_path}/fastdfs-nginx-module-1.20/src --with-stream --with-http_ssl_module --with-http_stub_status_module --with-stream_ssl_module && \
   make && \
   make install  && \
   cd ${setup_path}/fastdfs-5.11/conf  && \
   cp  http.conf mime.types /etc/fdfs/  && \
   ln -sf ${NG_path}/sbin/nginx  /sbin/nginx && \
   ln -sf ${NG_path}/conf/nginx.conf /etc/nginx.conf && \
   rm -rf ~/nginx-1.14.2  && \
   echo "nginx setup successful"
}

setting_nginx_config () {
   cd ${setup_path}/nginx/conf && \
   sed -r -i "s@^( )+(listen).*@\2 ${NG_port};@" ./nginx.conf  && \
   sed -r -i "s@^( )+(server_name).*@\2 ${ip};@" ./nginx.conf  && \
   line=`grep -n "server_name" ./nginx.conf |awk -F: 'NR==1{print $1}'` && \
   sed -i "${line}a ${SYMBOL_END}"  ./nginx.conf  && \ 
   sed -i "${line}a ngx_fastdfs_module;"  ./nginx.conf  && \
   sed -i "${line}a root /data/infra/fastdfs/storage/data;" ./nginx.conf  && \
   sed -i "${line}a location  /M00/ ${SYMBOL_START}" ./nginx.conf && \
   ${NG_path}/sbin/nginx  && \
   netstat -ntulp|grep ${NG_port}
   if [ $? -eq 0 ];then 
     echo "nginx setting successful" 
   else
     echo "nginx settting failed"
     exit 5
   fi
} 
   
setup_module && \
setup_fastdfs  && \
setup_fastdfs_tracker && \
setup_fastdfs_storage && \
setting_fastdfs_client && \
setup_fastdfs_nginx_module && \
setup_nginx  && \
setting_nginx_config  && \
echo "All setup steps have finish,you can upload one picture to ecsure"
/usr/bin/fdfs_upload_file /etc/fdfs/client.conf /root/ocean.jpg
