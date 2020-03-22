#!/bin/bash
TARGET_PATH=/data/jtb/infra/git/web-front/jt-platform-web
NEW_VERSION=$1
BRANCH=1.0.x
TIME=`date +%Y%m%d`
URL=http://git.zanclick.cn/jtb/jtb-platform/jt-platform-web.git

check_basic () {
  if [ -e ${TARGET_PATH} ];then
    rm -rf ${TARGET_PATH}
  fi
  if [ -z ${NEW_VERSION} ];then
    echo "You need add one parameter..,for example 1.0.2.RELEASE "
    exit 2
  fi 

}

replace_version () {
  cd /data/jtb/infra/git/web-front  && \
  git clone  $URL && \
  [ -d ${TARGET_PATH} ] &&  cd ${TARGET_PATH} || { echo "${TARGET_PATH} is not exists"; exit 1; }
  git checkout ${BRANCH} && \
  git pull && \
  git merge master  && \
  git push origin ${BRANCH}


git_operation () {
  cd ${TARGET_PATH} && \
  git checkout master && \
  OLD_VERSION=`grep "prodVersion"  ${TARGET_PATH}/src/main.js |awk -F"[']" '{print $(NF-1)}'`
  sed -i "s;${OLD_VERSION};${NEW_VERSION};" ${TARGET_PATH}/src/main.js
  git add . && \
  git commit -m "版本发布${NEW_VERSION}"
  git push                                            #最后push提交修改的版本号
}


check_basic && \
replace_version && \
git_operation
