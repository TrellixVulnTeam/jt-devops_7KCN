Destination_dir=${WORKSPACE}/src/plugins
DST=${WORKSPACE}
Now_time=`date +%Y%m%d-%H%M`

port=22
ip=10.8.0.98

run_build () {
  echo "Begin sed all config ip..."  && \
  sed -i -r 's;^(export const )(\$serverUrl=).*;\1\2"http://172.16.4.233:8812";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$uploadUrl=).*;\1\2"http://172.16.4.233:8812";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$apiServerUrl=).*;\1\2"http://172.16.4.234:8814";'  ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$socketioUrl=).*;\1\2"ws://172.16.4.233:7002/socketio";' ${Destination_dir}/mHttp.js
  sed -i -r 's;^(export const )(\$hostUrl=).*;\1\2"ws://172.16.4.233:60002";' ${Destination_dir}/mHttp.js
  echo "Begin npm run build..."  && \
  /usr/local/bin/npm  run build   && \
  echo "rpm build successful"  && \
  echo "sed all config ip successful,you can update front web"
}


update_web () {
  cd ${DST} && cp -r dist web && \
  cd ${DST} && tar -czf  web.tar.gz  web && \
  cd ${DST} && rm -rf web dist && \
  scp -P${port} ${DST}/web.tar.gz ${ip}:/root/   && \
  ssh -p${port} ${ip} tar -xf  /root/web.tar.gz -C /root/ && \
  ssh -p${port} ${ip} mv /usr/local/web  /data/backup/web_bak/web_bak${Now_time}   && \
  ssh -p${port} ${ip} mv /root/web  /usr/local/  && \
  ssh -p${port} ${ip} chown -R  nginx:nginx /usr/local/web  && \
  ssh -p${port} ${ip} chmod -R 755  /usr/local/web
}



main () {
   run_build  && \
   update_web && \
   cd  ${DST} && \
   rm -rf dist  web  web.tar.gz
   echo -e "\033[1;32mNow,front web update successful, happy\033[0m"
}

main 