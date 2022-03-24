
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_apns/flutter_apns.dart';
import 'package:push_message_register/push_message_register.dart';

import '../service/userservice.dart';
import '../util/showmessage_util.dart';
import '../model/im/grouprelation.dart';
import '../model/evaluateactivity.dart';
import '../service/activity.dart';
import '../util/imhelper_util.dart';
import '../service/gpservice.dart';
import '../model/grouppurchase/goodpice_model.dart';
import '../global.dart';


class TokenUtil{
  PushMessageRegister _pushMessageRegister = PushMessageRegister();
  UserService _userService = UserService();
  String _brand = "other";
  final ImHelper _imHelper = ImHelper();

  getDeviceToken() async {
    await _getDeviceToken();
  }

   Future<void> _getDeviceToken() async {
    if(Global.profile.user != null) {
      if(Platform.isAndroid) {
        _pushMessageRegister.onReceiveMessage().listen((event) {
          if (event != null) {
            if (event["result"] == "success") {
              Global.devicetoken = event["token"].toString();
              Global.brand = event["brand"].toString();
              if (Global.profile.user != null) {

                _userService.updatePushToken(
                    Global.profile.user!.uid, Global.profile.user!.token!,
                    Global.brand, Global.devicetoken, (error, msg) {
                  ShowMessage.showToast(msg);
                });
              }
            }
          }
        });
        //vivo配置在AndroidManifest.xml
        Map apikey = {
          "XIAOMI_APP_ID": "2882303761519957474",
          "XIAOMI_APP_KEY": "5621995751474",
          "HUAWEI_APP_ID": "104414629",
          "HUAWEI_APP_KEY": "",
          "OPPO_APP_KEY": "bd433ec5604645a88acdd28456a67aef",
          "OPPO_APP_SECRET": "52e07d9d047543168a1d213439e95336",
          "MEIZU_APP_ID": "146976",
          "MEIZU_APP_KEY": "dfdffa4965214f31b75047c058483b89"
        };
        _brand = await PushMessageRegister.registerApi(apikey);
      }

      if(Platform.isIOS || _brand == "other"){
        PushConnector connector = createPushConnector();
        _registerFcmOrApns(connector);
      }
    }
  }

  _registerFcmOrApns(connector) async {
    connector.configure(
      onLaunch: (data) => onPush('onLaunch', data),
      onResume: (data) => onPush('onResume', data),
      onMessage: (data) => onPush('onMessage', data),
      onBackgroundMessage: _onBackgroundMessage,
    );
    connector.token.addListener(() {
      Global.devicetoken = connector.token.value;
      if(Platform.isIOS) {
        _userService.updatePushToken(
            Global.profile.user!.uid, Global.profile.user!.token!,
            "ios", connector.token.value, (error, msg) {
        });
      }
      else{
        _userService.updatePushToken(
            Global.profile.user!.uid, Global.profile.user!.token!,
            "fcm", connector.token.value, (error, msg) {
          ShowMessage.showToast(msg);
        });
      }
    });
    connector.requestNotificationPermissions();

    if (connector is ApnsPushConnector) {
      connector.shouldPresent = (x) async {
        final remote = RemoteMessage.fromMap(x.payload);
        return remote.category == 'MEETING_INVITATION';
      };
      connector.setNotificationCategories([
        UNNotificationCategory(
          identifier: 'MEETING_INVITATION',
          actions: [
            UNNotificationAction(
              identifier: 'ACCEPT_ACTION',
              title: 'Accept',
              options: UNNotificationActionOptions.values,
            ),
            UNNotificationAction(
              identifier: 'DECLINE_ACTION',
              title: 'Decline',
              options: [],
            ),
          ],
          intentIdentifiers: [],
          options: UNNotificationCategoryOptions.values,
        ),
      ]);
    }
  }

