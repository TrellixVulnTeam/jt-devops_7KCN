#!/bin/bash
Destination_dir=/data/jtb/infra/git/jt-platform-web/src/plugins
DST=/data/jtb/infra/git/jt-platform-web
#NPM_CMD=/usr/local/bin/npm  run build
Now_time=`date +%Y%m%d-%H%M`

check_user () {
  if [ $USER != "root" ];then
     echo "Notice:You must first to be root,then you can execute this shell script" && \
     exit 2
  fi
}

run_build () {
  cd ${Destination_dir}  && \
  git reset --hard HEAD
  git checkout master
  git reset --hard HEAD
  git pull
  echo "Begin sed all config ip..."  && \
  sed -i -r 's;^(export const )(\$serverUrl=).*;\1\2"http://112.35.30.250:8812";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$uploadUrl=).*;\1\2"http://112.35.30.250:8812";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$apiServerUrl=).*;\1\2"http://112.35.30.250:8814";'  ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$socketioUrl=).*;\1\2"ws://112.35.30.250:7002/socketio";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$hostUrl=).*;\1\2"ws://112.35.30.250:60002";' ${Destination_dir}/mHttp.js
  echo "Begin npm run build..."  && \
  /usr/local/bin/npm  run build   && \
  echo "rpm build successful"  && \
  echo "sed all config ip successful,you can update front web"
}

update_web () {
  echo "Begin update front web" && \
  cd /usr/local && \
  tar -czf web_${Now_time}.tar.gz   web  && \
  mv web_${Now_time}.tar.gz /data/backup/web_bak && \
  #mv /usr/local/web/www   /root/ && \
  rm -rf /usr/local/web/*
  cp -r ${DST}/dist/*  /usr/local/web/
  #mv /root/www  /usr/local/web/  && \
  chown -R  nginx:nginx /usr/local/web  && \
  chmod -R 757 /usr/local/web
  echo "Update front web successful"
}

check_user && \
run_build 
update_web  && \
rm -rf ${DST}/dist  && \
echo -e "\033[1;32mNow,front web update successful, happy\033[0m"
