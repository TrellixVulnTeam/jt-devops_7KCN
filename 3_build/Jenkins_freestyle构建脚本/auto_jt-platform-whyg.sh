Path=/data/jtb/infra/jenkins/jobs/${JOB_NAME}/builds
echo ${Path}

HARBOR_PREFIX=harbor.zhkj.com/jtb
TEMP=/tmp/tem.log
TMP_LOG=/tmp/wh.log
FIL_LOG=/tmp/yg.log

get_svcname () {
    cd ${Path}
    sed -i '/^$/d'  ${BUILD_NUMBER}/changelog.xml
    awk '/src\/main/{print $NF}'  ${BUILD_NUMBER}/changelog.xml > ${TMP_LOG}  
    ##测试时使用
    ##awk '/src\/main/{print $NF}'   /root/changelog.xml   > ${TMP_LOG}
    cat ${TMP_LOG} | grep provider && awk -F/ '{print $1}' ${TMP_LOG} > ${FIL_LOG}  || echo provider
    cat ${TMP_LOG} | grep endpoint && echo "endpoint-rqys" >> ${FIL_LOG}  || echo endpoint-rqys
    sed -i "s;platform-;;"  ${FIL_LOG}
    SVC_NAME=`cat ${FIL_LOG}|sort|uniq`
    echo $SVC_NAME
}



filter_service () {
    echo $1|grep provider &&  cd ${WORKSPACE}/platform-$1 &&  mvn clean && mvn install || echo provider
    echo $1|grep endpoint &&  cd ${WORKSPACE}/platform-$1 &&  mvn clean && mvn install || echo endpoint
}

release_newversion () {
echo "当前目录为：`pwd`"
PORT=$(awk "/$1/{print $NF}" ${JENKINS_HOME}/platform_port.log|awk '{print $2}') && \
version=$(awk '/<version>[^<]+<\/version>/{gsub(/<version>|<\/version>/,"",$1);print $1;exit;}' pom.xml) && \
cp -f target/$1-${version}.jar /opt/build/platform/lib  && \
cd /opt/build/platform/lib && \
../bin/build_docker_image.sh $1 ${version} ${PORT} && \
docker tag jt-$1:${version} ${HARBOR_PREFIX}/jt-platform-$1:${version} && \
docker push ${HARBOR_PREFIX}/jt-platform-$1:${version}
/opt/kube/bin/kubectl delete -f ../conf/jt-platform-$1.yml
/opt/kube/bin/kubectl create -f ../conf/jt-platform-$1.yml --record
docker  rmi  jt-$1:${version}
docker  rmi  ${HARBOR_PREFIX}/jt-platform-$1:${version}
}

#判断提交记录中是否包含多个服务,若包含多个则进行多个服务发布,否则进行单个服务发布
get_svcname
echo ${SVC_NAME} > ${TEMP}
echo ${SVC_NAME}|grep provider &&  a=$(grep -o "provider" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}') || a=0
echo ${SVC_NAME}|grep endpoint && c=$(grep -o "endpoint" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}')  || b=0
number=`expr $a + $b`
echo $number

main () {
    if [ ${number} -eq 1 ];then
        filter_service   ${SVC_NAME}
        release_newversion  ${SVC_NAME}
    else
        for service in `cat ${TEMP}`;do
          filter_service  ${service}
          release_newversion ${service}
        done
    fi
rm -f ${FIL_LOG}
}


main