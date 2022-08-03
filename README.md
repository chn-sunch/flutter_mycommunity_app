# flutter_mycommunity_app

# 项目简介

演示程序下载地址: https://www.chulaiwanba.com

因开源造成接口调用增加，而后续版本中服务端大多数接口都是付费接口（短信,oss,人脸识别,ocr,图片处理等）2.4.2之后的版本已无法开源，2.4.2的部分需付费接口也无法正常使用如短信接口。

# 编译版本

Flutter 2.10.3 • channel stable   
Tools • Dart 2.16.1

由于使用的部分组件可能还不支持高版本Flutter SDK,如果超过这个版本有可能无法编译。

# 版本更新
## 3.2.0 开发中
* 隐私设置（隐藏我的关注列表等）
* 通知设置（赞、评论、消息等）
* 视频播放、视频上传

## 3.1.2 当前版本
* 阿里云金融级人脸识别（实名认证）
* IOS登录修改为authorization_code模式，增加注销时执行revoke.
* UI更新，代码优化BUG修改

## 3.0.0 
* 微信电商财付通接入(二级商户入驻，分账等)
* 阿里云OCR接口(身份证等证照识别)
* UI更新，代码优化BUG修改

## 3.0.0以前
* 支付宝、微信、IOS 登录
* websocket 消息通讯
* apns,华为、小米、魅族、oppo、vivo、fcm 消息推送
* 支付宝、微信支付、IM中发支付宝红包
* 上传图片、上传语音、高德地图定位、周边商户搜索，导航等
* 微信卡片、朋友圈分享，微信中打开h5并跳转到app
* 图片验证码
* 瀑布流，搜索等基础UI

## 部分UI截图
![1](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/index_1.jpg)  | ![2](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/shop.jpg)  | ![3](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/moment_1.jpg)
 ---- | ----- | ------  
![4](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/message_1.jpg)  | ![5](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/myhome.jpg) | ![6](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/map.jpg)
![7](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/otherhome.jpg)  | ![8](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/pay.jpg) | ![9](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/redpacket.jpg)
