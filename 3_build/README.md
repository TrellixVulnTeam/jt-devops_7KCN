# Build项目

## 目录说明
- Gateway网关构建脚本：          网关侧项目K8s部署脚本
- Platform平台构建脚本:          平台侧项目K8s部署脚本
- Jenkins_freestyle构建脚本:    包含Jenkins中自动构建发布项目脚本（提交代码，触发构建发布），主要使用Shell
- Jenkins_Pipeline构建脚本:     包含Jenkins中生产环境服务发布、手动触发服务发布）,主要使用Pipeline+Ansible
- 前端发布脚本:                  各平台环境前端项目打包发布
- 前后端封板脚本：               以周为期的各项目迭代封版脚本