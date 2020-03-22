#!/usr/bin/python
# -*- conding: utf-8 -*-

from __future__ import print_function
import sendmail
import subprocess
import os

def check_mail():
    flag = True
    if os.path.exists('sendmail.py'):
        flag = True
    else:
        flag = False
    return flag
     

def main():
    if check_mail():
        output = subprocess.check_output("kubectl get pods|awk 'NR>1{print $3}'",shell=True)
        lines=output.split('\n')
        for item in lines[0:-1]:
            print(item)
            if item != "Running":
                sendmail.send_mail('wushaoyu95@163.com','wsy123456','15071244227@139.com',"Message from 112.35.6.145","Error pod status in 112.35.6.145")
                break
            else:
                pass
    else:
        print("sendmail module is not exists,please check it...")


if __name__ == "__main__":
    main()
