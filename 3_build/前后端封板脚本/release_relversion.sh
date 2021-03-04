#!/bin/bash

set -o nounset
set -o errexit
#set -o pipefail

set_var () {
  REPO_URL="http://git.zanclick.cn/jtb/${GROUP_NAME}/$1.git"
    
  [[  -e ${BASE_DIR} ]] && rm -rf ${BASE_DIR} || { echo "${BASE_DIR} is not exists";exit 3;}
}

replace_version () {
  cd ${BASE_DIR}
  OLD_VERSION=`grep "</version>" ${BASE_DIR}/${2-}/pom.xml |awk -F '[<>]' 'NR==1{print $3}'`
  Result=`find ${BASE_DIR}/${2-} -name "pom.xml"`
  for dir in ${Result};do
    sed -i "s;${OLD_VERSION};$1;"  $dir
  done
  retval=`grep -w "$1"  ${BASE_DIR}/${2-}/pom.xml`
    if [ -z ${retval} ];then
      echo "Replace old version ${OLD_VERSION} failed,please check it"
      exit 3
    else
      echo "Replace old version ${OLD_VERSION} successful,and current version is $1"
    fi
}

replace_depend_version () {
  echo "Begin update jt-commons/jt-platfomre-core项目依赖版本"
  cd ${BASE_DIR} && \
  commons_version=`grep "<jt-commons"  pom.xml|awk -F '[<>]'  '{print $3}'`
  core_version=`grep "<jt-platform-core"  pom.xml|awk -F '[<>]'  '{print $3}'`
  
  local jt_commons_path=${GIT_DIR}/jt-commons
  local branch=1.1.x
  cd ${jt_commons_path} && \
  git checkout ${branch} && \
  Commons_version=`grep "<version>" pom.xml |awk -F '[<>]' 'NR==1{print $3}'`
  if [ ${commons_version} == ${Commons_version} ];then
     echo "依赖项目版本号一直，不需要修改..."
  else
     sed -i "s;${commons_version};${Commons_version};" ${BASE_DIR}/pom.xml
  fi
  echo "Update jt-commons/jt-platfomre-core项目依赖版本 finished"
}


mvn_compile () {
  mvn clean  &&  mvn install  -Dmaven.test.skip=true
  result=$?
  if [ ${result} -eq 0 ];then
    echo "Mvn compile and build ${NEW_VERSION} version  successful"
  else
    echo "Mvn compile and build ${NEW_VERSION} version  failed"
    exit 4
  fi
}

deploy_operation () {
  git checkout master && \
  git add . && \
  git commit -m "版本修改${REL_VERSION}" && \
  git push   && \
  git checkout ${BRANCH} && \
  git merge master && \
  git push origin ${BRANCH}
}

release_version () {
  set_var  && \
  cd ${BASE_DIR} && \
  git checkout ${BRANCH} && \
  replace_version  ${NEW_VERSION}
  mvn_compile
  git add . && \
  git commit -m "版本发布${NEW_VERSION}" && \
  git push origin ${BRANCH}
}

change_dir () {
  #切换工作目录

  cd $1 && \
  git clone ${REPO_URL} && \
  [[ -d ${BASE_DIR} ]] &&  cd ${BASE_DIR} || { echo "${BASE_DIR} is not exists"; exit 1; }
}

get_code () {
  # 获取源码
  
  set_var
  change_dir ${GIT_DIR}
  replace_version ${REL_VERSION} && \
  mvn_compile
  deploy_operation
}

archive () {
  #合并代码

  git chckout ${BRANCH}
  git merge master && 
  git push origin ${BRANCH}
}

release_jt_platform () {
  #获取代码,打包发布jt-platform项目
  
  set_var
  
  change_dir ${GIT_DIR}
  replace_version ${NEW_VERSION}
  mvn_compile
  archive
}

release_jt_platform_web () {
  #获取代码，打包发布jt-platform-web项目

  change_dir ${GIT_DIR}/web-front
  archive

  #开发版本发布
  cd ${GIT_DIR}/web-front/${GROUP_NAME}
  git checkout master
  OLD_VERSION=`grep "prodVersion"  ./src/main.js |awk -F"[']" '{print $(NF-1)}'`
  sed -i "s;${OLD_VERSION};${NEW_VERSION};" ./src/main.js
  git add . && \
  git commit -m "版本发布${NEW_VERSION}"
  git push 
}

