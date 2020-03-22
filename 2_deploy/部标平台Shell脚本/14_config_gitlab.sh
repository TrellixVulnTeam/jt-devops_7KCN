#!/bin/bash
DIR=/data/jtb/infra/gitlab
if [ ! -e ${DIR} ];then 
  mkdir ${DIR}
  mkdir ${DIR}/config
  mkdir ${DIR}/data
  mkdir ${DIR}/logs
fi

docker run -d -p 2222:22 -p 4443:443 -p 8888:80 \
--name gitlab --restart always \
-v ${DIR}/config:/etc/gitlab \
-v ${DIR}/data/:/var/opt/gitlab \
-v ${DIR}/logs:/var/log/gitlab gitlab/gitlab-ce
