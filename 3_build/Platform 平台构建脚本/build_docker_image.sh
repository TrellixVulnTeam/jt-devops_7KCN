#!/bin/sh

SVC_NAME=$1
VERSION=$2
PORT=$3

rm -rf ./Dockerfile
(
cat<<EOF
FROM openjdk:8-jdk-slim-zh

ENV TZ=Asia/Shanghai
ENV JAVA_OPTS=""

ADD platform-${SVC_NAME}-${VERSION}.jar ${SVC_NAME}.jar

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
EXPOSE ${PORT}

ENTRYPOINT java \${JAVA_OPTS} -Duser.timezone=GMT+08 -Djava.security.egd=file:/dev/./urandom -jar ${SVC_NAME}.jar --spring.profiles.active=prod
EOF
) >Dockerfile

docker build -t jt-platform-${SVC_NAME}:${VERSION} .
