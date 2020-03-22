#!/bin/bash
PORT=3307
#LICENSE="BDZiYWU2ZGZhODhhYzQ0Nzk5ZWQ1YmU0MzQ2NmUwODhiAAAAAAAAAAAEAAAAAAAAAAwwNQIYPNwKJjUHuuZQUyaihg5p87gov8BOErnsAhkA8SL6j52kG1um9Fd2MA4gVDJwyETpizW2AA=="
PASS=GIPA5k#HoAaps8
#Tips:before you execute this shell script,you must list all memsql cluster ip   in variable,IP1,IP2,IP3 and so on.
IP1=10.111.30.3
IP2=`ifconfig eth0|awk 'NR==2{print $2}'`
IP3=10.111.30.5
SSH_PORT=2022
User=admin

MEMSQL_TOOLS="memsql-client-1.0.0-7e30b698e9.x86_64.rpm \
              memsql-studio-1.7.1-9754b6b8cc.x86_64.rpm \
              memsql-toolbox-1.2.2-bcf06f20a7.x86_64.rpm"

MEMSQL_SERVER=/root/memsql-server-6.8.6-5cec6e303c.x86_64.rpm

for tool in /root/${MEMSQL_TOOLS};do
  rpm -ivh ${tool}
done

ping -c 3 ${IP1} > /dev/null 2>&1 
retvel=$?
if [ ${retvel} -ne 0 ];then
   echo "Maybe you need ensure memsql cluster ip"
else
   echo "baisc enviroment is good"
fi

result=`id -u ${User}`
if [ -z ${result} ];then
  useradd ${User}
  echo ${User} |passwd --stdin ${User}
fi

su - ${User}  && \
ssh-keygen -t rsa  -f  ~/.ssh/id_rsa -N  ''   && \
for ip in ${IP1} ${IP2} ${IP3};do
  ssh-copy-id ${ip} 
done

memsql-deploy setup-cluster --high-availability=false --memsql-port ${PORT}  \
--file-path ${MEMSQL_SERVER}  \
--license BDZiYWU2ZGZhODhhYzQ0Nzk5ZWQ1YmU0MzQ2NmUwODhiAAAAAAAAAAAEAAAAAAAAAAwwNQIYPNwKJjUHuuZQUyaihg5p87gov8BOErnsAhkA8SL6j52kG1um9Fd2MA4gVDJwyETpizW2AA==  \
--master-host ${IP1}:${SSH_PORT}  \
--aggregator-hosts ${IP2}:${SSH_PORT}  \
--leaf-hosts ${IP3}:${SSH_PORT}   \
--password ${PASS}

memsql-admin list-nodes
