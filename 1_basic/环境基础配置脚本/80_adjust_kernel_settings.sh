#!/bin/sh

lock_sys_file() {
    file_name=$1
    echo "Locking ${file_name} ..."
    chattr +i ${file_name}
}

change_fd_limit() {
    echo "Changing fd limit..."
    limit=$(ulimit -n) && \
    echo "  current fd limit: ${limit}"
    echo '*  -  nofile  65535' >> /etc/security/limits.conf && \
    cat /etc/security/limits.conf && \

    { cat >>/etc/rc.local<<EOF
#open files
ulimit -HSn 65535
#stack size
ulimit -s 65535
EOF
    }
}

set_kernel_params() {
    echo "Changing kernel params..." && \
{ cat >>/etc/sysctl.conf<<EOF
# added by admin
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time =600
net.ipv4.ip_local_port_range = 1024    65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
EOF
}   
}

lock_sys_files() {
    echo "Locking important system files..."
    SYS_FILES="/etc/passwd /etc/inittab /etc/group /etc/shadow /etc/gshadow"
    for sys_file in ${SYS_FILES}; do
        lock_sys_file ${sys_file}
    done
    mv /usr/bin/chattr /usr/bin/admchattr
}

change_fd_limit && \
set_kernel_params && \
lock_sys_files

