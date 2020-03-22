#!/bin/bash
TIME=$(date +%F)
809_POD=$(kubectl get pods |grep 809-up|awk '{print $1}')
CONFIG_POD=$(kubectl get pods |grep config-server|awk '{print $1}')
TERMINAL_POD=$(kubectl get pods |grep terminal|awk '{print $1}')

list="809-up config-server terminal"

delete_809log () {
 for number in `seq 0 50`;do
   cmd jt-gateway-809-up
 done
}

delete_configlog () {
 number=0
   cmd configcenter
}

delete_terminallog () {
 for number in `seq 0 1`;do
   cmd  providerterminal
 done
}

cmd () {
  parameter=$1
  echo $parameter
  if [[ ${pod} == terminal ]];then
    Number=$(echo ${pod_name} |grep -o ${pod} |awk '{a[$0]++} END{for (i in a) {print i"\t"a[i]; }}'|awk '{print $2}')
    if [ $Number -ne 1 ];then
      for item in ${pod_name};do
        #${pod_name}=$item
        #execute 
        kubectl exec -it ${item} -- ls -l /logs/$1-${TIME}.${number}.log
        ret=$?
        if [ $ret -eq 0 ];then
           kubectl exec -it ${item} -- rm -f  /logs/$1-${TIME}.${number}.log
        fi
      done
    else
      execute
    fi
  else
    execute
  fi
}

execute () {
  kubectl exec -it ${pod_name} -- ls -l /logs/$parameter-${TIME}.${number}.log
  ret=$?
  if [ $ret -eq 0 ];then
     kubectl exec -it ${pod_name} -- rm -f  /logs/$parameter-${TIME}.${number}.log
  fi
}

main () {
for pod in ${list};do
  pod_name=$(kubectl get pods |grep ${pod}|awk '{print $1}')
  if [[ ${pod} == "809-up" ]];then
    delete_809log
  elif [[ ${pod} == "config-server" ]];then
    delete_configlog
#  elif [[ ${pod} == "terminal" ]];then
#    delete_terminallog
  fi
done
}

main
