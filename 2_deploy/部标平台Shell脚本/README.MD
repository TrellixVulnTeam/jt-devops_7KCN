# 部标平台shell脚本部署
一、需求：为提升部标平台的基础组件部署效率，现将各组件都写成shell脚本使用ansible批量执行提升部署效率，本次以移动云测试环境部署示例说明
  前提：
     1、执行以下脚本时，需满足yum源可用，已安装ansible自动运维工具及配置ssh免密登录到每台机器，并且将平台所需的所有软件包都已copy到绑有公网IP（即ansible控制节点）机器上的/root目录下
	 2、本次测试环境ansible的hosts文件，为方便部署（后续可根据实际需要，及节点服务部署调整）
	    [all]
         10.111.30.3 ansible_ssh_port=2022
         10.111.30.10 ansible_ssh_port=2022
         10.111.30.5 ansible_ssh_port=2022

        [mysql]
         10.111.30.10 ansible_ssh_port=2022
         10.111.30.5 ansible_ssh_port=2022

        [my]
         10.111.30.3 ansible_ssh_port=2022
        [master]
         10.111.30.10 ansible_ssh_port=2022
        [slave]
         10.111.30.5 ansible_ssh_port=2022

二、基础组件部署(所有部署脚本都统一拷贝到/data/jtb/bin目录下）
- ###拷贝相关服务包及部署基础环境
   1、将各节点服务器所需的rpm包，拷贝到至相应脚本
     ansible-playbook  1_copy_rpm.yml
   2、部署各服务基础环境（java环境、mvn、基本rpm安装等）
     ansible all -m script -a '/data/jtb/bin/2_prepare_basic_env.sh'
- ###部署ELK日志系统
  3、部署elasticsearch服务(注：需在脚本中将elasticsearch集群所有节点IP，写入脚本变量中）
    ansible all -m script -a '/data/jtb/bin/3_install_elasticsearch.sh'
  4、部署logstash服务（注：需在脚本中将elasticsearch集群所有节点IP及端口，写入到脚本变量中）
    ansible all -m script -a '/data/jtb/bin/4_install_logstash.sh'
  5、部署kibana服务（注：本机部署可以直接运行shell脚本）
    ansible my -m scirpt -a '/data/jtb/bin/5_install_kibana.sh'
- ###部署MySQL主从
  6、部署节点MySQL服务
    ansible mysql -m script -a '/data/jtb/bin/6_install_mysql.sh'
  7、配置MySQL主节点相关配置(注：需在脚本中设置MySQL的root密码，写入变量中，以下相关mysql脚本中所有root密码需保持一致，已在此脚本最后替换给这些脚本）
    ansible master -m script -a ’/data/jtb/bin/7_set_mysql_master.sh'
  8、配置MySQL从节点相关配置
    ansible slave  -m script -a '/data/jtb/bin/8_set_mysql_slave.sh'
  9、创建相应的库
    ansible master -m script -a '/data/jtb/bin/9_create_database.sh'
- ###部署Kafka服务（本次集群环境为3台机器，若实际需要超过此数量，需修改部分脚本）
  10、部署zookeeper服务（注：需在脚本中将zookeeper集群的所有节点IP，写入相关变量中）
    ansbile all -m scirpt -a '/data/jtb/bin/10_install_zookeeper.sh'
  11、部署kafka服务（注：需在脚本中将kafka集群的所有节点IP及zookeeper连接主机及端口，写入相关变量中）
    ansible all -m script -a ’/data/jtb/bin/11_install_kafka.sh'
- ###部署Nginx服务
  12、部署Nginx
    ansible  my -m script -a '/data/jtb/bin/12_install_nginx.sh'
- ###部署jenkins服务  
  13、部署jenkins
    sh -x /data/jtb/bin/13_install_jenkins.sh
- ###部署gitlab服务
  14、部署gitlab
    sh -x /data/jtb/bin/14_config_gitlab.sh
- ####部署fastdfs服务
  15、部署fastdfs
    ansible slave -m script -a '/data/jtb/bin/15_install_fastdfs.sh'
- ####部署mycat服务
  16、部署mycat（注：需在脚本中配置mycat连接密码，否则以脚本中的为准）
    ansible master -m script -a '/data/jtb/bin/16_install_mycat.sh'
- ####部署redis服务	
  17、部署redis（注：需在脚本中设置redis密码，否则以脚本中的为准）
    ansible slave -m script -a '/data/jtb/bin/17_install_redis.sh'
- ####部署memsql服务
  18、部署memsql（注：需在脚本中将memsql集群的所有节点ip写入脚本变量中，在聚合节点执行安装操作）
    ansible master -m script -a '/data/jtb/bin/18_install_memsql.sh'
- ####部署zabbix服务	
  19、部署zabbix—server服务(注：脚本结尾会把zabbix server ip传递给安装zabbux-agent的脚本，另此脚本已包含安装agent服务，若需单独安装zabbix-agent服务，可执行下一个脚本）
    sh -x   /data/jtb/bin/19_install_zabbix_server.sh
  20、部署zabbix-agentd服务（注：）
    ansible -m mysql -a '/data/jtb/bin/20_install_zabbix_agent.sh'
- ####部署ftp服务
  21、部署ftp服务部署
    ansible -m slave -a '/data/jtb/bin/21_install_ftp.sh'
	