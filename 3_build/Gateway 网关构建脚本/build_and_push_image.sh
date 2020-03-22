#!/bin/sh

GROUP_NAME=$1
SVC_NAME=$2
VERSION=$3
PORTS=$4

../bin/build_docker_images.sh ${GROUP_NAME} ${SVC_NAME} ${VERSION} ${PORTS} && \
docker tag ${GROUP_NAME}-${SVC_NAME}:${VERSION} harbor.zhkj.com/jtb/${GROUP_NAME}-${SVC_NAME}:${VERSION} && \
docker push harbor.zhkj.com/jtb/${GROUP_NAME}-${SVC_NAME}:${VERSION}