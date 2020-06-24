#该脚本用于在测试环境Jenkins，发布其他环境的服务

HARBOR_PREFIX=harbor.zhkj.com/jtb
IP=10.111.30.8
PORT=2022

#拉取、导出镜像
docker   pull  ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${VERSION} && \
docker  save  -o  /data/platform/jt-platform-${SVC_NAME}-${VERSION}.tar   ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${VERSION}   && \
echo "导出镜像 successful.."

#传送、导入镜像
scp  -P${PORT}  /data/platform/jt-platform-${SVC_NAME}-${VERSION}.tar     ${IP}:/root/   && \
ssh ${IP} -p${PORT}  docker load -i  /root/jt-platform-${SVC_NAME}-${VERSION}.tar    && \
echo "传送镜像 successful.." 

#推送镜像到harbor仓库
ssh ${IP} -p${PORT} docker push ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${VERSION}   && \
echo "推送镜像successful"   && \


#更新
ssh ${IP} -p${PORT} kubectl delete -f /opt/build/platform/jt-platform-${SVC_NAME}.yml
ssh ${IP} -p${PORT} kubectl create -f /opt/build/platform/jt-platform-${SVC_NAME}.yml --record
#ssh ${IP} -p${PORT} kubectl apply -f /opt/build/platform/jt-platform-${SVC_NAME}.yml

#清除打包的镜像 
ssh ${IP} -p${PORT}  rm -f  /root/jt-platform-${SVC_NAME}-${VERSION}.tar
ssh ${IP} -p${PORT}  docker  rmi  ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${VERSION}

#清除本地镜像
rm -f  /data/platform/jt-platform-${SVC_NAME}-${VERSION}.tar
docker  rmi  ${HARBOR_PREFIX}/jt-platform-${SVC_NAME}:${VERSION}
