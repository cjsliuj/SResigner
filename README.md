# SResigner
SResigners是一款集动态库注入与删除、IPA元数据修改、重签名功能为一体的MacOS应用，旨在为您提供贴心的一条龙服务。

[SResigner的实现](https://blog.csdn.net/jerryandliujie/article/details/84845162)

# 开发环境
Xcode10.2
Swift4.2

# 运行环境
MacOS 10.11+

# 功能特性
- 支持动态库注入与删除，支持dylib和framework形式的动态库
- 自动识别所有需要重签名的文件，不漏签
- 自动解析描述文件所包含的证书，证书选择更加便捷
- 支持拖拽ipa、描述文件，操作便捷
- 优化签名步骤，并发执行codesign命令，重签更加快速
- 支持修改AppName、Version、BundleID

# 软件主界面
![image](https://raw.githubusercontent.com/cjsliuj/SResigner/master/DocResource/main.png)