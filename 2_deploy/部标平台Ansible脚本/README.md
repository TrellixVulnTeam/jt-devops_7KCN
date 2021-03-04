# 部标平台Ansible自动化运维脚本

使用说明
- 1、Ansible配置文件inventory可指定ansible所读取控制的hosts文件，为了不与默认目录/etc/ansible规定的主机分组混淆，本项目可创建/data/ansible目录，将所有playbook放进本目录下，读取主机以/data/ansible/hosts文件中定义为准。也可在项目hansible.cfg文件中自定义修改（示例已/data/ansible为准)。
- 2、在执行安装步骤前，需在hosts文件(/data/ansible/hosts)中按照主机分组配置相应主机地址。


开始安装
- ansible-playbook 00.package.yml
- ansible-playbook 01.prepare.yml
- ansible-playbook 02.elk.yml
- ansible-playbook 03.kafka.yml
- ansible-playbook 04.nginx.yml
- ansible-playbook 05.gitlab.yml
- ansible-playbook 06.mysql.yml
- ansible-playbook 07.redis.yml
- ansible-playbook 08.fastdfs.yml
- ansible-playbook 09.ftp.yml
- 其他组件安装见addon目录