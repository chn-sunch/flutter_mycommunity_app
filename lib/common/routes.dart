import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../page/about.dart';
import '../page/activity/collection.dart';
import '../page/activity/mycreateactivity.dart';
import '../page/activity/myjoinactivity.dart';
import '../page/index.dart';
import '../page/activity/scan.dart';
import '../page/activity/searchactivity.dart';
import '../page/activity/searchactivityresult.dart';
import '../page/activity/province.dart';
import '../page/activity/city.dart';
import '../page/activity/activityinfo.dart';
import '../page/activity/reportactivity.dart';
import '../page/activity/issuedactivity.dart';
import '../page/activity/widget/reportimageactivity.dart';
import '../page/activity/widget/reportotheractivity.dart';
import '../page/activity/widget/fraudactivity.dart';
import '../page/shop/collection.dart';
import '../page/shop/goodpriceinfo.dart';
import '../page/shop/createorder.dart';
import '../page/shop/joinus.dart';
import '../page/shop/orderfinish.dart';
import '../page/shop/orderconfirm.dart';
import '../page/shop/orderinfo.dart';
import '../page/shop/searchproduct.dart';
import '../page/shop/searchproductresultpage.dart';
import '../page/shop/evaluateinfo.dart';
import '../page/im/map_shownav.dart';
import '../page/im/thumbuplist.dart';
import '../page/im/createcommunity.dart';
import '../page/im/newfollowlist.dart';
import '../page/im/noticelist.dart';
import '../page/im/message.dart';
import '../page/im/groupmember.dart';
import '../page/im/managegroupmember.dart';
import '../page/im/communitymemberlist.dart';
import '../page/im/joincommunity.dart';
import '../page/im/sharedrelationlist.dart';
import '../page/im/redpacket.dart';
import '../page/im/redpacketlist.dart';
import '../page/user/browhistory.dart';
import '../page/user/order/finish.dart';
import '../page/user/order/pending.dart';
import '../page/user/order/refund.dart';
import '../page/user/setting.dart';
import '../page/user/followuserlist.dart';
import '../page/user/fanslist.dart';
import '../page/user/order/evaluate.dart';
import '../page/user/syshelper.dart';
import '../page/user/login.dart';
import '../page/user/myprofile.dart';
import '../page/user/bugsuggest/index.dart';
import '../page/user/profileedit.dart';
import '../page/user/namesignature.dart';
import '../page/user/bugsuggest/buginfo.dart';
import '../page/user/bugsuggest/bugreport.dart';
import '../page/user/bugsuggest/reportinfo.dart';
import '../page/user/bugsuggest/suggestinfo.dart';
import '../page/user/bugsuggest/suggestreport.dart';
import '../page/user/bugsuggest/reportlist.dart';
import '../page/user/order/orderevaluatelist.dart';
import '../page/user/usersafe.dart';
import '../page/user/updatemobile.dart';
import '../page/user/exit.dart';
import '../page/user/otherprofile.dart';
import '../page/user/shardefanslist.dart';
import '../page/user/sharedlist.dart';
import '../page/user/square/momentreport.dart';
import '../page/user/square/momentinfo.dart';
import '../page/user/square/searchmoment.dart';
import '../page/user/square/searchmomentresultpage.dart';

import '../page/user/otherfollowuser.dart';
import '../page/user/binduser.dart';

import '../util/animationpage_util.dart';
import '../widget/htmlcontent.dart';
import '../widget/photo/photoview.dart';
import '../widget/maplocationpicker.dart';
import '../widget/phonecountrycodeView.dart';



UnitaryAnimationPageRoute? route;


