#!/bin/bash
export REGISTRY_MIRROR="CN"
export DOCKER_VER=18.09.7
export K8S_BIN_VER=v1.15.0
export EXT_BIN_VER=0.3.0
export SYS_PKG_VER=0.3.2

mkdir -p /opt/kube/bin /etc/docker /etc/ansible/{down,bin} /data/kubernetes/docker

function install_docker() {
  # check if a container runtime is already installed
  systemctl status docker|grep Active|grep -q running && { echo "[WARN] docker is already running."; return 0; }
  systemctl status containerd|grep Active|grep -q running && { echo "[ERROR] containerd is running, unsupported."; exit 1; }

  if [[ "$REGISTRY_MIRROR" == CN ]];then
    DOCKER_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/x86_64/docker-${DOCKER_VER}.tgz"
  else
    DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VER}.tgz"
  fi

#  mkdir -p /opt/kube/bin /etc/docker /etc/ansible/{down,bin} /data/kubernetes/docker
  if [[ -f "/etc/ansible/down/docker-${DOCKER_VER}.tgz" ]];then
    echo "[INFO] docker binaries already existed"
  else
    echo -e "[INFO] \033[33mdownloading docker binaries\033[0m $DOCKER_VER"
    if [[ -e /usr/bin/curl ]];then
      curl -C- -O --retry 3 "$DOCKER_URL" || { echo "[ERROR] downloading docker failed"; exit 1; }
    else
      wget -c "$DOCKER_URL" || { echo "[ERROR] downloading docker failed"; exit 1; }
    fi
    mv ./docker-${DOCKER_VER}.tgz /etc/ansible/down
  fi

  tar zxf /etc/ansible/down/docker-${DOCKER_VER}.tgz -C /etc/ansible/down && \
  mv /etc/ansible/down/docker/* /opt/kube/bin && \
  ln -sf /opt/kube/bin/docker /bin/docker

echo "[INFO] generate docker service file"
  cat > /etc/systemd/system/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io
[Service]
Environment="PATH=/opt/kube/bin:/bin:/sbin:/usr/bin:/usr/sbin"
ExecStart=/opt/kube/bin/dockerd
ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process
[Install]
WantedBy=multi-user.target
EOF

 echo "[INFO] generate docker config file"
  if [[ "$REGISTRY_MIRROR" == CN ]];then
    echo "[INFO] prepare register mirror for $REGISTRY_MIRROR"
    cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://dockerhub.azk8s.cn", "https://docker.mirrors.ustc.edu.cn"],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
    },
  "data-root": "/data/kubernetes/docker"
}
EOF
  else
    echo "[INFO] standard config without registry mirrors"
    cat > /etc/docker/daemon.json << EOF
{
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
    },
  "data-root":/data/kubernetes/docker"
}
EOF
  fi

  if [[ -e /etc/centos-release || -e /etc/redhat-release ]]; then
    echo "[INFO] turn off selinux in CentOS/Redhat"
    setenforce 0
    echo "SELINUX=disabled" > /etc/selinux/config
  fi

  echo "[INFO] enable and start docker"
  systemctl enable docker
  systemctl daemon-reload && systemctl restart docker && sleep 8
}

function get_k8s_bin() {
  [[ -f "/etc/ansible/bin/kubelet" ]] && { echo "[WARN] kubernetes binaries existed"; return 0; }

  echo -e "[INFO] \033[33mdownloading kubernetes\033[0m $K8S_BIN_VER binaries"
  docker pull wushaoyu/kubernetes-bin:${K8S_BIN_VER} && \
  echo "[INFO] run a temporary container" && \
  docker run -d --name temp_k8s_bin wushaoyu/kubernetes-bin:${K8S_BIN_VER} && \
  echo "[INFO] cp k8s binaries" && \
  docker cp temp_k8s_bin:/k8s /k8s_bin_tmp && \
  mv /k8s_bin_tmp/* /etc/ansible/bin && \
  echo "[INFO] stop&remove temporary container" && \
  docker rm -f temp_k8s_bin && \
  rm -rf /k8s_bin_tmp
}

function get_ext_bin() {
  [[ -f "/etc/ansible/bin/etcdctl" ]] && { echo "[WARN] extral binaries existed"; return 0; }

  echo -e "[INFO] \033[33mdownloading extral binaries\033[0m kubeasz-ext-bin:$EXT_BIN_VER"
  docker pull wushaoyu/kubernetes-extra-bin:${EXT_BIN_VER} && \
  echo "[INFO] run a temporary container" && \
  docker run -d --name temp_ext_bin wushaoyu/kubernetes-extra-bin:${EXT_BIN_VER} && \
  echo "[INFO] cp extral binaries" && \
  docker cp temp_ext_bin:/extra /extra_bin_tmp && \
  mv /extra_bin_tmp/* /etc/ansible/bin && \
  echo "[INFO] stop&remove temporary container" && \
  docker rm -f temp_ext_bin && \
  rm -rf /extra_bin_tmp
}

function get_offline_image() {
  # images needed by k8s cluster
  calicoVer=v3.4.4
  corednsVer=1.5.0
  dashboardVer=v1.10.1
  flannelVer=v0.11.0-amd64
  heapsterVer=v1.5.4
  metricsVer=v0.3.3
  pauseVer=3.1
  traefikVer=v1.7.12

  imageDir=/etc/ansible/down
  [[ -d "$imageDir" ]] || { echo "[ERROR] $imageDir not existed!"; exit 1; }

  echo -e "[INFO] \033[33mdownloading offline images\033[0m"

  if [[ ! -f "$imageDir/calico_$calicoVer.tar" ]];then
    docker pull calico/cni:${calicoVer} && \
    docker pull calico/kube-controllers:${calicoVer} && \
    docker pull calico/node:${calicoVer} && \
    docker save -o ${imageDir}/calico_${calicoVer}.tar calico/cni:${calicoVer} calico/kube-controllers:${calicoVer} calico/node:${calicoVer}
  fi
  if [[ ! -f "$imageDir/coredns_$corednsVer.tar" ]];then
    docker pull coredns/coredns:${corednsVer} && \
    docker save -o ${imageDir}/coredns_${corednsVer}.tar coredns/coredns:${corednsVer}
  fi
  if [[ ! -f "$imageDir/dashboard_$dashboardVer.tar" ]];then
    docker pull mirrorgooglecontainers/kubernetes-dashboard-amd64:${dashboardVer} && \
    docker save -o ${imageDir}/dashboard_${dashboardVer}.tar mirrorgooglecontainers/kubernetes-dashboard-amd64:${dashboardVer}
  fi
  if [[ ! -f "$imageDir/flannel_$flannelVer.tar" ]];then
    docker pull easzlab/flannel:${flannelVer} && \
    docker save -o ${imageDir}/flannel_${flannelVer}.tar easzlab/flannel:${flannelVer}

  fi
  if [[ ! -f "$imageDir/heapster_$heapsterVer.tar" ]];then
    docker pull mirrorgooglecontainers/heapster-amd64:${heapsterVer} && \
    docker save -o ${imageDir}/heapster_${heapsterVer}.tar mirrorgooglecontainers/heapster-amd64:${heapsterVer}
  fi
  if [[ ! -f "$imageDir/metrics-server_$metricsVer.tar" ]];then
    docker pull mirrorgooglecontainers/metrics-server-amd64:${metricsVer} && \
    docker save -o ${imageDir}/metrics-server_${metricsVer}.tar mirrorgooglecontainers/metrics-server-amd64:${metricsVer}
  fi
  if [[ ! -f "$imageDir/pause_$pauseVer.tar" ]];then
    docker pull mirrorgooglecontainers/pause-amd64:${pauseVer} && \
    docker save -o ${imageDir}/pause_${pauseVer}.tar mirrorgooglecontainers/pause-amd64:${pauseVer}
  fi
  if [[ ! -f "$imageDir/traefik_$traefikVer.tar" ]];then
    docker pull traefik:${traefikVer} && \
    docker save -o ${imageDir}/traefik_${traefikVer}.tar traefik:${traefikVer}
  fi
}


install_docker && \
get_k8s_bin && \
get_ext_bin && \
get_offline_image
