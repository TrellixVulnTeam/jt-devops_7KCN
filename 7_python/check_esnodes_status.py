#!/usr/bin/python

from __future__ import print_function

import sendmail
import subprocess

def get_es_status(cmd):
    check_result = subprocess.check_call(cmd, shell=True)
    
def cmd(es_node,port):
    check_cmd = "curl http://{0}:{1}/_cat/nodes?v"
    return check_cmd.format(es_node,port)

def main():
    es_node = "10.111.30.3"
    port = "9200"
    get_es_status(cmd(es_node,port))

if __name__ == "__main__":
    main()
