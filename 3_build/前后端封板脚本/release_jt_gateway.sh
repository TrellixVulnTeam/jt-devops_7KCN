#!/bin/bash
TARGET_PATH=/data/jtb/infra/git/jt-gateway
#OLD_VERSION=`grep "</version>" $TARGET_PATH/pom.xml |awk -F '[<>]' 'NR==1{print $3}'`
NEW_VERSION=$1
BRANCH=1.0.x
TIME=`date +%Y%m%d`
URL=http://git.zanclick.cn/jtb/jtb-gateway/jt-gateway.git

check_basic () {
  if [  -e ${TARGET_PATH} ];then
     rm -rf ${TARGET_PATH}
  fi
  
  if [ -z ${NEW_VERSION} ];then
      echo "Usage:you need add new version,for example:1.0.3.RELEASE and so on "
      exit 2
  fi
}

replace_version () {
  cd /data/jtb/infra/git && \
  git clone $URL && \
  [ -d ${TARGET_PATH} ] &&  cd ${TARGET_PATH} || { echo "${TARGET_PATH} is not exists"; exit 1; }
  git checkout master && \
  OLD_VERSION=`grep "</version>" $TARGET_PATH/pom.xml |awk -F '[<>]' 'NR==1{print $3}'`
  Result=`find ${TARGET_PATH} -name "pom.xml"`
  for dir in ${Result};do
    sed -i "s;${OLD_VERSION};${NEW_VERSION};"  $dir
  done
  retval=`grep -w "${NEW_VERSION}"  ${TARGET_PATH}/pom.xml`
    if [ -z ${retval} ];then
      echo "Replace old version ${OLD_VERSION} failed,please check it"
      exit 3
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
    echo "Mvn compile and build ${NEW_VERSION} version  successful"
  else
    echo "Mvn compile and build ${NEW_VERSION} version  failed"
    exit 4
  fi
}

git_operation () {
  cd ${TARGET_PATH} && \
  git checkout master && \
  git add . && \
  git commit -m "版本发布${NEW_VERSION}"
  git push                                               #最后push提交修改的版本号
  #git tag -a "${NEW_VERSION}" -m "${NEW_VERSION}" && \   #打标签及备注
  #git push origin ${NEW_VERSION}  && \                   #将本地tag推向远程仓库，默认提交git push时，标签及合并的分支不会推向远程仓库
  git checkout ${BRANCH} && \                            #切换分支
  git reset --hard HEAD
  git pull 
  git merge master && \                                  #合并master分支到1.0.x
  git push origin ${BRANCH}                          #将本地新合并的1.0.x分支推向远程仓库,默认提交git push时，标签及合并的分支不会推向远程仓库,否则在后面修改开发版本提交时会出现冲突
}


check_basic && \
replace_version && \
mvn_compile &&  \
git_operation
