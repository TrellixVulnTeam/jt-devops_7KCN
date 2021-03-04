#!/usr/bin/env python
# -*- coding:utf8 -*-

from __future__ import print_function

import subprocess
import os
import tarfile
import paramiko


def cmd():
    cmd = "mvn {0} && mvn {1}"
    return cmd.format('clean', 'install')


def runcmd(command):
    subprocess.check_call(command, shell=True)


def unpack_socketio(target_dir, package_name,svc_name):
    os.chdir(target_dir)
    with tarfile.open(package_name, mode='r') as out:
        out.extractall(".")
    if os.path.exists(svc_name):
	print('socketio压缩包解压成功')

def get_pid(host):
    try:
        data = subprocess.check_output('ssh {0} "ps -ef|grep socketio|grep -v grep"'.format(host), shell=True)
        result = data.split()
        return result[1]
    except Exception:
        print("Socketio service has stopped...")


def transfer(pid,dir,host,target_dir,svc_name):
    lib_dir = os.path.join(dir,'lib')
    bin_sh = os.path.join(dir,'bin','startup.sh')
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host)
    stdin,stdout,stderr = ssh.exec_command("rm -rf {0}".format(lib_dir))
    os.chdir(os.path.join(target_dir,svc_name))
    print('当前目录是:',os.getcwd())
    print('运行脚本是:',bin_sh)
    subprocess.check_call('scp -r lib {0}:{1}'.format(host,dir),shell=True)
    print('reulst is--------------------- ',pid)
    if pid:
        stdin,stdout,stderr = ssh.exec_command("kill -9 {0}".format(pid))
        print('Will to restart socketio')
        #ssh.exec_command("source {0} && {1}".format('/etc/profile',bin_sh))
        subprocess.check_call('ssh {0} "source {1} && sh {2}"'.format(host,'/etc/profile',bin_sh),shell=True)
        print('socketio has release successful')
    else:
        print('Will to start socketio')
        #ssh.exec_command("sh {}".format(bin_sh))
        subprocess.check_call('ssh {0} "source {1} && sh {2}"'.format(host,'/etc/profile',bin_sh),shell=True)
        print('socketio has release successful')
    ssh.close()


def main():
    host = "192.168.2.3"
    svc_name = "socketio-1.0"
    dir = "/data/jtb/socektio-1.0"
    base_dir = os.getcwd()
    target_dir = os.path.join(base_dir, 'socketio-server', 'target')
    package_name = svc_name + '-assembly.tar.gz'
    runcmd(cmd())
    unpack_socketio(target_dir,package_name,svc_name)
    transfer(get_pid(host),dir,host,target_dir,svc_name)


if __name__ == "__main__":
    main()
