#!/bin/bash
TIME=`date +%Y%m%d_%H%M`
GATEWAY_ROOT=/data/jtb/jt-gateway
DOWN_ROOT=/data/jtb

SVC_LIST="jt-gateway-1078 \
          jt-gateway-808 \
          jt-gateway-809-down \
          jt-gateway-809-up \
          jt-gateway-809-down-xg \
          jt-gateway-809-up-whyg"

DOWN_LIST="jt-gateway-809-down-jtj \
          jt-gateway-809-down-za"


[[ -d ${GATEWAY_ROOT} ]] || { echo "[WARN] ${GATEWAY_ROOT} is not exits!"; exit 1; }
[[ -d ${DOWN_ROOT} ]] || { echo "[WARN] ${DOWN_ROOT} is not exits!"; exit 2; }

tar_consolelog () {
  for svc in ${SVC_LIST};do 
    cd ${GATEWAY_ROOT}/${svc}/logs && \
    tar -czf console_${TIME}.tar.gz  console.log && \ 
    (
    cat /dev/null > console.log
    )
  done
  #find ${GATEWAY_ROOT} -mtime +10 -name *.tar.gz  -exec rm -f {} \;
}

tar_jtdown () {
  for down in ${DOWN_LIST};do
    cd ${DOWN_ROOT}/${down}/logs && \
    tar -czf console_${TIME}.tar.gz   console.log && \ 
    (
    cat /dev/null > console.log
    )
    #find ${DOWN_ROOT}/${down}  -mtime +10 -name *.tar.gz  -exec rm -f {} \;
  done
}

tar_consolelog
tar_jtdown


find ${GATEWAY_ROOT} -mtime +10 -name "*.tar.gz"  -exec rm -f {} \;
find ${DOWN_ROOT}/jt-gateway-809-down-jtj  -mtime +10 -name "*.tar.gz"  -exec rm -f {} \;
find ${DOWN_ROOT}/jt-gateway-809-down-za  -mtime +10 -name "*.tar.gz"  -exec rm -f {} \;
