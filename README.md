# flutter_mycommunity_app

# 项目简介
Hi，你好:raised_hand:	，当你想要出门逛街购物休闲娱乐时身边是不是总缺少一位小伙伴，为了尝试解决该痛点于是有了这个开源项目。客户端使用Flutter开发当前已经实现了一些常用功能：websocket聊天、消息推送、微信分享、支付宝支付、支付宝红包、地图定位搜索、动态列表、社交账户登录、语音图片上传等，线下商家入驻还在开发中。

由于是个人独立项目因此时间有限基本是采取实现功能即可的状态在开发因此可能存在许多隐藏bug、代码混乱等问题，欢迎大家参与pull request新增功能、代码优化重构、UI修改、图片素材都OK，目前app已经上架appstore和android商店，每天有10个左右注册新用户。

希望通过这个Flutter开源项目与大家一起完成应用客户端在多平台的部署，如实现pc和web上的IM聊天功能，同时还希望该项目可以在你需要开发一款独立应用时提供帮助。

```mermaid
	    sequenceDiagram
	    participant you as You
	    participant friend as Your friend
	    participant same as Same with you   
	    you ->> +friend: 今天天气不错去买衣服吗?
	    friend-->> -you: 今天要加班...    	  	   
     you ->> same: 有人买衣服吗?
     loop 逛街购物群
        same->>same: 找到和你一样想去逛街的人
     end
     same-->>you: 逛街出发！
```

业务流程  

```mermaid
     flowchart LR
     商家服务 --> 用户创建关联活动群 --> 群内购买商家服务一起去
```


# 编译版本

Flutter 2.10.3 • channel stable   
Tools • Dart 2.16.1

由于使用的部分组件可能还不支持高版本Flutter SDK,如果超过这个版本有可能无法编译。

## 待开发的功能

如果你也想参与此项目,可以发个issues咱们在那里交流,Flutter前端待完成的内容：   
 
 （1）服务页面需要更新为成 店铺列表-》商品列表，类似美团。 
 
 （2）服务商入驻功能，分小微，个体户，企业，可参照收付通产品接口。
  
1. 微信支付（已完成2022-4-9 对应版本 2.4.1）
2. 商户入驻（后端代码开发中，分别用微信的收付通和支付宝的直付通，前端欢迎pull request）   
3. 消息免打扰，修改群名称等
4. 代码优化重构

## 截图

![1](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/index.jpg)  | ![2](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/activity.jpg)  | ![3](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/moment.jpg)
 ---- | ----- | ------  
![4](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/message.jpg)  | ![5](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/myhome1.jpg) | ![6](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/map.jpg)
![7](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/account1.jpg)  | ![8](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/pay.jpg) | ![9](https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/githubimg/redpacket.jpg)
## App演示
应用商店搜索出来玩吧
