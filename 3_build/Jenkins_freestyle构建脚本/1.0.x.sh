Path=/data/jtb/infra/jenkins/jobs/${JOB_NAME}/builds
echo ${Path}


#定义变量
is_provider=$(echo "${SVC_NAME}"|sed -n '/^provider-.*/p')
is_endpoint=$(echo "${SVC_NAME}"|sed -n '/^endpoint-.*/p')
HARBOR_PREFIX=harbor.zhkj.com/jtb
TEMP=/tmp/temp.log
TMP_LOG=/tmp/svcname.log
FIL_LOG=/tmp/fil.log

get_svcname () {
    cd ${Path}
    sed -i '/^$/d'  ${BUILD_NUMBER}/changelog.xml
    awk '/src\/main/{print $NF}'  ${BUILD_NUMBER}/changelog.xml > ${TMP_LOG}
    ##测试时使用awk '/src\/main/{print $NF}'   /root/bak.log   > ${TMP_LOG}
    cat ${TMP_LOG} | grep provider && awk -F/ '{print $2}' ${TMP_LOG} > ${FIL_LOG}  || echo provider
    cat ${TMP_LOG} | grep gateway-server && echo "platform-gateway-server" >> ${FIL_LOG}  ||  echo gateway
    cat ${TMP_LOG} | grep gateway-api && echo "platform-gateway-api" >> ${FIL_LOG}  || echo gateway-api
    cat ${TMP_LOG} | grep endpoint && echo "platform-endpoint-809" >> ${FIL_LOG}  || echo endpoint-809
    SVC_NAME=`cat ${FIL_LOG}|sort|uniq`
    echo $SVC_NAME
}


mvn_compile () {
cd platform-parent/
mvn clean && mvn install

cd ../platform-endpoint/platform-endpoint-contract/
mvn clean && mvn install
}

filter_service () {
    echo $1|grep provider &&  cd ${WORKSPACE}/platform-provider/$1 &&  mvn clean && mvn install -Dmaven.test.skip=true || echo provider
    echo $1|grep gateway &&  cd ${WORKSPACE}/$1 &&  mvn clean && mvn install  ||  echo gateway
    echo $1|grep endpoint &&  cd ${WORKSPACE}/platform-endpoint/$1 &&  mvn clean && mvn install || echo endpoint
}

release_newversion () {
PORT=$(awk "/$1/{print $NF}" ${JENKINS_HOME}/platform_port.log|awk '{print $2}') && \
version=$(awk '/<version>[^<]+<\/version>/{gsub(/<version>|<\/version>/,"",$1);print $1;exit;}' pom.xml) && \
cp -f target/$1-${version}.jar /opt/build/platform/lib  && \
cd /opt/build/platform/lib && \
../bin/build_docker_image.sh $1 ${version} ${PORT} && \
docker tag jt-$1:${version} ${HARBOR_PREFIX}/jt-$1:${version} && \
docker push ${HARBOR_PREFIX}/jt-$1:${version}
/opt/kube/bin/kubectl delete -f ../conf/jt-$1.yml
/opt/kube/bin/kubectl create -f ../conf/jt-$1.yml --record
docker  rmi  jt-$1:${version}
docker  rmi  ${HARBOR_PREFIX}/jt-$1:${version} && echo "successful" || echo "faid"
}

#判断提交记录中是否包含多个服务,若包含多个则进行多个服务发布,否则进行单个服务发布
get_svcname
echo ${SVC_NAME} > ${TEMP}
echo ${SVC_NAME}|grep provider &&  a=$(grep -o "provider" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}') || a=0
echo ${SVC_NAME}|grep gateway && b=$(grep -o "gateway" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}')    || b=0
echo ${SVC_NAME}|grep endpoint && c=$(grep -o "endpoint" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}')  || c=0
number=`expr $a + $b + $c`
echo $number

main () {
    if [ ${number} -eq 1 ];then
        #mvn_compile
        filter_service   ${SVC_NAME}
        release_newversion  ${SVC_NAME}
    else
        #mvn_compile
        for service in `cat ${TEMP}`;do
          filter_service  ${service}
          release_newversion ${service}
        done
    fi
rm -f ${FIL_LOG}
}


main