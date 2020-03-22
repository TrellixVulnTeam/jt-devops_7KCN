#该脚本用于自动触发前端构建发布

#获取本次构建的路径
Path=/data/jtb/infra/jenkins/jobs/${JOB_NAME}/builds
echo ${Path}

#获取提交信息是否符合标准
BRANCH=`grep message ${Path}/${BUILD_NUMBER}/log |sed -n '1p'|awk '{print substr($3,2)}'`

#定义变量
Now_time=`date +%Y%m%d-%H%M`

#替换前端地址
run_build () {
#sed -i -r 's;^(export const )(\$serverUrl=).*;\1\2"http://112.35.6.145:8812";' ${WORKSPACE}/src/plugins/mHttp.js
#sed -i -r 's;^(export const )(\$uploadUrl=).*;\1\2"http://112.35.6.145:8812";' ${WORKSPACE}/src/plugins/mHttp.js
#sed -i -r 's;^(export const )(\$historyPathUrl=).*;\1\2"http://112.35.6.145:8814";'  ${WORKSPACE}/src/plugins/mHttp.js
#sed -i -r 's;^(export const )(\$socketioUrl=).*;\1\2"ws://112.35.6.145:7002/socketio";' ${WORKSPACE}/src/plugins/mHttp.js
sed -i -r 's;^(export const )(\$serverUrl=).*;\1\2"http://10.111.30.3:8812";' ${WORKSPACE}/src/plugins/mHttp.js
sed -i -r 's;^(export const )(\$uploadUrl=).*;\1\2"http://10.111.30.3:8812";' ${WORKSPACE}/src/plugins/mHttp.js
sed -i -r 's;^(export const )(\$historyPathUrl=).*;\1\2"http://10.111.30.3:8814";'  ${WORKSPACE}/src/plugins/mHttp.js
sed -i -r 's;^(export const )(\$socketioUrl=).*;\1\2"ws://10.111.30.3:7002/socketio";' ${WORKSPACE}/src/plugins/mHttp.js
echo "Begin npm run build..."  && \
cd  ${WORKSPACE} && \
/usr/local/bin/npm  run build   && \
echo "rpm build successful"
}

#更新web前端
update_web () {
echo "Begin update front web" && \
cd /usr/local && \
tar -czf web_${Now_time}.tar.gz   web  && \
mv web_${Now_time}.tar.gz ./web_bak && \
rm -rf /usr/local/web/*
cp -r ${WORKSPACE}/dist/*  /usr/local/web/
cp -r ${WORKSPACE}/src/assets/global /usr/local/web/assets/  && \
cp /data/mvn/JtPlayer.swf  /usr/local/web/jt1078/
cp -r /data/mvn/global   /usr/local/web/assets/
chown -R  nginx:nginx /usr/local/web  && \
chmod 755 /usr/local/web
echo "Update front web successful"
}

#获取提交的代码分支，若为1.0.x则进行自动构建发布，若为其他则停止构建
if [ ${BRANCH} == "1.0.x" ];then
    run_build && \
    update_web
else
    Number=`expr ${BUILD_NUMBER} - 1`
    Branch=`grep message ${Path}/${Number}/log |sed -n '1p'|awk '{print substr($3,2)}'`
   if [ ${Branch} == "1.0.x" ];then
    run_build && \
    update_web
   fi
fi
