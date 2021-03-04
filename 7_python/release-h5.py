#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import os,shutil
import subprocess

def npm_run(base_dir):
    print('当前目录是:',base_dir)
    subprocess.check_call('{} {} {}'.format('/usr/local/bin/npm','run','build-dev'),shell=True)

def update(base_dir,web_dir,h5_dir):
    if os.path.exists(base_dir + '/www'):
        try:
            if os.path.exists(h5_dir):
                shutil.rmtree(h5_dir)
        except Exception as err:
            print('目前没有h5端部署，直接更新即可')
        finally:
            shutil.move(base_dir + '/www',web_dir + '/www')
            subprocess.check_call('{} {} {} {}'.format('chown','-R','nginx:nginx',h5_dir),shell=True)
        print('h5端更新成功')
    else:
        print('打包失败,请检查！！！')


def main():
    base_dir = os.getcwd()
    web_dir = '/usr/local/web'
    h5_dir = os.path.join(web_dir,'www')
    npm_run(base_dir)
    update(base_dir,web_dir,h5_dir)



if __name__ == "__main__":
    main()
