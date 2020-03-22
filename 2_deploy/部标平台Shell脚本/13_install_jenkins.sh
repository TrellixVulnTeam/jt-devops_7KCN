#!/bin/bash
RPM_PATH=/root/jenkins-2.180-1.1.noarch.rpm
JENKINS_HOME=/data/jtb/infra/jenkins
CONF=/etc/sysconfig/jenkins
LOG_DIR=/data/jtb/logs/jenkins
REPOSITORY_PATH=/root/.m2
REPOSITORY_TAR=/root/repository.tar.gz
PLUGIN_TAR=/root/plugins.tar.gz
PORT=8091
CMD=/etc/init.d/jenkins

check_tar () {
 #if [ ! -e ${PLUGIN_TAR} ];then
 #  echo "${PLUGIN_TAR} is not exits,please upload it first"
 #  exit 1
 #fi
 #if [ ! -e ${REPOSITORY_TAR} ];then
 #  echo "${REPOSITORY_TAR} is not exits,please upload it firest"
 #  exit 2
 #fi
 if [ ! -e ${LOG_DIR} ];then
   mkdir ${LOG_DIR}
 fi
 if [ ! -e ${JENKINS_HOME} ];then
   mkdir ${JENKINS_HOME}
 fi
 #if [ ! -e ${REPOSITORY_PATH} ];then
 #  mkdir ${REPOSITORY_PATH}
 #fi
}

#Notice:If you execute this shell script first faild,then you need modify /etc/init.d/jenkins where log_dir path
setup_jenkins () {
  #yum -y install ${RPM_PATH}
  sed -i "s;/var/log/jenkins;${LOG_DIR};" ${CMD}
  sed -r -i "s;^(JENKINS_HOME=).*;\1'"${JENKINS_HOME}"';" ${CONF}
  sed -r -i "s;^(JENKINS_PORT=).*;\1'"${PORT}"';"  ${CONF}
  chown jenkins:jenkins ${LOG_DIR}
  chown jenkins:jenkins ${JENKINS_HOME}
  ${CMD} start
}

configure_jenkins () {
  sed -r -i "s;^(JENKINS_USER=).*;\1'"root"';"  ${CONF}
  ${CMD} restart
  #tar -xf ${REPOSITORY_TAR} -C ${REPOSITORY_PATH}
  #tar -xf /root/plugins.tar.gz -C ${JENKINS_HOME}
}

check_tar && \
setup_jenkins && \
configure_jenkins
