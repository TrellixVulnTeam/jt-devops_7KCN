#!/bin/sh

source ./utils.sh

YUM_PATH=/etc/yum.repos.d/

echo "Logging path is: ${LOG}"

change_yum_repo() {
    echo "Changing yum repository to faster image..."
    {
    if [[ -f "${YUM_PATH}/CentOS-Base.repo" ]];then
        mv ${YUM_PATH}/CentOS-Base.repo ${YUM_PATH}/CentOS-Base.repo.bak
    fi
    } && \
    cp conf/CentOS7-Base-163.repo ${YUM_PATH}/ && \
    yum clean all && \
    yum makecache
}

install_packs() {
    echo "Installing basic libraries and tools.."
    install_pack wget && \
    install_pack gcc && \
    install_pack vim && \
    install_pack ntpdate && \
    install_pack sysstat && \
    install_pack git   && \
	install_pack telnet && \
	install_pack tcpdump 
}

change_yum_repo && \
install_packs