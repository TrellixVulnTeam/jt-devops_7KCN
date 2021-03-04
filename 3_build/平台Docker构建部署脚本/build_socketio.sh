#!/bin/bash

NAME="socketio-server"
VERSION="1.0.10.BUILD-SNAPSHOT"
JAVA_OPTS="-Xms1024m -Xmx1024m -XX:-TieredCompilation -Xmn512m -Xss512k -XX:+UseG1GC -XX:+UseStringDeduplication"


function build_image() {
    cat > Dockerfile << EOF
FROM openjdk:8-jdk-slim-zh

ENV TZ=Asia/Shanghai
ENV JAVA_OPTS=""

ADD  ${NAME}-${VERSION}.jar   ${NAME}-${VERSION}.jar

RUN ln -snf /usr/share/zoneinfo/ /etc/localtime && echo  > /etc/timezone
EXPOSE 11005

ENTRYPOINT java ${JAVA_OPTS} -Duser.timezone=GMT+08 -Djava.security.egd=file:/dev/./urandom -jar ${NAME}-${VERSION}.jar --spring.profiles.active=prod
EOF
    docker build -t ${NAME}:${VERSION} .
}

function get_container_msg() {
    docker ps |grep -q  ${NAME}
    if [ $? -eq 0 ];then
        container_name=`docker ps |grep ${NAME}|awk '{print $NF}'`
        container_id=`docker ps |grep ${NAME}|awk '{print $1}'`
        image_msg=`docker inspect -f {{.Image}}  ${NAME}`
        image_id=`awk -F: '{print substr($NF,1,12)}' <<< ${image_msg}`
    fi
    container_name=${container_name:-None}
    container_id=${container_id:-None}
    image_id=${image_id:-None}
    echo "---------应用${NAME}信息如下----------"
       
}

function check_container() {
    get_container_msg
    if [ ${container_name} != 'None' ];then
        echo -e "\033[1;35m正在清除旧版${NAME}应用容器\033[0m"
        docker stop ${NAME} > /dev/null && docker rm ${NAME} > /dev/null
        echo -e "\033[1;35m旧版${NAME}应用已停\n原容器ID为:${container_id}\n原镜像ID为:${image_id}\033[0m"
    else
        echo -e "\033[1;35m${NAME}应用未运行\033[0m"
    fi
}

function  run_container() {
    check_container
    docker run -d  --restart=always --net=host  --name ${NAME} ${NAME}:${VERSION}  && \
    sleep 2
    get_container_msg
    echo -e "\033[1;32m新版${NAME}应用发布成功\n新容器ID为:${container_id}\n新镜像ID为:${image_id}\033[0m"
}
  
function main() {
    build_image
    run_container
}

main
