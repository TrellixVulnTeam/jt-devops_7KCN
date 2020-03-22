#该脚本用于 手动构建发布平台

is_provider=$(echo "${SVC_NAME}"|sed -n '/^provider-.*/p')
is_endpoint=$(echo "${SVC_NAME}"|sed -n '/^endpoint-.*/p')

HARBOR_PREFIX=harbor.zhkj.com/jtb

cd platform-parent/
mvn clean && mvn install

cd ../platform-commons/
mvn clean && mvn install

cd ../platform-core/
mvn clean && mvn install

cd ../platform-endpoint/platform-endpoint-contract/
mvn clean && mvn install && \

cd ../..

if [[ ${is_provider} ]];then
   cd platform-provider/
fi
if [[ ${is_endpoint} ]];then
   cd platform-endpoint/
fi

pwd
cd platform-${SVC_NAME}
mvn clean && mvn install && \

version=`awk '/<version>[^<]+<\/version>/{gsub(/<version>|<\/version>/,"",$1);print $1;exit;}' pom.xml`

cp -f target/platform-${SVC_NAME}-${version}.jar /opt/build/lib



cd /opt/build/lib
../bin/build_docker_image.sh ${SVC_NAME} ${version} ${PORT} && \

docker tag jt-platform-${SVC_NAME}:${version} ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${version} && \
docker push ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${version}
 

# 目前测试阶段没有版本控制，所以这里需要先delete然后再apply，后续直接apply即可
kubectl delete -f ../platform/jt-platform-${SVC_NAME}.yml && \
kubectl apply -f ../platform/jt-platform-${SVC_NAME}.yml --record

#kubectl apply -f  ../platform/jt-platform-${SVC_NAME}.yml --record

docker  rmi  jt-platform-${SVC_NAME}:${version}
docker  rmi  ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${version}


#bugfix紧急修改版本
#Version=1.0.8.bugfix
#docker tag jt-platform-${SVC_NAME}:${version} ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${Version} && \
#docker push ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${Version}
#docker  rmi  jt-platform-${SVC_NAME}:${Version}
#docker  rmi  ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${Version}
