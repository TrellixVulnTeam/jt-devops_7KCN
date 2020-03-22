本项目致力于提供快速部署高可用`k8s`集群的工具,本项目已根据部标平台(jt-platform)的实际情况，在原项目的基础上进行了修改，已和平台基础组件部署脚本配套使用，修改部分包括但不限于：修改kubernetes组件的数据安装目录为/data/kubernetes，修改部分内核参数优化参数，修改haproxy离线安装方式为从华为云下载安装，修改拉锯镜像的标签等等。


## 安装说明
根据集群节点在kubernetes的角色，修改hosts文件中kube-master和kube-node分组中对应的IP，若需要master节点高可用，可在kube-master主机分组下添加IP即可。

## 分布安装
- sh -x 00.pull_image.sh
- ansible-playbook 01.prepare.yml
- ansible-playbook 02.etcd.yml
- ansible-playbook 03.docker.yml
- ansible-playbook 04.kube-master.yml
- ansible-playbook 05.kube-node.yml
- ansible-playbook 06.network.yml
- ansible-playbook 07.harbor.yml
- ansible-playbook 08.cluster-addon.yml

注：持续更新