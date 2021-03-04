Path=/data/jtb/infra/jenkins/jobs/${JOB_NAME}/builds
echo ${Path}


#定义变量
HARBOR_PREFIX=harbor.zhkj.com/jtb
TEMP=/tmp/te.log
TMP_LOG=/tmp/ta.log
TM_LOG=/tmp/tm.log
FAL_LOG=/tmp/tn.log
FIL_LOG=/tmp/te.log


get_svcname () {
    cd ${Path}
    sed -i '/^$/d'  ${BUILD_NUMBER}/changelog.xml
    awk '/src\/main/{print $NF}'  ${BUILD_NUMBER}/changelog.xml > ${TMP_LOG}
    ##测试使用
    #sed -i '/^$/d'  /root/test.log
    #awk '/src\/main/{print $NF}'  /root/test.log > ${TMP_LOG}
    cat ${TMP_LOG} | grep gateway-app |grep gateway-809 | awk -F/ '{print $3}' > ${FIL_LOG} || echo jt-gateway-app
    cat ${TMP_LOG} | grep gateway-app |grep -v gateway-809 | awk -F/ '{print $2}' > ${FAL_LOG} || echo jt-gateway-app
    grep -v gateway-app ${TMP_LOG}| awk -F/ '{print $1}' > ${TM_LOG}  || echo jt-gateway-other 
    SVC_NAME=`cat ${FIL_LOG}|sort|uniq`
    echo "要发布的服务名称有:${SVC_NAME}"
}


mvn_compile () {
    if [ ! -z ${TM_LOG} ];then
        SVC_NAME=`cat ${TM_LOG}|sort|uniq`
        for item in ${SVC_NAME};do
            echo "开始打包服务,服务名称${item}"
            cd ${WORKSPACE}/${item}  && mvn clean && mvn install
        done
        echo "基础依赖包打包完成....."
    fi
    if  [ ! -z ${FIL_LOG} ];then
        SVC_NAME=`cat ${FIL_LOG}|sort|uniq`
        for item in ${SVC_NAME};do
            echo "开始打包服务,服务名称${item}"
            cd ${WORKSPACE}/jt-gateway-app/jt-gateway-809/${item}  && mvn clean && mvn install
        done
    fi
    if  [ ! -z ${FAL_LOG} ];then
        SVC_NAME=`cat ${FAL_LOG}|sort|uniq`
        for item in ${SVC_NAME};do
            echo "开始打包服务,服务名称${item}"
            cd ${WORKSPACE}/jt-gateway-app/${item}  && mvn clean && mvn install
            PORT=`grep ${item}   ${JENKINS_HOME}/platform_port.log|awk '{print $2}'`
            release_newversion  ${item}
        done
    fi
}


release_newversion () {
version=$(awk '/<version>[^<]+<\/version>/{gsub(/<version>|<\/version>/,"",$1);print $1;exit;}' pom.xml)
cp -f target/$1-${version}.jar /opt/build/gateway/lib  && \
cd /opt/build/gateway/lib && \
../bin/auto_build_and_push_image.sh $1 ${version} ${PORT} && \
docker tag $1:${version} ${HARBOR_PREFIX}/$1:${version} && \
docker push ${HARBOR_PREFIX}/$1:${version}
kubectl delete -f ../conf/$1.yml
kubectl create -f ../conf/$1.yml --record
docker  rmi  $1:${version}
docker  rmi  ${HARBOR_PREFIX}/$1:${version}
}

#判断提交记录中是否包含多个服务,若包含多个则进行多个服务发布,否则进行单个服务发布
#get_svcname
#mvn_compile
#echo ${SVC_NAME} > ${TEMP}
#echo ${SVC_NAME}|grep gateway-app &&  a=$(grep -o "gateway-app" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}') || a=0
#echo ${SVC_NAME}|grep commons && b=$(grep -o "commons" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}')    || b=0
#echo ${SVC_NAME}|grep contract && c=$(grep -o "contract" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}')  || c=0
#echo ${SVC_NAME}|grep message && c=$(grep -o "message" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}')  || d=0
#echo ${SVC_NAME}|grep core && c=$(grep -o "core" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}')  || e=0
#number=`expr $a + $b + $c + $e + $d`
#number=$a
#main () {
#    if [ ${number} -eq 1 ];then
#        filter_service   ${SVC_NAME}
#        release_newversion  ${SVC_NAME}
#    else
#        for service in `cat ${TEMP}`;do
#          filter_service  ${service}
#          release_newversion ${service}
#        done
#    fi
#rm -f ${FIL_LOG}


main () {
   get_svcname
   mvn_compile
   rm -f ${TM_LOG}  ${FAL_LOG} ${FIL_LOG}
}

main