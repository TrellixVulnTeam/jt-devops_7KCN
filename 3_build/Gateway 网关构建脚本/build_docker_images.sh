#!/bin/sh

GROUP_NAME=$1
SVC_NAME=$2
VERSION=$3

OLD_IFS="$IFS" 
IFS="," 
PORTS=($4) 
IFS="$OLD_IFS"
PORTS_STR=""

for port in ${PORTS[@]}
do
    PORTS_STR="${PORTS_STR} ${port}"
done

rm -rf ./Dockerfile
(
cat<<EOF
FROM openjdk:8-jdk-slim-zh

ENV TZ=Asia/Shanghai
ENV JAVA_OPTS=""

ADD ${GROUP_NAME}-${SVC_NAME}-${VERSION}.jar ${SVC_NAME}.jar

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
EXPOSE ${PORTS_STR}

ENTRYPOINT java \${JAVA_OPTS} -Duser.timezone=GMT+08 -Djava.security.egd=file:/dev/./urandom -jar ${SVC_NAME}.jar --spring.profiles.active=prod
EOF
) >Dockerfile

docker build -t ${GROUP_NAME}-${SVC_NAME}:${VERSION} .