var onGenerateRoute = (RouteSettings settings){
  switch (settings.name) {
    case '/main'://根目录
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => IndexPage(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => IndexPage(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/Login'://登录
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => LoginPage(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => LoginPage(), settings: settings.copyWith());
      }
      break;

    case '/ScanView'://扫描二维码
      if (Platform.isAndroid) {
        return UnitaryAnimationPageRoute(builder: (_) => ScanView(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return UnitaryCupertinoPageRoute(builder: (_) => ScanView(), settings: settings.copyWith());
      }
      break;

    case '/SearchActivity'://搜索活动
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SearchActivity(arguments:settings.arguments  ), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SearchActivity(arguments:settings.arguments ), settings: settings.copyWith());
      }
      break;

    case '/SearchActivityResultPage'://活动搜索结果，
      if (Platform.isAndroid) {
        return UnitaryAnimationPageRoute(builder: (_) => SearchActivityResultPage(arguments:settings.arguments),animationType:AnimationType.NoSpecial, settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return UnitaryCupertinoPageRoute(builder: (_) => SearchActivityResultPage(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/ListViewProvince'://省份选择
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ListViewProvince(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ListViewProvince(), settings: settings.copyWith());
      }
      break;
    case '/ListViewCity'://城市选择
      if (Platform.isAndroid) {
        return UnitaryAnimationPageRoute(builder: (_) => ListViewCity(arguments:settings.arguments), animationType:AnimationType.NoSpecial, settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return UnitaryCupertinoPageRoute(builder: (_) => ListViewCity(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/MapLocationShowNav'://IM地图显示导航
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MapLocationShowNav(arguments: settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MapLocationShowNav(arguments: settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/MapLocationPicker'://IM地图位置选择
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MapLocationPicker(arguments: settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MapLocationPicker(arguments: settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/ActivityInfo'://活动发布更多信息
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ActivityInfo(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ActivityInfo(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/Setting'://设置
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => Setting(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => Setting(), settings: settings.copyWith());
      }
      break;

    case '/HtmlContent': //加载html文本
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => HtmlContent(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => HtmlContent(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/PhotoViewImageHead'://图片浏览，社团头像放大
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => PhotoViewImageHead(arguments:settings.arguments), settings: settings.copyWith(), animationType:AnimationType.NoSpecial);
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => PhotoViewImageHead(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/MyBrowHistory'://历史浏览记录
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyBrowHistory(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyBrowHistory(), settings: settings.copyWith());
      }
      break;

    case '/MyFollowUser'://我关注的用户
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyFollowUser(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyFollowUser(), settings: settings.copyWith());
      }
      break;

    case '/MyFansUser'://我的粉丝
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyFansUser(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyFansUser(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/MyCollectionGoodPrice':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyCollectionGoodPrice(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyCollectionGoodPrice(), settings: settings.copyWith());
      }
      break;

    case '/MyCollectionActivity':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyCollectionActivity(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyCollectionActivity(), settings: settings.copyWith());
      }
      break;

    case '/MyCreateActivity'://个人主页中的活动列表，创建，加入，收藏
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyCreateActivity(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyCreateActivity(), settings: settings.copyWith());
      }
      break;

    case '/MyJoinActivity'://个人主页中的活动列表，创建，加入，收藏
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyJoinActivity(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyJoinActivity(), settings: settings.copyWith());
      }
      break;

    case '/MyOrderPending':
      if(Platform.isAndroid){
        return AnimationPageRoute(builder: (_) => MyOrderPending(), settings: settings.copyWith());
      }
      else if(Platform.isIOS){
        return CupertinoPageRoute(builder: (_) => MyOrderPending(), settings: settings.copyWith());
      }
      break;

    case '/MyOrderFinish':
      if(Platform.isAndroid){
        return AnimationPageRoute(builder: (_) => MyOrderFinish(), settings: settings.copyWith());
      }
      else if(Platform.isIOS){
        return CupertinoPageRoute(builder: (_) => MyOrderFinish(), settings: settings.copyWith());
      }
      break;

    case '/MyOrderRefund':
      if(Platform.isAndroid){
        return AnimationPageRoute(builder: (_) => MyOrderRefund(), settings: settings.copyWith());
      }
      else if(Platform.isIOS){
        return CupertinoPageRoute(builder: (_) => MyOrderRefund(), settings: settings.copyWith());
      }
      break;


    case '/ProAndSuggestion':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ProAndSuggestion(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ProAndSuggestion(), settings: settings.copyWith());
      }
      break;

    case '/BugReport':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => BugReport(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => BugReport(), settings: settings.copyWith());
      }
      break;
    case '/BugInfo':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => BugInfo(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => BugInfo(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/SuggestReport':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SuggestReport(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SuggestReport(), settings: settings.copyWith());
      }
      break;
    case '/SuggestInfo':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SuggestInfo(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SuggestInfo(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;
    case '/MyReportInfo':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyReportInfo(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyReportInfo(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/SysHelper':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SysHelper(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SysHelper(), settings: settings.copyWith());
      }
      break;

    case '/MyProfile'://我的资料页面
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyProfile(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyProfile(), settings: settings.copyWith());
      }
      break;

    case '/MyProfileEdit'://用户编辑
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyProfileEdit(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyProfileEdit(), settings: settings.copyWith());
      }
      break;

    case '/NameAndSignature'://昵称和个人签名
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => NameAndSignature(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => NameAndSignature(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/MyUserId':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyUserId(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyUserId(), settings: settings.copyWith());
      }
      break;

    case '/MyUpdateMobile':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyUpdateMobile(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyUpdateMobile(), settings: settings.copyWith());
      }
      break;

    case '/MyExit':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyExit(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyExit(), settings: settings.copyWith());
      }
      break;

    case '/OtherProfile'://其他人的个人主页
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => OtherProfile(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => OtherProfile(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/ReportActivity':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ReportActivity(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ReportActivity(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/FraudActivity':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => FraudActivity(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => FraudActivity(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;
    case '/ReportOtherActivity':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ReportOtherActivity(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ReportOtherActivity(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;
    case '/ReportImageActivity':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ReportImageActivity(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ReportImageActivity(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/MyReportList':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyAllReportList(arguments: settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyAllReportList(arguments: settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/ThumbUpList':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ThumbUpList(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ThumbUpList(), settings: settings.copyWith());
      }
      break;

    case '/CreateCommunity'://创建社团
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => CreateCommunity(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => CreateCommunity(), settings: settings.copyWith());
      }
      break;

    case '/MomentReport'://发布动态
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MomentReport(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MomentReport(), settings: settings.copyWith());
      }
      break;

    case '/MomentInfo':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MomentInfo(arguments: settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MomentInfo(arguments: settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/NewFollowList':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => NewFollowList(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => NewFollowList(), settings: settings.copyWith());
      }
      break;

    case '/NoticeList':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => NoticeList(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => NoticeList(), settings: settings.copyWith());
      }
      break;

    case '/GoodPriceInfo':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => GoodPriceInfo(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => GoodPriceInfo(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/IssuedActivity'://用户编辑
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => IssuedActivity(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => IssuedActivity(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/ShardeFansList':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ShardeFansList(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ShardeFansList(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/SharedList':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SharedList(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SharedList(), settings: settings.copyWith());
      }
      break;

    case '/MyMessage':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MyMessage(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MyMessage(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/CreateOrder':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => CreateOrder(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => CreateOrder(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/GroupMember'://查看群聊中的活动成员，退出群聊等操作
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => GroupMember(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => GroupMember(arguments: settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/ManageActivityMember':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ManageActivityMember(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ManageActivityMember(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/SearchProduct':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SearchProduct(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SearchProduct(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/SearchProductResultPage':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SearchProductResultPage(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SearchProductResultPage(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/MemberList'://社团成员列表
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => MemberList(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => MemberList(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/SearchMoment':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SearchMoment(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SearchMoment(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/SearchMomentResultPage':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SearchMomentResultPage(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SearchMomentResultPage(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/JoinCommunity':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => JoinCommunity(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => JoinCommunity(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/OrderFinish':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => OrderFinish(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => OrderFinish(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/ActivityEvaluate': //待评价的活动列表
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => ActivityEvaluateList(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => ActivityEvaluateList(), settings: settings.copyWith());
      }
      break;

    case '/Evaluate'://评价
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => Evaluate(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => Evaluate(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/EvaluateInfo'://评价详情，评价的回复
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => EvaluateInfo(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => EvaluateInfo(arguments: settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/OtherFollowUser'://其他人关注的用户
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => OtherFollowUser(arguments:settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => OtherFollowUser(arguments:settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/PhoneCountryCodeView'://手机归属地
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => PhoneCountryCodeView(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => PhoneCountryCodeView(), settings: settings.copyWith());
      }
      break;

    case '/SharedRelationList':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => SharedRelationList(arguments: settings.arguments), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => SharedRelationList(arguments: settings.arguments), settings: settings.copyWith());
      }
      break;

    case '/RedPacket':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => RedPacket(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => RedPacket(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;
    case '/RedPacketList':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => RedPacketList(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => RedPacketList(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/BindUser':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => BindUser(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => BindUser(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/About':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => About(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => About(), settings: settings.copyWith());
      }
      break;

    case '/OrderInfo':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => OrderInfo(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => OrderInfo(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/OrderConfirm':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => OrderConfirm(arguments: settings.arguments,), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => OrderConfirm(arguments: settings.arguments,), settings: settings.copyWith());
      }
      break;

    case '/JoinUs':
      if (Platform.isAndroid) {
        return AnimationPageRoute(builder: (_) => JoinUs(), settings: settings.copyWith());
      } else if (Platform.isIOS) {
        return CupertinoPageRoute(builder: (_) => JoinUs(), settings: settings.copyWith());
      }
      break;
  }
};
