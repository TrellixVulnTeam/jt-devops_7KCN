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

#mailto_list = ["15071244227@163.com","wushaoyu95@163.com"]
mailto_list = "15071244227@163.com"

def send_mail(from_user,password,recieve_user,subject,text):
    msg=MIMEText(text)
    msg['From'] = from_user
    #msg['To'] = ";".join(recieve_user)
    msg['To'] = recieve_user
    msg['Subject'] = subject
    smtp_server=smtplib.SMTP(SMTP_SERVER,SMTP_PORT)
    print('Begin to connect mail server..')
    print(msg['To'])
    try:
        smtp_server.ehlo()
        print('starting encrypted section...')
        smtp_server.login(from_user,password)
        print('login successful,sending mail...')
        smtp_server.sendmail(from_user,recieve_user,msg.as_string())
    except Exception as err:
        print('sending mail failed:{0}'.format(err))
    finally:
        smtp_server.quit()

def main():
    send_mail('wushaoyu95@163.com','wsy123456',mailto_list,'subject:this is test message','hello,world')

if __name__ == "__main__":
    main()
