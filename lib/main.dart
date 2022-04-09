import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluwx/fluwx.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tobias/tobias.dart';

import 'global.dart';
import 'bloc/activity/activity_city_bloc.dart';
import 'bloc/im/im_bloc.dart';
import 'bloc/im/reply_notice_bloc.dart';
import 'bloc/user/authentication_bloc.dart';
import 'common/cn_localizations.dart';
import 'common/routes.dart';
import 'bloc/activity/activity_data_bloc.dart' as activitybloc;
import 'page/splash.dart';
import 'page/index.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    // 强制竖屏
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  _initFluwx();

  if(Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white
        ));
  }

  runApp(MyApp());
}

_initFluwx() async {
  bool weixin = await isWeChatInstalled;
  bool alipay = await isAliPayInstalled();
  Global.isWeChatInstalled = weixin;
  Global.isAliPayInstalled = alipay;
  if(weixin) {
    await registerWxApi(
        appId: "wx08bd2f7c9a87beee",
        doOnAndroid: true,
        doOnIOS: true,
        universalLink: "https://www.chulaiwanba.com/");
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Future<bool> _myinitprivacy;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _myinitprivacy = _initprivacy();
    WidgetsBinding.instance!.addObserver(this);//页面生命周期监测
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this); //移除
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
      //  应用程序处于闲置状态并且没有收到用户的输入事件。
      //注意这个状态，在切换到后台时候会触发，所以流程应该是先冻结窗口，然后停止UI
        break;
      case AppLifecycleState.paused:
        String? actid = await getExtMsg();
//      应用程序处于不可见状态
        break;
      case AppLifecycleState.resumed:
      //进入应用时不会触发该状态
      //应用程序处于可见状态，并且可以响应用户的输入事件。它相当于 Android 中Activity的onResume。
        if(Global.isWeChatInstalled) {
          String? actid = await getExtMsg();

          if (actid != null && actid != "") {
            if (actid.indexOf("^_^") >= 0) {
              actid = actid.split("^_^")[0].toString();
              Navigator.pushNamed(
                  Global.navigatorKey.currentContext!, '/ActivityInfo',
                  arguments: {"actid": actid});
            }
          }
        }
        break;
      case AppLifecycleState.detached:
      //当前页面即将退出
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (BuildContext context) => AuthenticationBloc()..add(LoggedState()),
          ),
          BlocProvider<ImBloc>(
            create: (BuildContext context) => ImBloc(),
          ),
          BlocProvider<ReplyNoticeBloc>(
            create: (BuildContext context) => ReplyNoticeBloc(),
          ),
          BlocProvider<CityActivityDataBloc>(
            create: (BuildContext context) => CityActivityDataBloc(),
          ),
          BlocProvider<activitybloc.ActivityDataBloc>(
            create: (BuildContext context) => activitybloc.ActivityDataBloc(),
          ),
        ],

        child:RefreshConfiguration(
            headerBuilder: () => MaterialClassicHeader(distance: 100, ),// 配置默认头部指示器,假如你每个页面的头部指示器都一样的话,你需要设置这个
            footerBuilder:  () => ClassicFooter( loadStyle: LoadStyle.ShowWhenLoading),        // 配置默认底部指示器
            headerTriggerDistance: 80.0,        // 头部触发刷新的越界距离
            maxOverScrollExtent :100, //头部最大可以拖动的范围,如果发生冲出视图范围区域,请设置这个属性
            maxUnderScrollExtent:0, // 底部最大可以拖动的范围
            enableScrollWhenRefreshCompleted: false, //这个属性不兼容PageView和TabBarView,如果你特别需要TabBarView左右滑动,你需要把它设置为true
            enableLoadingWhenFailed : false, //在加载失败的状态下,用户仍然可以通过手势上拉来触发加载更多
            hideFooterWhenNotFull: false, // Viewport不满一屏时,禁用上拉加载更多功能
            enableBallisticLoad: true, // 可以通过惯性滑动触发加载更多

            child:  MaterialApp(
              key: Global.mainkey,
              navigatorKey: Global.navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                //platform: TargetPlatform.iOS,
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: Colors.white
                ),
                primaryColor: Global.profile.backColor,
                primaryColorBrightness: Brightness.light,
                splashColor: Color.fromRGBO(0, 0, 0, 0),
                accentColor: Colors.black,
                canvasColor: Colors.grey.shade100,
                //画布颜色
                appBarTheme: AppBarTheme(
                    color: Colors.white,
                    elevation: 0,
                    iconTheme: IconThemeData(
                        color: Colors.white
                    )
                ),

//              textTheme: TextTheme(
//                  body1: TextStyle(color: Global.profile.fontColor)
//              ),
                buttonTheme: ButtonThemeData(
                    textTheme: ButtonTextTheme.accent
                ),
              ),
              home: _buildFutureBuilder(),
              builder: (context, widget) {
                return MediaQuery(
                  //设置文字大小不随系统设置改变
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: widget!,
                );
              },
              localizationsDelegates: [
                RefreshLocalizations.delegate,
                ChineseCupertinoLocalizations.delegate, // 自定义的delegate
                DefaultCupertinoLocalizations.delegate, // 目前只包含英文
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],

              ///语言
              supportedLocales: [
                const Locale('zh', 'CH'),
                const Locale('en', 'US'),
              ],

              ///路由表
              onGenerateRoute: onGenerateRoute,
              navigatorObservers: [ //这个监听器是个集合，可根据不同需求对路由做不同的设置
                MyNavigatorObserver()
              ],
            )
        ));
  }

  FutureBuilder<bool> _buildFutureBuilder() {
    return FutureBuilder<bool>(
      builder: (context, AsyncSnapshot<bool> async) {
        if (async.connectionState == ConnectionState.active ||
            async.connectionState == ConnectionState.waiting) {
          return SizedBox();
        }
        if (async.connectionState == ConnectionState.done) {
          debugPrint("done");
          if (async.hasError) {
            return SizedBox();
          }
          else if (async.hasData) {
            bool isaggress = async.data!;
            return isaggress ? IndexPage() : SplashPage();
          }
        }
        return SizedBox();
      },
      future: _myinitprivacy,
    );
  }

  Future<bool> _initprivacy() async {
    SharedPreferences _isagreeprivacy = await SharedPreferences.getInstance();
    var _isagree = await _isagreeprivacy.get('isagreeprivacy');
    if (_isagree != null && _isagree.toString() == "1") {
      return true;
    }
    else {
      if(Platform.isIOS){
        return true;
      }else if(Platform.isAndroid){
        return false;
      }
    }

    return false;
  }
}


class MyNavigatorObserver extends NavigatorObserver {
  ///route 当前路由
  ///previousRoute   先前活动的路由
  ///放入路由  即打开
  @override
  void didPush(Route route, Route? previousRoute) {
    // TODO: implement didPush
    if(Global.isInDebugMode) {
      print('----------pop-----------');
      print('当前活动的路由：${route.settings}');
      print('先前活动的路由：${previousRoute?.settings}');
      print('----------end-----------');
    }
    super.didPush(route, previousRoute);
  }
  ///弹出当前路由
  @override
  void didPop(Route route, Route? previousRoute) {
    // TODO: implement didPop
    if(Global.isInDebugMode) {
      print('----------pop-----------');
      print('当前活动的路由：${route.settings}');
      print('先前活动的路由：${previousRoute?.settings}');
      print('----------end-----------');
    }
    super.didPop(route, previousRoute);
  }
}
