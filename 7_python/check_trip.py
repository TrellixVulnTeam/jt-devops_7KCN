#!/usr/bin/python

from __future__ import print_function
import subprocess
import re

def execute_cmd(kafka_cmd,path):
    output = subprocess.Popen(kafka_cmd, cwd=path, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = output.communicate()
    if output.returncode == 0:
        return output.returncode, stdout
    return output.returncode, stderr

def get_status(kafka_cmd,path,group_name):
    returncode, out = execute_cmd(kafka_cmd,path)
    if returncode == 0:
        try:
            re.match('consumer',out) 
            print('yes')
        except:
#            delete_pod(group_name)
            print('no')
        raise SystemExit("execute {0} successful:{1}".format(kafka_cmd,out))
    else:
        raise SystemExit("execute {0} error:{1}".format(kafka_cmd,out))


def check_consumer(kafka_nodes,group_name):
    kafka_cmd = "./kafka-consumer-groups.sh --bootstrap-server={0}  --group={1} --describe"
    return kafka_cmd.format(kafka_nodes,group_name)

#def delete_pod(group_name):
#    l = []
#    parameter = "$6"
#    get_cmd = 'kubectl get pods -o wide|grep -i running|grep {0} |awk "{print {1}}"'.format(group_name,parameter)
#    pod_ip = subprocess.check_output(get_cmd,shell=True) 
#    l.appned(pod_ip)
#    for item in l:
#        subprocess.call('kubectl delete pod item',shell=True)

def main():
    path = '/data/jtb/infra/kafka_2.12-2.2.0/bin/'
    kafka_nodes = "10.111.30.3:9092,10.111.30.10:9092,10.111.30.5:9092"
    group_name = "gateway-calc-trip"

    get_status(check_consumer(kafka_nodes,group_name),path,group_name)


if __name__ == "__main__":
    main()
