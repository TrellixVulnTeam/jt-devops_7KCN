#!/bin/sh

SVC_NAME=$1
VERSION=$2
PORT=$3
JAVA_OPTS="-Xms1024m -Xmx1024m -XX:-TieredCompilation -Xmn512m -Xss512k -XX:+UseG1GC -XX:+UseStringDeduplication"

function logger() {
    TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
    case "$1" in
    debug)
        echo -e "$TIMESTAMP \033[36mDEBUG\033[0m $2"
        ;;
    info)
        echo -e "$TIMESTAMP \033[32mINFO\033[0m $2"
        ;;
    warn)
        echo -e "$TIMESTAMP \033[33mWARN\033[0m $2"
        ;;
    error)
        echo -e "$TIMESTAMP \033[31mERROR\033[0m $2"
        ;;
    *)
        ;;
    esac
}

function usage() {

    cat << EOF
### 使用帮助
../bin/$(basename $0)  [app_name]  [app_version]  [app_port]

Example:
    ../bin/$(basename $0)  platform-provider-org 1.0.21.BUILD-SNAPSHOT 8090

Flag:
    You must chdir to your jar dir,then execute this script.
EOF
}


# 构建应用镜像
function build_image() {
    logger info "开始构建${SVC_NAME}应用镜像..."
    rm -f ./Dockerfile
    (
    cat<<EOF
    FROM openjdk:8-jdk-slim-zh

    ENV TZ=Asia/Shanghai

    ADD ${SVC_NAME}-${VERSION}.jar ${SVC_NAME}.jar

    RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
    EXPOSE ${PORT}

    ENTRYPOINT java \${JAVA_OPTS} -Duser.timezone=GMT+08 -Djava.security.egd=file:/dev/./urandom -jar ${SVC_NAME}.jar --spring.profiles.active=prod
EOF
    ) >Dockerfile

    docker build -t jt-${SVC_NAME}:${VERSION} .
    logger info "应用${SVC_NAME}镜像构建成功"
}

function check_basic_image() {
    logger info "检查openjdk基础镜像是否存在"
    docker images|grep openjdk |grep "8-jdk-slim-zh" > /dev/null 2>1 || { logger error "Openjdk基础镜像不存在，请先导入openjdk:8-jdk-slim-zh基础镜像"; exit 1; }
    logger info "Openjdk基础镜像已存在"
}   


function get_container_msg() {
    docker ps -a |grep -q  ${SVC_NAME}
    if [ $? -eq 0 ];then
        container_name=`docker ps -a |grep ${SVC_NAME}|awk '{print $NF}'`
        container_id=`docker ps -a |grep ${SVC_NAME}|awk '{print $1}'`
        image_msg=`docker inspect -f {{.Image}}  ${SVC_NAME}`
        image_id=`awk -F: '{print substr($NF,1,12)}' <<< ${image_msg}`
    fi
    container_name=${container_name:-None}
    container_id=${container_id:-None}
    image_id=${image_id:-None}
}

function check_container() {
    get_container_msg  && \
    if [ ${container_name} != 'None' ];then
        logger info "应用${SVC_NAME}已运行,容器ID为:${container_id};镜像ID为:${image_id}"
        logger info "开始停止并删除应用${SVC_NAME}容器..."
        docker stop ${SVC_NAME} > /dev/null && docker rm ${SVC_NAME} > /dev/null
        logger info "旧版${SVC_NAME}应用已清除"
    else
        logger info "应用${SVC_NAME}未运行"
    fi
}

# 启动应用容器
function  run_container() {
    check_container &&  \
    logger info "开始启动新的${SVC_NAME}应用"
    docker run -d  --restart=always --net=host   --name ${SVC_NAME} jt-${SVC_NAME}:${VERSION} >/dev/null 2>1  && \
    sleep 2
    get_container_msg  && \
    logger info "应用${SVC_NAME}启动成功"
    logger info "新版${SVC_NAME}应用发布成功;容器ID为:${container_id};镜像ID为:${image_id}"
    logger debug "删除${SVC_NAME}-${VERSION}.jar"
    rm -f ${SVC_NAME}-${VERSION}.jar
}

[[ $# -ne 3 ]] && { logger error "Invalid parameters"; usage; exit 1; }

function main() {
    check_basic_image && \
    build_image   &&  \
    run_container
}

main
