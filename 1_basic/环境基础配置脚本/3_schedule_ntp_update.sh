#!/bin/sh

echo "Scheduling ntp update task..."

chkconfig --level 3 crond on && \
service crond restart &&


#echo '*/5 * * * * /usr/sbin/ntpdate time.windows.com >/dev/null 2>&1' >>/var/spool/cron/root && \
#echo '*/10 * * * * /usr/sbin/ntpdate time.nist.gov >/dev/null 2>&1' >>/var/spool/cron/root

echo '*/30 * * * * /usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1' >>/var/spool/cron/root