#!/bin/bash


set -o nounset
#set -o errexit


NODE_EXPORTER_VERSION="0.18.0"
NODE_EXPORTER_PORT=59100
INSTALL_DIR=/data/jtb/infra


[[ -d ${INSTALL_DIR} ]] || mkdir -p ${INSTALL_DIR}


check_docker_status () {
    systemctl status docker|grep -q running
    status=$?
}   

docker_node_exporter () {
    docker pull prom/node-exporter:v${NODE_EXPORTER_VERSION}  && \
    docker run -itd -p ${NODE_EXPORTER_PORT}:9100 --restart=always --name=node-exporter  prom/node-exporter:v${NODE_EXPORTER_VERSION}
}

local_node_exporter () {
    [[ ! -f /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz ]] && \
        wget -O /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz  https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
    tar -xf  /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz  -C ${INSTALL_DIR}
    cp ${INSTALL_DIR}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter  /usr/bin/

    cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target
[Service]
ExecStart=/usr/bin/node_exporter \
          --web.listen-address=:${NODE_EXPORTER_PORT}
[Install]
WantedBy=multi-user.target
EOF

    systemctl status node_exporter
    systemctl daemon-reload && systemctl start  node_exporter
}

check_run_status () {
    netstat -anp|grep -q ${NODE_EXPORTER_PORT}
    val=$?
    if [ ${val} -eq 0 ];then
        echo $1
    else
        echo $2
    fi
}

main () {
    check_docker_status
    if [ $status -eq 0 ];then
        echo "[INFO] Begin pull node-exporter image..."
        docker_node_exporter
        check_run_status  "[INFO] Node-exporter container start successful" "[WARN] Node-exporter container start faild"
    else
        echo "[INFO] Begin download node-exporter package..."
        local_node_exporter
        check_run_status "[INFO]Node-exporter is start successful..." "[WARN]Node-exporter is start faild..."
    fi
}

main