  Future<dynamic> onPush(String name, RemoteMessage payload) async {
    String content = payload.data.toString();
    if(content != ""){
      content.replaceAll('{', '').replaceAll('}', '');

      List<String> contents = content.split(',');
      for(String content in contents) {
        if(content.indexOf('content:') >= 0) {
          content = content.split('content:')[1];
          deeplinkNav(content);
        }
      }
    }

    return Future.value(true);
  }

  Future<dynamic> _onBackgroundMessage(RemoteMessage data) => onPush('onBackgroundMessage', data);

  deeplinkNav(String deeplink) async {
    //微信中打开app
    if(deeplink.indexOf("extmsg=") >= 0){
      deeplink = deeplink.split("extmsg=")[1];
      String actid = deeplink.split("^_^")[0];
      Navigator.pushNamed(Global.navigatorKey.currentContext!, '/ActivityInfo',
          arguments: {"actid": actid});
    }

    //消息通知pushmessage
    if(deeplink.indexOf("timeline_id:") >= 0){
      String timeline_id = deeplink.split("timeline_id:")[1];

      if(Global.profile.user != null){
        GroupRelation? groupRelation = await _imHelper.getGroupRelationByGroupid(Global.profile.user!.uid, timeline_id);
        if(groupRelation != null){
          Global.timeline_id = timeline_id;
          Navigator.pushNamed(Global.navigatorKey.currentContext!, '/MyMessage', arguments: {"GroupRelation": groupRelation}).then((val) {});
        }
      }
    }

    //活动点赞、留言、回复
    if(deeplink.indexOf("actid:") >= 0){
      String actid = deeplink.split("actid:")[1];
      Navigator.pushNamed(Global.navigatorKey.currentContext!, '/ActivityInfo',
          arguments: {"actid": actid});
    }

    //新用户关注
    if(deeplink.indexOf("follow:") >= 0){
      String uid = deeplink.split("follow:")[1];
      Navigator.pushNamed(Global.navigatorKey.currentContext!, '/OtherProfile', arguments: {"uid": uid});
    }

    //新的商品点赞，回复，留言
    if(deeplink.indexOf("goodpriceid:") >= 0){
      String goodpriceid = deeplink.split("goodpriceid:")[1];
      _gotoGoodPrice(goodpriceid);
    }

    //新bug点赞、回复、留言
    if(deeplink.indexOf("bugid:") >= 0){
      String bugid = deeplink.split("bugid:")[1];
      Navigator.pushNamed(Global.navigatorKey.currentContext!, '/BugInfo', arguments: {"bugid": bugid});
    }

    //新suggestid点赞、回复、留言
    if(deeplink.indexOf("suggestid:") >= 0){
      String suggestid = deeplink.split("suggestid:")[1];
      Navigator.pushNamed(Global.navigatorKey.currentContext!, '/SuggestInfo', arguments: {"suggestid": suggestid});
    }

    //新momentid点赞、回复、留言
    if(deeplink.indexOf("momentid:") >= 0){
      String momentid = deeplink.split("momentid:")[1];
      Navigator.pushNamed(Global.navigatorKey.currentContext!, '/MomentInfo', arguments: {"momentid": momentid});
    }

    //新的评价点赞、回复
    if(deeplink.indexOf("evaluateid:") >= 0){
      String evaluateid = deeplink.split("evaluateid:")[1];
      ActivityService activityService = new ActivityService();
      EvaluateActivity? evaluateactivity = await activityService.getEvaluateActivityByEvaluateid(int.parse(evaluateid));
      if(evaluateactivity != null) {
        Navigator.pushNamed(Global.navigatorKey.currentContext!, '/EvaluateInfo',
            arguments: {"evaluateActivity": evaluateactivity});
      }
    }
  }

  Future<void> _gotoGoodPrice(String goodpriceid) async {
    GPService gpservice = new GPService();
    GoodPiceModel? goodprice = await gpservice.getGoodPriceInfo(goodpriceid);
    if (goodprice != null) {
      Navigator.pushNamed(
          Global.navigatorKey.currentContext!, '/GoodPriceInfo', arguments: {
        "goodprice": goodprice
      });
    }
  }
}