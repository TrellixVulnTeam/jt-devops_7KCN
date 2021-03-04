Path=/data/jtb/infra/jenkins/jobs/${JOB_NAME}/builds
echo ${Path}


#定义变量
HARBOR_PREFIX=harbor.zhkj.com/jtb
TEMP=/tmp/te.log
TMP_LOG=/tmp/ga.log
FIL_LOG=/tmp/ge.log


get_svcname () {
    cd ${Path}
    #sed -i '/^$/d'  ${BUILD_NUMBER}/changelog.xml
    #awk '/src/{print $NF}'  ${BUILD_NUMBER}/changelog.xml > ${TMP_LOG}
    
    awk -F/  '/app/{print $2}' ${TMP_LOG} > ${FIL_LOG}  || echo app
    SVC_NAME=`cat ${FIL_LOG}|sort|uniq`
    echo $SVC_NAME
}


mvn_compile () {
   cd ${WORKSPACE}/gateway-calc-core
   mvn clean && mvn install
}


filter_service () {
    for item in ${svc_name};do
        cd ${WORKSPACE}/gateway-calc-app/$1 &&  mvn clean && mvn install
    done
}


release_newversion () {
PORT=$(awk "/$1/{print $NF}" ${JENKINS_HOME}/platform_port.log|awk '{print $2}') && \
cd ${WORKSPACE}/gateway-calc-app/$1
version=$(awk '/<version>[^<]+<\/version>/{gsub(/<version>|<\/version>/,"",$1);print $1;exit;}' pom.xml) && \
cp -f target/$1-${version}.jar /opt/build/gateway/lib  && \
cd /opt/build/gateway/lib && \
../bin/auto_build_and_push_image.sh  $1 ${version} ${PORT} && \
docker tag $1:${version} ${HARBOR_PREFIX}/jt-$1:${version} && \
docker push ${HARBOR_PREFIX}/jt-$1:${version}
kubectl delete -f ../conf/$1.yml
kubectl create -f ../conf/$1.yml --record
docker  rmi  $1:${version}
docker  rmi  ${HARBOR_PREFIX}/jt-$1:${version}
}

#判断提交记录中是否包含多个服务,若包含多个则进行多个服务发布,否则进行单个服务发布
get_svcname
mvn_compile
echo ${SVC_NAME} > ${TEMP}
echo ${SVC_NAME}|grep foward &&  b=$(grep -o "foward" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}') || b=0
echo ${SVC_NAME}|grep trip &&  c=$(grep -o "trip" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}') || c=0
echo ${SVC_NAME}|grep alarm &&  d=$(grep -o "alarm" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}') || d=0
echo ${SVC_NAME}|grep statistics &&  e=$(grep -o "statistics" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}') || e=0
number=`expr $b + $c + $d + $e`


main () {
    if [ ${number} -eq 1 ];then
        cd ${WORKSPACE}/gateway-calc-app/${SVC_NAME} &&  mvn clean && mvn install
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