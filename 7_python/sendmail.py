#!/usr/bin/python
# -*- conding: utf-8 -*-

from __future__ import print_function
import smtplib
from email.mime.text import MIMEText
import sys,os

SMTP_SERVER = "smtp.163.com"
SMTP_PORT = 25

base_dir = "sys.path.append(os.path.abspath(os.path.dirname(__file__)))"
sys.path.append(base_dir)

def send_mail(from_user,password,recieve_user,subject,text):
    msg=MIMEText(text)
    msg['From'] = from_user
    msg['To'] = recieve_user
    msg['Subject'] = subject
    smtp_server=smtplib.SMTP(SMTP_SERVER,SMTP_PORT)
    print('Begin to connect mail server..')
    try:
        smtp_server.ehlo()
        print('starting encrypted section...')
        smtp_server.login(from_user,password)
        print('login successful,sending mail...')
        smtp_server.sendmail(from_user,recieve_user,msg.as_string())
    except Execption as err:
        print('sending mail failed:{0}'.format(err))
    finally:
        smtp_server.quit()

def main():
    send_mail('wushaoyu95@163.com','wsy123456','15071244227@163.com','subject:this is test message','hello,world')

if __name__ == "__main__":
    main()
