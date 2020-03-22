#!/bin/bash
CONF=/etc/vsftpd/vsftpd.conf
MIN_PORT=9122
MAX_PORT=9123


install_ftp () {
 yum -y install vsftpd
 cp ${CONF} ${CONF}.bak
 sed -r -i "s;^(anonymous_enable=).*;\1NO;"  ${CONF}   && \
 sed -r -i "s;^(connect_from_port_20=).*;\1NO;" ${CONF}  && \
 sed -r -i "s;^(#)(chroot_local_user=YES);\2;"  ${CONF}  && \
 sed -r -i "s;^(listen=).*;\1YES;"   ${CONF}   && \
 sed -r -i "s;^(listen_ipv6=).*;\1NO;"  ${CONF}  && \
 echo "allow_writeable_chroot=YES" >>  ${CONF}  && \
 echo "pasv_enable=YES" >>    ${CONF}  && \
 echo "pasv_min_port=${MIN_PORT}" >>  ${CONF}  && \
 echo "pasv_max_port=${MAX_PORT}" >>  ${CONF}  && \
 systemctl start vsftpd
 systemctl enable vsftpd
}


install_ftp
