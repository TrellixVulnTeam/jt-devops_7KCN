# 运管跑批脚本整理

## 说明(本项目用于数据跑批相关脚本)
- 1、根据实际路径，修改启动配置文件application.yml中定义的路径,配置连接地址(kafka地址，mysql地址等)
- 2、编写启动脚本run.sh,定义启动参数（启动jar包的名称、配置文件名称，需与开发提供jar包名称一致）
- 3、上传运行的jar包文件，删除jar包自带的配置文件，手动指定配置文件启动（已在启动脚本run.sh中完成）
- 4、修改是由playbook的yml文件中jar包的名称（需与开发提供jar包名称一致）

1、分步分发配置文件、修改配置、启动脚本
- ansible-playbook 001.yml
- ansible-playbook 002.yml
- ansible-playbook 003.yml
- ansible-playbook 004.yml
- ansible-playbook 005.yml
- ansible-playbook 006.yml
- ansible-playbook 007.yml
- ansible-playbook 008.yml

按标签执行任务（通常只更新jar包的情况下）
- for i in `seq 1 8`;do
-   ansible-playbook 00${i}.yml --tags copy_jar
-   ansible-playbook 00${i}.yml  --tags start_run
- done

2、一键启动
- ansible-playbook run.yml