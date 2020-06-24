#!/bin/bash
KAFKA_DIR=/data/jtb/infra/kafka_2.12-2.2.0/bin
KAKFA_NODES="192.168.0.2:9092,192.168.0.3:9092,192.168.0.4:9092"
GROUP_NAME=gateway-calc-trip
MAIL_TO="15071244227@139.com,wushaoyu95@163.com"
TIME=`date +'%F %R'`
LOG=/tmp/trip.log
PORT=21002

delete_pod() {
  get_trip_threadpool
  pod_name=`kubectl get pods -o wide |grep "gateway-calc-trip" |awk '{print $1}'` 
  echo "[WARN]begin delete gateway-calc-trip pod..." >>  ${LOG}
  for item  in ${pod_name};do
    echo "begin delete pod..." >>  ${LOG}
    kubectl delete pod $item
  done
  echo "delete pod successful.."  >> ${LOG}
}

get_trip_threadpool() {
  pod_ip=`kubectl get pods -o wide |grep gateway-calc-trip|awk 'NR==1{print$6}'`
  curl ${pod_ip}:${PORT}/jtb/executors/dump |python -m json.tool >> ${LOG}
}

main () {
  cd ${KAFKA_DIR}  &&  \
  consum_result=`./kafka-consumer-groups.sh --bootstrap-server=${KAKFA_NODES}  --group=${GROUP_NAME} --describe|grep -w "loc"|awk '{print $6}'` &&  \
  retval=`echo ${consum_result} |grep "consumer"`
  if [ -z $retval ];then
     echo "[WARN]云途三方gateway-calc-trip消费异常,请注意..." |mail -s "云途三方gateway-calc-trip消费情况" ${MAIL_TO}
     echo "[WARN] at $TIME" >> ${LOG}
     delete_pod
  else
     echo "gateway-calc-trip消费正常..."
  fi
}

main
