# 部标平台ansible自动化运维脚本

使用说明
- 1、inventory可指定ansible所读取控制的hosts文件，为了不与默认目录/etc/ansible规定的主机分组混淆，本项可创建/data/ansible目录，将所有playbook放进本目录下，也可在项目hansible.cfg文件中自定义修改（示例已/data/ansible为准)
- 2、在执行安装步骤前，需在hosts文件中配置所有服务器ip为全局变量（示例已配置完成，可修改对应ip即可）
- 3、若服务器数量为三台，则可直接修改对应主机分组的IP，按顺序执行playbook即可（见示例hosts文件）。
- 4、本示例主要针对于三台主机部署，若主机数量大于三台，可视具体情况修改全局变量ip对应地址，但2和3可不做修改（原因：按部署结构规定，数据库将部署于这两台主机，在对应的roles中已经写入）

开始安装
- ansible-playbook 00.copy.yml
- ansible-playbook 01.prepare.yml
- ansible-playbook 02.elk.yml
- ansible-playbook 03.mysql.yml
- ansible-playbook 04.kafka.yml
- ansible-playbook 05.nginx.yml
- ansible-playbook 06.gitlab.yml
- ansible-playbook 07.fastdfs.yml
- ansible-playbook 08.redis.yml
- ansible-playbook 09.memsql.yml
- ansible-playbook 10.ftp.yml
- ansible-playbook 11.zabbix.yml
- ansible-playbook 12.jenkins.yml(若需要使用jenkins，可安装）
