#脚本用于平台Jt-platform项目,提交代码，自动触发构建发布

Path=/data/jtb/infra/jenkins/jobs/${JOB_NAME}/builds
echo ${Path}

#定义变量
is_provider=$(echo "${SVC_NAME}"|sed -n '/^provider-.*/p')
is_endpoint=$(echo "${SVC_NAME}"|sed -n '/^endpoint-.*/p')
HARBOR_PREFIX=harbor.zhkj.com/jtb
TEMP=/tmp/temp.log

#获取本次构建的模块名称
SVC_NAME=`grep message ${Path}/${BUILD_NUMBER}/log |sed -n '1p'|awk '{print substr($3,2)}'`
BRANCH=`grep message ${Path}/${BUILD_NUMBER}/log |sed -n '1p'|awk '{print $4}'`

#获取提交信息是否符合标准，不符合则停止构建(主要判断是否开头为provider开头。例provider-report)
echo "${SVC_NAME}"
if [ ${SVC_NAME} == "Merge" ];then
  unset ${SVC_NAME}
  Number=`expr ${BUILD_NUMBER} - 1`
  SVC_NAME=`grep message ${Path}/${Number}/log |sed -n '1p'|awk '{print substr($3,2)}'`
else
  name=`echo ${SVC_NAME}|awk -F-  '{print $1}'`
  if [ -z ${name} ] || [ ${name} != provider ];then
     echo -e "[ERROR] Your commit message do not match standard service name，so stop this build.."
     exit 0
  fi
fi
echo "${SVC_NAME}"

#获取提交的代码分支，若为1.0.x则进行自动构建发布，若为其他则停止构建
if [ ${BRANCH} != "1.0.x" ];then
   echo -e "[ERROR] Your commit message do not match standard  branch，so stop this build.."
   exit 0
fi

mvn_compile () {
cd platform-parent/
mvn clean && mvn install

cd ../platform-commons/
mvn clean && mvn install

cd ../platform-core/
mvn clean && mvn install

cd ../platform-endpoint/platform-endpoint-contract/
mvn clean && mvn install
}

release_newversion () {
PORT=$(awk "/$1/{print $NF}" ${JENKINS_HOME}/platform_port.log|awk '{print $2}') && \
version=$(awk '/<version>[^<]+<\/version>/{gsub(/<version>|<\/version>/,"",$1);print $1;exit;}' pom.xml) && \
cp -f target/platform-$1-${version}.jar /opt/build/lib  && \
cd /opt/build/lib && \
../bin/build_docker_image.sh $1 ${version} ${PORT} && \
docker tag jt-platform-$1:${version} ${HARBOR_PREFIX}/jt-platform-$1:${version} && \
docker push ${HARBOR_PREFIX}/jt-platform-$1:${version}
kubectl delete -f ../platform/jt-platform-$1.yml
kubectl create -f ../platform/jt-platform-$1.yml --record
docker  rmi  jt-platform-$1:${version}
docker  rmi  ${HARBOR_PREFIX}/jt-platform-$1:${version}
}

#判断提交记录中是否包含多个服务,若包含多个则进行多个服务发布,否则进行单个服务发布
echo ${SVC_NAME} > ${TEMP}
number=$(grep -o "provider" ${TEMP}| awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}')
echo $number
if [ ${number} -eq 1 ];then
  echo "begin mvn"
  mvn_compile
  cd ${WORKSPACE}/platform-provider/platform-${SVC_NAME}
  mvn clean && mvn install
  release_newversion  ${SVC_NAME}
else
  sed -i "s/,/ /g" ${TEMP}
  cat ${TEMP} && \
  mvn_compile  && \
  pwd
  for service in $(cat ${TEMP});do
    cd ${WORKSPACE}/platform-provider/platform-${service}  && \
    mvn clean && mvn install
    release_newversion ${service}
  done
fi
