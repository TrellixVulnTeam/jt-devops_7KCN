#!/bin/sh
source ../../utils.sh

NODE_IPS="192.168.0.2 \
        192.168.0.3 \
        192.168.0.4 \
        192.168.0.5"

install_pack python && \
install_pack python-pip && \

# 配置ansible免密登录
# 更安全 Ed25519 算法
ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519 & \
# 或者传统 RSA 算法
ssh-keygen -t rsa -b 2048 -N '' -f ~/.ssh/id_rsa & \
{ for node_ip in ${NODE_IPS}; do
    ssh-copy-id ${node_ip}
  done
} & \

# 下载工具脚本easzup，举例使用kubeasz版本2.0.2
export release=2.0.2
curl -C- -fLO --retry 3 https://github.com/easzlab/kubeasz/releases/download/${release}/easzup && \
chmod +x ./easzup && \
# 使用工具脚本下载
./easzup -D && \

cd /etc/ansible && cp example/hosts.multi-node hosts