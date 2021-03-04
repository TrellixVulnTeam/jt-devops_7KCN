# 使用说明

## xxl-job部署路径
-    /data/jtb/infra/xxl-job

## 启动脚本路径： 
- /data/jtb/infra/xxl-job/bin/run

## systemctl脚本: 
- /usr/lib/systemd/system/xxljob.service



## 脚本使用详情
- 启动xxl-job:   systemctl start xxljob

- 停止xxl-job:   systemctl stop xxljob

- 重启xxl-job:   systemctl restart xxljob

- 查看xxl-job运行状态:     systemctl status xxljob

- 开机自启：   systemctl enable xxljob
