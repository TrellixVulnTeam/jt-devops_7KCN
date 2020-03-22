#!/bin/sh
LOCAL_PACK_ROOT=/usr/local
JDK_TAR=/root/jdk-8u201-linux-x64.tar.gz
MVN_TAR=/root/apache-maven-3.6.1-bin.tar.gz
PROFILE=/etc/profile
DIR=/data/jtb
IP=`ifconfig eth0|awk 'NR==2{print $2}'`
NAME="logstash.zhkj.com"

PACK_LIST="jdk-8u201-linux-x64.tar.gz \
        apache-maven-3.6.1-bin.tar.gz"

RPM_LIST="wget \
          gcc \
          vim \
          ntpdate \
          telnet \
          sysstat \
          git \
          tcpdump \
          net-tools \
          auto-conf
          lrzsz"

if [ -z ${IP} ];then
  echo "You must first get ip,maybe you should check network card name"
  exit 4
else
  echo " ${IP} ${NAME}" >> /etc/hosts
fi


set_env_vars () {
    echo "Ready to set java environment..." 
    { for pack in ${PACK_LIST}; do
        pack_dir=/root/${pack}
        tar -xf ${pack_dir} -C /usr/local && rm -f ${pack_dir}
    done
    } && \
    echo "Setting environment variables..."
}

set_java_env () {
echo "#add java path" >> ${PROFILE}
echo "export JAVA_HOME=/usr/local/jdk1.8.0_201" >> ${PROFILE}
echo 'export JRE_HOME=${JAVA_HOME}/jre' >>  ${PROFILE}
echo 'export CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar:${JAVA_HOME}/lib' >> ${PROFILE}
echo "#add maven path" >> ${PROFILE}
echo "#export M2_HOME=/usr/local/apache-maven-3.6.1" >> ${PROFILE}
echo '#export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:${M2_HOME}/bin:$PATH' >> ${PROFILE}
source ${PROFILE}  && \
ln -s /usr/local/jdk1.8.0_201/bin/java   /usr/bin/java  && \
ln -s /usr/local/apache-maven-3.6.1/bin/mvn   /usr/bin/mvn 
}

install_packs () {
  echo "Install basic libraries and tools.."
  for rpm in ${RPM_LIST};do
     yum -y install ${rpm}
  done
} 

mkdir_dir () {
  mkdir -p ${DIR}
  mkdir ${DIR}/bin
  mkdir ${DIR}/infra
  mkdir ${DIR}/logs
  chown -R 755 ${DIR}
}
set_env_vars && \
set_java_env && \
install_packs && \
mkdir_dir
