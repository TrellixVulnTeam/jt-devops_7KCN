HARBOR_PREFIX=harbor.zhkj.com/jtb
GATEWAY_LIB=/opt/build/gateway/lib/
LIST="jt-gateway-commons jt-gateway-contract jt-gateway-core jt-gateway-message"
VERSION=$(grep version pom.xml |awk -F '[<>]' 'NR==2{print $3}')
GROUP_NAME="jt-gateway"
PORT=$(grep ${SVC_NAME} $WORKSPACE/port.txt|awk '{print $NF}')

if [[ ${SVC_NAME} = None ]];then
  echo "[ERROR] 必须通过Jt-gateway代码质量分析项目来触发构建发布此项目" && \
  echo ${SVC_NAME}
  exit 0
fi

mvn_operation () {
  mvn clean && \
  mvn install
}

mvn_install () {
  for item in $LIST;do
    cd $WORKSPACE/$item && \
    mvn_operation
  done
}

main () {
#mvn打包
mvn_install && \
cd  ../jt-gateway-app/jt-gateway-${SVC_NAME} &&  \
mvn_operation && \
cp ./target/jt-gateway-${SVC_NAME}-$VERSION.jar  ${GATEWAY_LIB}  && \
cd ${GATEWAY_LIB} &&  \
#打包推送镜像
echo $PWD
../bin/build_and_push_image.sh ${GROUP_NAME}  ${SVC_NAME} $VERSION  $PORT
version=$(grep -w image ../conf/${GROUP_NAME}-${SVC_NAME}.yml |awk -F: '{print $NF}')
#更新pod
#if [ "$VERSION" = "$version" ];then
  #pod_name=$(kubectl get pods -o wide |grep ${SVC_NAME}|awk '{print $1}')
  #kubectl delte ${pod_name} 
  kubectl delete -f  ../conf/${GROUP_NAME}-${SVC_NAME}.yml
  kubectl apply -f  ../conf/${GROUP_NAME}-${SVC_NAME}.yml
#else
#  sed -i "s;$VERSION;$version;"  ../conf/${GROUP_NAME}-${SVC_NAME}.yml
#  kubectl apply -f  ../conf/${GROUP_NAME}-${SVC_NAME}.yml
#fi
}

main

