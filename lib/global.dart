// 提供五套可选主题色
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/profile.dart';
import 'util/networkmanager_util.dart';


const _themes = <MaterialColor>[
  Colors.purple,
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
];


class Global {

  static String serviceurl = "https://api.chulaiwanba.com/";
  static String serviceIM =  "ws://ws.chulaiwanba.com:8082/ws";
  // static String serviceurl = "http://192.168.10.108:8080/";
  // static String serviceIM =  "ws://192.168.10.108:8082/ws";


  static String headimg = "images/icon_head_default.png";
  static String nullimg = "images/icon_nullimg.png";

  static String osshost = "https://oss.chulaiwanba.com/";
  static String apphost = "https://www.chulaiwanba.com/";
  static String applogourl = "https://mycommunity-prod.oss-cn-hangzhou.aliyuncs.com/appImage/logo.png";
  static bool isWeChatInstalled = false;
  static bool isAliPayInstalled = false;
  static const int SUCCESS = 200;
  static SharedPreferences? _prefs;
  static Profile profile = Profile();
  static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldState> mainkey = new GlobalKey<ScaffoldState>();

  static const String female = "0";
  static const String male = "1";
  static const String initGender = "2";
  static const int pagesize = 25;
  static Map<String, Object>? locationCurrent;//当前位置信息
  static BuildContext? mainContext;
  static String brand = "";
  static String devicetoken = "";
  static String timeline_id = "";//最新的聊天消息

  static const defredcolor = Color(0xffff2442);
  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  //初始化全局信息，会在APP启动时执行
  static Future init(BuildContext context) async {
    mainContext = context;
    _prefs = await SharedPreferences.getInstance();
    var _profile = _prefs!.getString("profile");
    if (_profile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
        if(profile.user != null) {
           NetworkManager.init(profile.user, mainContext!);
        }
      } catch (e) {
        //print(e);
      }
    }
  }

  // 持久化Profile信息
  static saveProfile(){
    _prefs!.setString("profile", jsonEncode(profile.toJson()));
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);//如果debug模式下会触发赋值
    return inDebugMode;
  }
}