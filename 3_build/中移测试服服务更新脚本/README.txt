1、iptables添加及删除
清除134防火墙策略：
    iptables -D INPUT 3   （138、132执行）

添加134防火墙策略：
    iptables -A INPUT -s 172.31.2.134 -j DROP     （138、132执行）

#########################手动服务更新#################################
2、手动服务更新
1）目录说明：（涉及服务更新）
    /opt/build/platform/   平台应用目录
       -- bin    构建镜像脚本
       -- lib    应用jar包
       -- conf   应用启停脚本

    /opt/build/gateway/   网关应用目录
       -- bin    构建镜像脚本
       -- lib    应用jar包
       -- conf   应用启停脚本

2）查看应用运行状态（134执行）
kubectl get pods -o wide

3)网关应用更新（134主机执行，ps：版本号以当时打包的为准)
  -- 先将jar包上传至/opt/build/gateway/lib目录下，然后再次目录执行以下操作

  -- 执行对应服务的发布脚本 cd  /opt/build/gateway/lib
       ../bin/build_and_push_image.sh gateway-calc alarm 1.1.6.YYC.BUILD-SNAPSHOT 21001
       ../bin/build_and_push_image.sh gateway-calc trip 1.1.6.YYC.BUILD-SNAPSHOT 21002
       ../bin/build_and_push_image.sh gateway-calc statistics 1.1.6.YYC.BUILD-SNAPSHOT 21003
       ../bin/build_and_push_image.sh jt-gateway 808 1.1.6.YYC.BUILD-SNAPSHOT 10005,9998
       ../bin/build_and_push_image.sh jt-gateway 1078 1.1.6.YYC.BUILD-SNAPSHOT 10004,9996,9997,60002,60003
       ../bin/build_and_push_image.sh jt-gateway annex 1.1.6.YYC.BUILD-SNAPSHOT 10012,9990
       
  -- 查看服务更新状态：
      kubectl get pods -o wide   更新服务为running状态时更新成功

4)平台服务更新(134主机执行，ps：版本号以当时打包的为准)
  -- 先将jar包上传至/opt/build/platform/lib目录下，然后再次目录执行以下操作

  -- 执行对应服务的发布脚本 cd  /opt/build/platform/lib
        ../bin/build_docker_image.sh  platform-provider-ygapi    1.0.21.BUILD-SNAPSHOT    8099
        ../bin/build_docker_image.sh  platform-provider-terminal    1.0.21.BUILD-SNAPSHOT    10009
        ../bin/build_docker_image.sh  platform-provider-system    1.0.21.BUILD-SNAPSHOT    8081
        ../bin/build_docker_image.sh  platform-provider-report-yyc    1.1.0.RELEASE    11005
        ../bin/build_docker_image.sh  platform-provider-report    1.0.21.BUILD-SNAPSHOT    10010
        ../bin/build_docker_image.sh  platform-provider-push    1.0.21.BUILD-SNAPSHOT    8083
        ../bin/build_docker_image.sh  platform-provider-org    1.0.21.BUILD-SNAPSHOT    8090
        ../bin/build_docker_image.sh  platform-provider-map    1.0.21.BUILD-SNAPSHOT    8091
        ../bin/build_docker_image.sh  platform-provider-job    1.0.21.BUILD-SNAPSHOT    8093
        ../bin/build_docker_image.sh  platform-provider-infrastructure    1.0.21.BUILD-SNAPSHOT    10001
        ../bin/build_docker_image.sh  platform-gateway-server    1.0.21.BUILD-SNAPSHOT    8812
        ../bin/build_docker_image.sh  platform-endpoint-809    1.0.21.BUILD-SNAPSHOT    11001
        ../bin/build_docker_image.sh  platform-endpoint-mobile  1.0.21.BUILD-SNAPSHOT    11002
       ../bin/build_docker_image.sh  platform-provider-data    1.0.21.BUILD-SNAPSHOT   12009

  -- 查看服务更新状态：
      kubectl get pods -o wide   更新服务为running状态时更新成功

#########################一键服务更新#################################
3、轻量服务更新
     1）jt-commons项目编译
        sh -x /data/jtb/bin/jt-commons.sh

     2）jt-platform-core项目编译
        sh -x /data/jtb/bin/jt-platform-core.sh

     1）发布网关计算出jt-gateway-calc项目
       sh -x /data/jtb/bin/jt-gateway-calc.sh alarm
       sh -x /data/jtb/bin/jt-gateway-calc.sh trip
       sh -x /data/jtb/bin/jt-gateway-calc.sh statistics

    2）发布平台jt-platform服务
       sh -x /data/jtb/bin/jt-platform.sh ygapi
       sh -x /data/jtb/bin/jt-platform.sh terminal
       sh -x /data/jtb/bin/jt-platform.sh system
       sh -x /data/jtb/bin/jt-platform.sh report-yyc
       sh -x /data/jtb/bin/jt-platform.sh report
       sh -x /data/jtb/bin/jt-platform.sh org
       sh -x /data/jtb/bin/jt-platform.sh push
       sh -x /data/jtb/bin/jt-platform.sh job
       sh -x /data/jtb/bin/jt-platform.sh map
       sh -x /data/jtb/bin/jt-platform.sh infrastructure
       sh -x /data/jtb/bin/jt-platform.sh gateway-server
       sh -x /data/jtb/bin/jt-platform.sh endpoint-809
       sh -x /data/jtb/bin/jt-platform.sh endpoint-mobile
       sh -x /data/jtb/bin/jt-platform.sh provider-data 