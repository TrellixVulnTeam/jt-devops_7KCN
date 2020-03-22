#!/bin/bash
#Destination_dir=/data/jtb/infra/git/jt-platform-web
#NPM_CMD=/usr/local/bin/npm  run build
Destination_dir=/data/jtb/infra/git/jt-platform-web/src/plugins
DST=/data/jtb/infra/git/jt-platform-web
Now_time=`date +%Y%m%d-%H%M`
ip=112.35.44.185
port=2022

check_user () {
  if [ $USER != "root" ];then
     echo "Notice:You must first to be root,then you can execute this shell script" && \
     exit 2
  fi
}

run_build () {
  cd ${Destination_dir}  && \
  #git checkout master
  #git checkout 1.0.6.RELEASE
  git reset --hard HEAD && \
  git pull
  git checkout 1.0.x
  git reset --hard HEAD
#  expect << EOF
#  spawn git pull
#  expect "Username"  {send "wushaoyu\n"}
#  expect "Password"  {send "wushaoyu\n"}
#  expect "Password"  {send "exit\r"}
#EOF
  echo "Begin sed all config ip..."  && \
  sed -i -r 's;^(export const )(\$serverUrl=).*;\1\2"http://112.35.44.185:8812";' ${Destination_dir}/mHttp.js
  #sed -i -r 's;^(export const )(\$uploadUrl=).*;\1\2"http://112.35.44.185:30011";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$uploadUrl=).*;\1\2"http://112.35.44.185:8812";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$historyPathUrl=).*;\1\2"http://112.35.44.185:8814";'  ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$socketioUrl=).*;\1\2"ws://112.35.44.185:7002/socketio";' ${Destination_dir}/mHttp.js
  sed -r -i 's@^(Vue\.prototype\.\$skinColour =).*@\1 "ShengkeSkin";@'  ${DST}/src/main.js   ##省客皮肤替换
  echo "Begin npm run build..."  && \
  /usr/local/bin/npm  run build   && \
  echo "rpm build successful"  && \
  echo "sed all config ip successful,you can update front web"
}

update_web () {
  cd ${DST} && cp -r dist  web && \
  cd ${DST} && tar -czf  web.tar.gz  web && \
  cd ${DST} && rm -rf web && \
  scp -P${port} ${DST}/web.tar.gz ${ip}:/root/   && \
  ssh -p${port} ${ip} tar -xf  /root/web.tar.gz -C /root/ && \
  ssh -p${port} ${ip} cp -r /data/mvn/global /root/web/assets/  && \
  ssh -p${port} ${ip} cp  /data/mvn/JtPlayer.swf  /root/web/jt1078/ && \
  ssh -p${port} ${ip} mv /usr/local/web  /usr/local/web_bak/web_bak${Now_time}   && \
  ssh -p${port} ${ip} mv /root/web  /usr/local/  && \
  ssh -p${port} ${ip} chown -R  admin:admin /usr/local/web  && \
  ssh -p${port} ${ip} chmod 755  /usr/local/web
}
check_user && \
run_build  && \
update_web && \
echo -e "\033[1;32mNow,front web update successful\033[0m"
