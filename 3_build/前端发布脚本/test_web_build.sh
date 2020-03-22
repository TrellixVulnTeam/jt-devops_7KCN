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
  git reset --hard HEAD && \
  #git checkout master && \
  git checkout 1.0.x
  git reset --hard HEAD
#  expect << EOF
#  spawn git pull
#  expect "Username"  {send "wushaoyu\n"}
#  expect "Password"  {send "wushaoyu\n"}
#  expect "Password"  {send "exit\r"}
#EOF
  echo "Begin sed all config ip..."  && \
  sed -i -r 's;^(export const )(\$serverUrl=).*;\1\2"http://10.111.30.3:8812";' ${Destination_dir}/mHttp.js
  #sed -i -r 's;^(export const )(\$uploadUrl=).*;\1\2"http://112.35.6.145:10001";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$uploadUrl=).*;\1\2"http://10.111.30.3:8812";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$historyPathUrl=).*;\1\2"http://10.111.30.3:8814";'  ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$socketioUrl=).*;\1\2"ws://10.111.30.3:7002/socketio";' ${Destination_dir}/mHttp.js
  #sed -i -r 's;871202;511;' ${Destination_dir}/mHttp.js
  echo "Begin npm run build..."  && \
  /usr/local/bin/npm  run build   && \
  echo "rpm build successful"  && \
  echo "sed all config ip successful,you can update front web"
}

update_web () {
  echo "Begin update front web" && \
  cd /usr/local && \
  tar -czf web_${Now_time}.tar.gz   web  && \
  mv web_${Now_time}.tar.gz ./web_bak && \
  rm -rf /usr/local/web/*
  cp -r ${DST}/dist/*  /usr/local/web/
  cp -r ${DST}/src/assets/global /usr/local/web/assets/  && \
  cp /data/mvn/JtPlayer.swf  /usr/local/web/jt1078/
  cp -r /data/mvn/global   /usr/local/web/assets/
  chown -R  nginx:nginx /usr/local/web  && \
  chmod 755 /usr/local/web
  echo "Update front web successful"
}

check_user && \
run_build 
update_web  && \
rm -rf ${DST}/dist  && \
echo -e "\033[1;32mNow,front web update successful, happy\033[0m"
