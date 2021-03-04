#!/bin/bash

SVC_NAME=$1
HARBOR_PREFIX=harbor.zhkj.com/jtb
GATEWAY_LIB=/opt/build/gateway/lib/
BASE_DIR=/data/jtb/infra/git/jt-gateway-calc
WORKSPACE=/data/jtb/bin/
VERSION=$(grep version ${BASE_DIR}/pom.xml |awk -F '[<>]' 'NR==2{print $3}')
GROUP_NAME="gateway-calc"
PORT=$(grep ${SVC_NAME} $WORKSPACE/platform_port.log|awk '{print $NF}')
echo ${SVC_NAME}


mvn_operation () {
  mvn clean && \
  mvn install
}


main () {
    cd ${BASE_DIR} && \
    cd gateway-calc-core && \
    mvn_operation  && \
    cd ../gateway-calc-app/${GROUP_NAME}-${SVC_NAME}  &&  \
    mvn_operation  && \
    cp ./target/${GROUP_NAME}-${SVC_NAME}-$VERSION.jar  ${GATEWAY_LIB}  && \
    cd ${GATEWAY_LIB} &&  \
    #打包推送镜像
    echo $PWD
    ../bin/build_and_push_image.sh ${GROUP_NAME}  ${SVC_NAME} $VERSION  $PORT
    #version=$(grep -w image ../conf/${GROUP_NAME}-${SVC_NAME}.yml |awk -F: '{print $NF}')
    #kubectl delete -f  ../conf/${GROUP_NAME}-${SVC_NAME}.yml
    #kubectl apply -f  ../conf/${GROUP_NAME}-${SVC_NAME}.yml
}

main
echo ${SVC_NAME}
