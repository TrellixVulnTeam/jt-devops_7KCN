#!/bin/sh

# 下面的两条需要从Master节点获取
JOIN_TOKEN=xsy8d9.oxu6ld10n1u819tx
JOIN_CA_HASH=0b780cdf4d296dfc4ec04265787decacc0197f5a811f1c54c1c72335b6f0d164

echo "初始化节点..."
kubeadm join 192.168.0.3:6443 --token ${JOIN_TOKEN} \
    --discovery-token-ca-cert-hash sha256:${JOIN_CA_HASH} \
    && --ignore-preflight-errors=Swap\

echo "更新节点配置..."
mkdir -p $HOME/.kube && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config && \

source /usr/share/bash-completion/bash_completion && \
echo 'source <(kubectl completion bash)' >>~/.bashrc && \
source ~/.bashrc && \

echo "配置cni插件(flannel)"
wget https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml && \
sed -i 's/quay.io/quay-mirror.qiniu.com/g' kube-flannel.yml && \
kubectl apply -f kube-flannel.yml