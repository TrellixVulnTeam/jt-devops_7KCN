#!/usr/bin/python
# -*- conding: utf-8 -*-

import subprocess
import os
import tarfile

def execute_cmd(cmd,compile_path):
    p = subprocess.Popen(cmd,
                         shell=True,
                         cwd=compile_path,
                         stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    if p.returncode != 0:
        return p.returncode, stderr
    return p.returncode, stdout

def unpack_nginx(package_dir):
    with tarfile.open(package_dir,mode='r')  as out:
        out.extractall(".")

def create_dir(infra_path):
    if not os.path.exists(infra_path):
        os.mkdir(infra_path)

def format_nginx_command(compile_path, infra_path, user):
    format_nginx = "{0} --prefix={1} --user={2} --group={2} --with-stream --with-http_ssl_module --with-http_stub_status_module --with-stream_ssl_module && make && make install"
    return format_nginx.format("./configure",infra_path,user)

def compile_nginx(cmd,compile_path):
    returncode, out = execute_cmd(cmd,compile_path)
    if returncode != 0:
        raise SystemExit("execute {0} error:{1}".format(cmd,out))
    else:
        raise SystemExit("execute ({0}) successful".format(cmd))

def main():
    user = 'nginx'
    package = 'nginx-1.14.2.tar.gz'
    version = 'os.path.splitext(os.path.splitext(package)[0])[0]'
    infra_path = '/data/jtb/infra/nginx'
    base_dir = os.path.expanduser('~')
    package_dir = os.path.join(base_dir,package)
    compile_path = os.path.join(base_dir,version)
    
    if not os.path.exists(package_dir):
        raise SystemExit("{0} is not exists".format(package_dir))
    
    unpack_nginx(package_dir)
    create_dir(infra_path)
    compile_nginx(format_nginx_command(compile_path, infra_path, user),compile_path)

if __name__ == "__main__":
    main()
