#!/bin/sh

PACK_DOWNLOAD_URL=http://192.168.0.4:9002/packages

LOCAL_PACK_ROOT=/usr/local
JDK_TAR=${LOCAL_PACK_ROOT}/jdk-8u201-linux-x64.tar.gz
MVN_TAR=${LOCAL_PACK_ROOT}/apache-maven-3.6.1-bin.tar.gz

PACK_LIST="jdk-8u201-linux-x64.tar.gz \
        apache-maven-3.6.1-bin.tar.gz"

download_pack() {
    local pack_name=$1
    echo "Downloading ${pack_name}"
    wget ${PACK_DOWNLOAD_URL}/${pack_name}
}

download_packs() {
    cd ${LOCAL_PACK_ROOT}
    for pack in ${PACK_LIST}; do
        download_pack ${pack}
    done
}

set_env_vars() {
    echo "Ready to set java environment..." >> $log
    { for pack in ${PACK_LIST}; do
        pack_dir=${LOCAL_PACK_ROOT}/${pack}
        echo "Unpacking ${pack_dir} ..."
        tar -xf ${pack_dir} && rm -f ${pack_dir}
    done
    } && \
    echo "Setting environment variables..." && \
{ cat >> /etc/profile  << EOF
#add java path
export JAVA_HOME=/usr/local/jdk1.8.0_201
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar:${JAVA_HOME}/lib
#add maven path
export MVN_HOME=/usr/local/apache-maven-3.6.1
export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:${MVN_HOME}/bin:$PATH
EOF
} && \
    echo "path variable set finishd" >> $log
}

set_hosts() {
    echo "Setting hosts..."
{ cat >> /etc/hosts << EOF
# hosts for common components
192.168.0.3 config.zhkj.com
192.168.0.2 logstash.zhkj.com
192.168.0.2 es1.zhkj.com
192.168.0.5 es2.zhkj.com
192.168.0.4 es3.zhkj.com
EOF
}
}

download_packs && \
set_env_vars && \
set_hosts