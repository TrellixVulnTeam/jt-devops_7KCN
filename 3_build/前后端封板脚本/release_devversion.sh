#!/bin/bash
BASE_DIR=/data/jtb/infra/git
NEW_VERSION=$1
SERVICE=$2

if [ ${SERVICE} == "jt-platform" ];then
  TARGET_PATH=${BASE_DIR}/${SERVICE}
elif [ ${SERVICE} == "jt-gateway" ];then
  TARGET_PATH=${BASE_DIR}/${SERVICE}
elif [ ${SERVICE} == "jt-gateway-calc" ];then
  TARGET_PATH=${BASE_DIR}/${SERVICE}
elif [ ${SERVICE} == "jt-commons" ];then
  TARGET_PATH=${BASE_DIR}/${SERVICE}
elif [ ${SERVICE} == "jt-platform-core" ];then
  TARGET_PATH=${BASE_DIR}/${SERVICE}
else
  echo "No this project...${SERVICE}"
  exit 1
fi

echo ${TARGET_PATH}
OLD_VERSION=`grep "</version>" $TARGET_PATH/pom.xml |awk -F '[<>]' 'NR==1{print $3}'`

if [ -z ${NEW_VERSION} ];then
    echo "Usage:you need add new version and service name,for example:1.0.3.RELEASE platform"
    exit 2
fi
if [ -z ${SERVICE} ];then
    echo "Usage:you need add new version and service name,for example:1.0.3.RELEASE platform"
    exit 3
fi


replace_version () {
  cd ${TARGET_PATH} && \
  git checkout master && \
  git reset --hard HEAD && \
  git pull  && \
  Result=`find ${TARGET_PATH} -name "pom.xml"`
  for dir in ${Result};do
    sed -i "s;${OLD_VERSION};${NEW_VERSION};"  $dir
  done
  retval=`grep -w "${NEW_VERSION}"  ${TARGET_PATH}/pom.xml`
    if [ -z ${retval} ];then
      echo "Replace old version ${OLD_VERSION} failed,please check it"
      exit 1
    else
      echo "Replace old version ${OLD_VERSION} successful,and current version is ${NEW_VERSION}"
    fi
}

mvn_compile () {
  cd ${TARGET_PATH} && \
  mvn clean  && \
  mvn install
  result=$?
  if [ ${result} -eq 0 ];then
    echo "Mvn compile and build ${NEW_VERSION} version  successful" && \
    git add .  && \
    git commit -m "开发版本发布:${NEW_VERSION}" && \
    git push
  else
    echo "Mvn compile and build ${NEW_VERSION} version  failed"
    exit 4
  fi
}

#git_operation () {
#  git checkout master 
#  git add . && \
#  git commit -m "开发版本更新${NEW_VERSION}" && \
#  git push  
#}

replace_version && \
mvn_compile
#git_operation
