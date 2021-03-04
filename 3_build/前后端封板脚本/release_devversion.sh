#!/bin/bash

BASE_DIR=/data/jtb/infra/git
COMMONS_DIR=/data/jtb/infra/git/jt-commons
CORE_DIR=/data/jtb/infra/git/jt-platform-core
PLATFORM_DIR=/data/jtb/infra/git/jt-platform
GATEWAY_DIR=/data/jtb/infra/git/jt-gateway
CALC_DIR=/data/jtb/infra/git/jt-gateway-calc


P_VERSION=1.0.X
G_VERSION=1.1.X
SWITCH=0
SERVICE=$1
NEW_VERSION=$2

check_basic_message () {
  if [ -z ${NEW_VERSION} ];then
      echo "Usage:you need add new version and service name,for example:platform 1.0.3.RELEASE"
      exit 2
  fi
  if [ -z ${SERVICE} ];then
      echo "Usage:you need add new version and service name,for example:platform 1.0.3.RELEASE"
      exit 3
  fi
  #if [ -e ${TARGET_PATH} ];then
  #  echo ${TARGET_PATH} && \
  #  rm -rf ${TARGET_PATH}
  #fi
}

replace_version () {
  echo ${TARGET_PATH} && cd ${TARGET_PATH} && \
  git checkout master && \
  OLD_VERSION=`grep "</version>" ${TARGET_PATH}/pom.xml |awk -F '[<>]' 'NR==1{print $3}'`
  Result=`find ${TARGET_PATH} -name "pom.xml"`
  for item in ${Result};do
    sed -i "s;${OLD_VERSION};${NEW_VERSION};"  $item
  done
  retval=`grep -w "${NEW_VERSION}"  ${TARGET_PATH}/pom.xml`
    if [ -z ${retval} ];then
      echo "Replace old version ${OLD_VERSION} failed,please check it"
      exit 1
    else
      echo "Replace old version ${OLD_VERSION} successful,and current version is ${NEW_VERSION}"
    fi
}

replace_platform_version () {
  cd  ${COMMONS_DIR} && \
  git checkout master && \
  COMMON_VERSION=`grep "</version>" pom.xml |awk -F '[<>]' 'NR==1{print $3}'`

  cd ${TARGET_PATH} && \
  git checkout master && \
  commons_version=`grep "<jt-commons"  pom.xml|awk -F '[<>]'  '{print $3}'`
  sed -i "s;${commons_version};${COMMON_VERSION};" pom.xml
  replace_version
}

replace_gateway_version () {
  cd ${PLATFORM_DIR}  && \
  git checkout master && \
  PLAT_VERSION=`grep "</version>" pom.xml |awk -F '[<>]' 'NR==1{print $3}'` 

  cd ${TARGET_PATH} && \
  git checkout master
  platform_version=`grep "<jt-platform.version>"  pom.xml|awk -F '[<>]'  '{print $3}'`
  sed -i "s;${platform_version};${PLAT_VERSION};" pom.xml
  replace_version
}


replace_whyg_version () {
  cd ${TARGET_PATH} && \
  dir_list=`ls`
  git checkout master && \
  Result=`find ${TARGET_PATH}/platform-provider-dashboard-whyg -name "pom.xml"|head -1`
  result=`find ${TARGET_PATH} -name "pom.xml"`
  PLAT_VERSION=`grep "</version>" ${Result} |awk -F '[<>]' 'NR==1{print $3}'`
  for item in $result;do
    sed -i "s;${PLAT_VERSION};${NEW_VERSION};" ${item}
  done
  for item in ${dir_list};do
    cd ${TARGET_PATH}/$item && mvn clean && mvn install -Dmaven.test.skip=true
  done
  cd ${TARGET_PATH} && \
  git add .  && \
  git commit -m "开发版本发布:${NEW_VERSION}" && \
  git push
}


replace_ytsf_version () {
  cd ${TARGET_PATH} && \
  dir_list=`ls`
  git checkout master && \
  Result=`find ${TARGET_PATH}/platform-provider-report-ytsf -name "pom.xml"|head -1`
  result=`find ${TARGET_PATH} -name "pom.xml"`
  PLAT_VERSION=`grep "</version>" ${Result} |awk -F '[<>]' 'NR==1{print $3}'`
  for item in $result;do
    sed -i "s;${PLAT_VERSION};${NEW_VERSION};" ${item}
  done
  for item in ${dir_list};do
    cd ${TARGET_PATH}/$item && mvn clean && mvn install -Dmaven.test.skip=true
  done
  git add .  && \
  git commit -m "开发版本发布:${NEW_VERSION}" && \
  git push
}



mvn_compile () {
  cd ${TARGET_PATH} && \
  mvn clean  && \
  mvn install -Dmaven.test.skip=true
  result=$?
  if [ ${result} -eq 0 ];then
    echo "Mvn compile and build ${NEW_VERSION} version  successful" 
    git add .  && \
    git commit -m "开发版本发布:${NEW_VERSION}" && \
    git push
  else
    echo "Mvn compile and build ${NEW_VERSION} version  failed"
    exit 4
  fi
}

case $SERVICE in
    "jt-commons")
        TARGET_PATH=${BASE_DIR}/${SERVICE}
        check_basic_message
        replace_version
        mvn_compile
        ;;
    "jt-platform-core")
        TARGET_PATH=${BASE_DIR}/${SERVICE}
        check_basic_message
        replace_version
        mvn_compile
        ;;
    "jt-platform")
        TARGET_PATH=${BASE_DIR}/${SERVICE}
        check_basic_message
        replace_platform_version
        mvn_compile
        ;;
    "jt-platform-whyg")
        TARGET_PATH=${BASE_DIR}/${SERVICE}
        check_basic_message
        replace_whyg_version
        ;;
    "jt-platform-ytsf")
        TARGET_PATH=${BASE_DIR}/${SERVICE}
        check_basic_message
        replace_ytsf_version   
        ;;
    "jt-gateway")
        TARGET_PATH=${BASE_DIR}/${SERVICE}
        check_basic_message
        replace_gateway_version
        mvn_compile
        ;;
    "jt-gateway-calc")
        TARGET_PATH=${BASE_DIR}/${SERVICE}
        check_basic_message
        replace_gateway_version
        mvn_compile
        ;;
    *)
      echo "No this project...${SERVICE}"
esac
