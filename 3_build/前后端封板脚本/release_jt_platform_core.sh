#!/bin/bash
BASE_DIR=/data/jtb/infra/git/jt-platform-core
REPO_URL="http://git.zanclick.cn/jtb/jtb-core/jt-platform-core.git"
BRANCH=1.1.x
NEW_VERSION=$1
REL_VERSION=$2

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
  cd ${BASE_DIR}
  OLD_VERSION=`grep "</version>" $BASE_DIR/pom.xml |awk -F '[<>]' 'NR==1{print $3}'`
  Result=`find ${BASE_DIR} -name "pom.xml"`
  for dir in ${Result};do
    sed -i "s;${OLD_VERSION};$1;"  $dir
  done
  retval=`grep -w "$1"  ${BASE_DIR}/pom.xml`
    if [ -z ${retval} ];then
      echo "Replace old version ${OLD_VERSION} failed,please check it"
      exit 3
    else
      echo "Replace old version ${OLD_VERSION} successful,and current version is $1"
    fi
}

mvn_compile () {
  mvn clean  && \
  mvn install  -Dmaven.test.skip=true
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
  cd ${BASE_DIR} && \
  git checkout ${BRANCH} && \
  replace_version  ${NEW_VERSION}
  mvn_compile
  git add . && \
  git commit -m "版本发布${NEW_VERSION}" && \
  git push origin ${BRANCH}
}

get_code () {
  cd /data/jtb/infra/git && \
  git clone ${REPO_URL} && \
  [ -d ${BASE_DIR} ] &&  cd ${BASE_DIR} || { echo "${BASE_DIR} is not exists"; exit 1; }
  replace_version ${REL_VERSION} && \
  mvn_compile
  deploy_operation
}


main () {
  check_basic  &&  \
  get_code && \
  release_version
}

main
