#!/bin/sh
source ../utils.sh

echo "1. 添加Hosts信息..."
{ cat >>/etc/hosts<<EOF
192.168.0.3 k8s.master
192.168.0.5 k8s.node1
192.168.0.4 k8s.node2
192.168.0.2 k8s.node3
EOF
} && \

echo "2. 添加yum源..."
cd /etc/yum.repos.d/
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo && \
{ cat > kubernetes.repo << EOF
[kubernetes]
name=Kubernetes Repo
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
enable=1
EOF
} && \

echo "3. 安装工具包..."
yum install -y docker-ce kubelet kubeadm kubectl && \
echo "3.1 配置Docker参数..."
groupadd docker && \
mkdir -p /etc/docker && \
{ cat > /etc/docker/daemon.json << EOF
{
 "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF
} && \
systemctl daemon-reload && \

yum install -y epel-release python-pip && \
pip install docker-compose & \
echo "3.2 完善kubectl自动补全..."
yum install bash-completion && \
source /usr/share/bash-completion/bash_completion && \
echo 'source <(kubectl completion bash)' >>~/.bashrc && \
kubectl completion bash >/etc/bash_completion.d/kubectl && \


echo "4. 调整内核参数..."
modprobe br_netfilter && \
{ cat >>/etc/sysctl.conf<<EOF
# added for docker
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
} && \

echo "5. 设置systemctl"
systemctl enable kubelet && \
systemctl enable docker && \

echo "6. 配置Kubelet忽略Swap"
change_conf_attr KUBELET_EXTRA_ARGS "--fail-swap-on=false" /etc/sysconfig/kubelet