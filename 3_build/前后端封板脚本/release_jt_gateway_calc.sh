#!/bin/bash
BASE_DIR=/data/jtb/infra/git/jt-gateway-calc
REPO_URL="http://git.zanclick.cn/jtb/jtb-gateway/jt-gateway-calc.git"
BRANCH=1.1.x
NEW_VERSION=$1

check_basic () {
  if [  -e ${BASE_DIR} ];then
     rm -rf ${BASE_DIR}
  fi

  if [ -z ${NEW_VERSION} ];then
      echo "Usage:you need add new version,for example:1.0.3.RELEASE and so on "
      exit 2
  fi
}

replace_version () {
  cd /data/jtb/infra/git && \
  git clone ${REPO_URL} && \
  [ -d ${BASE_DIR} ] &&  cd ${BASE_DIR} || { echo "${BASE_DIR} is not exists"; exit 1; }
  git checkout master && \
  OLD_VERSION=`grep "</version>" $BASE_DIR/pom.xml |awk -F '[<>]' 'NR==1{print $3}'`
  if [[ ${OLD_VERSION} == ${NEW_VERSION} ]];then
     echo "VERSION is same,please check it.."
     exit 1
  fi
  Result=`find ${BASE_DIR} -name "pom.xml"`
  for dir in ${Result};do
    sed -i "s;${OLD_VERSION};${NEW_VERSION};"  $dir
  done
  retval=`grep -w "${NEW_VERSION}"  ${BASE_DIR}/pom.xml`
    if [ -z ${retval} ];then
      echo "Replace old version ${OLD_VERSION} failed,please check it"
      exit 3
    else
      echo "Replace old version ${OLD_VERSION} successful,and current version is ${NEW_VERSION}"
    fi
}


mvn_compile () {
  cd ${BASE_DIR} && \
  mvn clean  && \
  mvn install
  result=$?
  if [ ${result} -eq 0 ];then
    echo "Mvn compile and build ${NEW_VERSION} version  successful"
  else
    echo "Mvn compile and build ${NEW_VERSION} version  failed"
    exit 4
  fi
}

git_operation () {
  cd ${BASE_DIR} && \
  git checkout master && \
  git add . && \
  git commit -m "版本发布${NEW_VERSION}" && \
  git push   && \
  git checkout ${BRANCH} && \
  git reset --hard HEAD
  git pull &&  \
  git merge master && \
  git push origin ${BRANCH}
}

main () {
  check_basic  &&  \
  replace_version  && \
  mvn_compile  && \
  git_operation
}

main
