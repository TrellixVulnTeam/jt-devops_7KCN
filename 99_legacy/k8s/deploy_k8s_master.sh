#!/bin/sh
echo "部署K8S Master节点..."
# K8S_VERSION=v1.15.1
# images=(kube-apiserver:${K8S_VERSION} kube-controller-manager:${K8S_VERSION} kube-scheduler:${K8S_VERSION} kube-proxy:${K8S_VERSION} \
# pause:3.1 etcd:3.3.10 coredns:1.3.1)
# for imageName in ${images[@]}; do
# 	docker pull registry.cn-hangzhou.aliyuncs.com/k8sth/${imageName} && \
# 	docker tag registry.cn-hangzhou.aliyuncs.com/k8sth/${imageName} k8s.gcr.io/${imageName} && \
# 	docker rmi registry.cn-hangzhou.aliyuncs.com/k8sth/${imageName}
# done
kubeadm init --image-repository=registry.aliyuncs.com/google_containers --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --ignore-preflight-errors=Swap