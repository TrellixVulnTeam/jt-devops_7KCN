#该脚本用于 手动构建发布平台

SVC_NAME=$1
HARBOR_PREFIX=harbor.zhkj.com/jtb
BASE_DIR="/data/jtb/infra/git/jt-platform"
LIB_DIR="/opt/build/platform"


cd ${BASE_DIR} 
is_provider=$(echo "${SVC_NAME}"|sed -n '/^provider-.*/p')
is_endpoint=$(echo "${SVC_NAME}"|sed -n '/^endpoint-.*/p')

mvn_compile () {
    cd platform-endpoint/
    mvn clean && mvn install -Dmaven.test.skip=true
    cd ../platform-provider-api
    mvn clean && mvn install -Dmaven.test.skip=true
    cd ../
    if [[ ${is_provider} ]];then
        cd platform-provider/
    fi
    if [[ ${is_endpoint} ]];then
        cd platform-endpoint/
    fi
    pwd
    
    cd platform-${SVC_NAME}
    mvn clean && mvn install   -Dmaven.test.skip=true
    PORT=$(awk "/${SVC_NAME}/{print $NF}" /data/jtb/bin/platform_port.log|awk '{print $2}')
    version=`awk '/<version>[^<]+<\\/version>/{gsub(/<version>|<\\/version>/,"",$1);print $1;exit;}' pom.xml`
    cp -f target/platform-${SVC_NAME}-${version}.jar ${LIB_DIR}/lib/
}

pwd

build_image () {
    cd ${LIB_DIR}/lib
    ../bin/build_docker_image.sh platform-${SVC_NAME} ${version} ${PORT} && \
    
    #docker tag jt-platform-${SVC_NAME}:${version} ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${version} && \
    #docker push ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${version}
    # 
    #
    ## 目前测试阶段没有版本控制，所以这里需要先delete然后再apply，后续直接apply即可
    #kubectl delete -f ../conf/jt-platform-${SVC_NAME}.yml
    #kubectl apply -f  ../conf/jt-platform-${SVC_NAME}.yml --record
    #
    ##kubectl apply -f  ../platform/jt-platform-${SVC_NAME}.yml --record
    #
    #docker  rmi  jt-platform-${SVC_NAME}:${version}
    #docker  rmi  ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${version}
}

mvn_compile
build_image