release_jt_platform_whyg () {
 
 set_var

 cd ${BASE_DIR} 
 pro_name=$(ls)
 change_dir ${GIT_DIR}
 
 for item in ${pro_name};do
   replace_version ${REL_VERSION} ${item} 
   cd ${BASE_DIR}/${home_dir}
   mvn_compile
 done
 deploy_operation
}

release_jt_platform_ytsf () {
  
  set_var
 
  pro_name=platform-provider-report-ytsf
  home_dir=${BASE_DIR}/${pro_name}

  change_dir ${GIT_DIR}
  replace_version ${REL_VERSION} ${home_dir} 
  cd ${home_dir}
  mvn_compile
  deploy_operation 
}

usage () {
 #help message

 cat << EOF

Usage:  $(basename $0) [option] [newVersion] [oldVersion]

Avaiable option:
  jt-commons           will release jt-commons project 
  jt-platform-core     will release jt-platform-core project 
  jt-platform          will release jt-platform project
  jt-platform-web      will release jt-platform-web project
  jt-gateway           will release jt-gateway project
  jt-gateway-calc      will release jt-gateway-calc project
  jt-platform-whyg     will release jt-platform-whyg project
  jt-platform-ytsf     will release jt-platform-ytsf project

Flag:
  oldVersion           is your project's current release version,such as "1.0.22.RELEASE"
  newVersion           is your current release version add one, such as "1.0.23.RELEASE"

Example:
  [release jt-commons project]          $(basename $0)  jt-commons  1.0.23.RELEASE 1.0.22.RELEASE
  [release jt-platform-core project]    $(basename $0)  jt-platform-core  1.0.23.RELEASE 1.0.22.RELEASE
  [release jt-platform project]         $(basename $0)  jt-platform  1.0.23.RELEASE
  [release jt-platform-web project]     $(basename $0)  jt-platform-web  v1.0.23
  [release jt-gateway project]          $(basename $0)  jt-gateway  1.0.23.RELEASE 1.0.22.RELEASE
  [release jt-gateway-calc project]     $(basename $0)  jt-gateway-calc  1.0.23.RELEASE 1.0.22.RELEASE
  [release jt-platform-whyg project]    $(basename $0)  jt-platform-whyg  1.0.23.RELEASE 1.0.22.RELEASE
  [release jt-platform-ytsf project]    $(basename $0)  jt-platform-ytsf  1.0.23.RELEASE 1.0.22.RELEASE
EOF
  exit 1
}

[[ $# -eq 0 ]] && usage
if [ $1 == "jt-platform" ] || [ $1 == "jt-platform" ];then
   [[ $# -eq 2 ]] || usage 
else
   [[ $# -ne 3 ]] && usage
fi

PROJECT_NAME=$1
NEW_VERSION=$2
REL_VERSION=$3
GIT_DIR=/data/jtb/infra/git
BASE_DIR=${GIT_DIR}/$1

case $1 in
  jt-platform-core | jt-commons)
    GROUP_NAME=jtb-core
    BRANCH=1.1.x
    release_version
    ;;
  jt-platform)
    GROUP_NAME=jtb-platform
    BRANCH=1.0.x
    set_var && \
    release_jt_platform
    ;;
  jt-platform-web)
    GROUP_NAME=jtb-platform
    BRANCH=1.0.x
    release_jt_platform_web
    ;;
  jt-gateway | jt-gateway-calc)
    GROUP_NAME=jtb-gateway
    BRANCH=1.1.x
    release_version
    ;;
  jt-platform-whyg)
    GROUP_NAME=jtb-whyg
    BRANCH=1.0.x
    release_jt_platform_whyg
    ;;
  jt-platform-ytsf)
    GROUP_NAME=jtb-ytsf
    BRANCH=1.0.x
    release_jt_platform_ytsf
    ;;
  *)
    usage
esac
