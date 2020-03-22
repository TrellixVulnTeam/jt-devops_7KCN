#!/bin/sh

HARBOR_VERSION=v1.8.1

wget -P /usr/local/src/ https://github.com/vmware/harbor/releases/download/${HARBOR_VERSION}/harbor-online-installer-${HARBOR_VERSION}.tgz

tar zxf harbor-online-installer-v1.2.0.tgz -C /usr/local/
