# 项目迭代封版脚本


## 发布版本脚本说明（x.x.x.RELEASE）
- release_relversion.sh        RELEASE版本发布脚本(RELEASE封版脚本)

- release_devversion.sh        SNAPSHOT版本发布脚本(开发版本发布脚本)






## 脚本使用说明（此脚本以2020/09/12日发布使用为例）

### RELEASE版本使用说明：

```bash
 bash  release_relversion.sh   -h|--help

 Usage:  release_relversion.sh [option]  [newVersion]  [oldVersion]

 Avaiable option:
   jt-commons           will release jt-commons project 
   jt-platform-core     will release jt-platform-core project 
   jt-platform          will release jt-platform project
   jt-platform-web      will release jt-platform-web project
   jt-gateway           will release jt-gateway project
   jt-gateway-calc      will release jt-gateway-calc project
   jt-platform-whyg     will release jt-platform-whyg project
   jt-platform-ytsf     will release jt-platform-ytsf project

 Flag:
   oldVersion           is your project current release version,such as "1.0.22.RELEASE"
   newVersion           is your current release version add one, such as "1.0.23.RELEASE"

 Example:
   [release jt-commons project]          bash release_relversion.sh  jt-commons  1.1.7.RELEASE 1.1.6.RELEASE
   [release jt-platform-core project]    bash release_relversion.sh  jt-platform-core  1.1.7.RELEASE 1.1.6.RELEASE
   [release jt-platform project]         bash release_relversion.sh  jt-platform  1.0.23.RELEASE
   [release jt-platform-web project]     bash release_relversion.sh  jt-platform-web  v1.0.23
   [release jt-gateway project]          bash release_relversion.sh  jt-gateway  1.0.23.RELEASE 1.0.22.RELEASE
   [release jt-gateway-calc project]     bash release_relversion.sh  jt-gateway-calc  1.0.23.RELEASE 1.0.22.RELEASE
   [release jt-platform-whyg project]    bash release_relversion.sh  jt-platform-whyg  1.0.23.RELEASE 1.0.22.RELEASE
   [release jt-platform-ytsf project]    bash release_relversion.sh  jt-platform-ytsf  1.0.23.RELEASE 1.0.22.RELEASE
```

### SNAPSHOT版本使用说明

```bash
 bash  release_devversion.sh   -h|--help

 Usage:  release_devversion.sh  [option]  [devVersion]

 Avaiable option:
   jt-commons           will release jt-commons project 
   jt-platform-core     will release jt-platform-core project 
   jt-platform          will release jt-platform project
   jt-platform-web      will release jt-platform-web project
   jt-gateway           will release jt-gateway project
   jt-gateway-calc      will release jt-gateway-calc project
   jt-platform-whyg     will release jt-platform-whyg project
   jt-platform-ytsf     will release jt-platform-ytsf project

 Flag:
   devVersion           is your project current release version,but need add one.
                       for example your release version is  "1.0.22.RELEASE",your [devVersion] is "1.0.23.BUILD-SNAPSHOT"

 Example:
   [release jt-commons project]          bash release_devversion.sh  jt-commons  1.1.8.BUILD-SNAPSHOT
   [release jt-platform-core project]    bash release_devversion.sh  jt-platform-core  1.1.8.BUILD-SNAPSHOT
   [release jt-platform project]         bash release_devversion.sh  jt-platform  1.0.23.BUILD-SNAPSHOT
   [release jt-platform-web project]     bash release_devversion.sh  jt-platform-web  v1.0.23
   [release jt-gateway project]          bash release_devversion.sh  jt-gateway  1.0.23.BUILD-SNAPSHOT
   [release jt-gateway-calc project]     bash release_devversion.sh  jt-gateway-calc  1.0.23.BUILD-SNAPSHOT
   [release jt-platform-whyg project]    bash release_devversion.sh  jt-platform-whyg  1.0.23.BUILD-SNAPSHOT
   [release jt-platform-ytsf project]    bash release_devversion.sh  jt-platform-ytsf  1.0.23.BUILD-SNAPSHOT
```