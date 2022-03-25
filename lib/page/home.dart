import 'dart:async';
import 'dart:ui';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_links/uni_links.dart';

import '../page/user/pictureshow.dart';
import '../page/activity/recommend.dart';
import '../widget/my_tabbarview.dart';
import '../bloc/activity/activity_city_bloc.dart';
import '../bloc/activity/activity_data_bloc.dart';


import '../common/iconfont.dart';
import '../util/permission_util.dart';
import '../util/showmessage_util.dart';
import '../util/common_util.dart';
import '../util/token_util.dart';

import '../global.dart';
import 'activity/cityactivity.dart';
import 'user/follow.dart';

class HomePage extends StatefulWidget {
  final Function? parentJumpMyProfile;
  bool isPop;

  HomePage({Key? key, this.parentJumpMyProfile, this.isPop = false}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin  {

  int _currentIndex= 1;
  late TabController _tabController;
  String _title = "";
  final GlobalKey<_TabBarItemState> _itemKey1 = GlobalKey();
  final GlobalKey<_TabBarItemState> _itemKey2 = GlobalKey();
  final GlobalKey<_TabBarItemState> _itemCityKey2 = GlobalKey();
  String _temcitycode = "";
  DateTime? _lastPopTime;
  StreamSubscription<Map<String, Object>>? _locationListener;
  AMapFlutterLocation _locationPlugin = new AMapFlutterLocation();
  Map<String, Object>? _locationResult;
  late ActivityDataBloc _activityBloc;
  StreamSubscription? _sub;
  bool _initialUriIsHandled = false;
  TokenUtil _tokenUtil = new TokenUtil();

  @override
  void initState() {
    // 生命周期函数
    super.initState();
    _activityBloc = BlocProvider.of<ActivityDataBloc>(context);
    _initMap();
    _tabController = new TabController(vsync: this, length: 3);
    _tabController.index = _currentIndex;
    _tabController.addListener((){
      _itemKey1.currentState!.onPressed(_tabController.index);
      _itemKey2.currentState!.onPressed(_tabController.index);
      _itemCityKey2.currentState!.onPressed(_tabController.index);
    });

    _temcitycode = Global.profile.locationCode;
    //延迟500毫秒刷新下，
  }

  @override
  void dispose() { // 生命周期函数
    _tabController.dispose();
    _sub?.cancel();

    ///移除定位监听
    if (null != _locationListener) {
      _locationListener!.cancel();
    }

    ///销毁定位
    if (null != _locationPlugin) {
      _locationPlugin.destroy();
    }

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  _initMap() async {
    await Global.init(this.context);
    await _tokenUtil.getDeviceToken();
    _handleIncomingLinks();
    _handleInitialUri();

    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    await _locationCity();
    setState(() {

    });
  }



  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = linkStream.listen((String? uri) {
        if(uri != null) {
          _noticeHandle(uri);
        }
      }, onError: (Object err) {
        print('got err: $err');
        setState(() {
          if (err is FormatException) {

            // ShowMessage.showToast(err.message);
          }
        });
      });
    }
  }

  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final link = await getInitialLink();

        if (link == null) {
          print('no initial uri');
        } else {
          if(link != ""){
            _noticeHandle(link);
          }
        }
        if (!mounted) return;
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri');
        //ShowMessage.showToast(err.message);
      }
    }
  }

  Future<void> _noticeHandle(String deeplink) async {
    if(deeplink != null && deeplink != "") {
      await _tokenUtil.deeplinkNav(deeplink);
    }
  }

  Future<void> _locationCity( ) async {
    try {
      if(Global.profile.locationCode == null || Global.profile.locationCode == ""){
        Global.profile.locationCode = "allCode";
        Global.profile.locationName = "全国";

        if(Global.profile.locationGoodPriceCode == null || Global.profile.locationGoodPriceCode == ""){
          Global.profile.locationGoodPriceName = "全国";
          Global.profile.locationGoodPriceCode = "allCode";
        }

        bool locationStatus = await PermissionUtil.reqestLocation();
        await PermissionUtil.reqestStorage();

        if (locationStatus) {
          _locationListener = _locationPlugin.onLocationChanged().listen((Map<String, Object> result) {
            setState(() {
              _locationResult = result;
              if (_locationResult != null) {
                if(result["longitude"] != "" && result["adCode"] != "") {
                  try {
                    Global.profile.lat = double.parse(result["latitude"].toString());
                    Global.profile.lng = double.parse(result["longitude"].toString());

                    Global.profile.locationCode = CommonUtil.getCityNameByGaoDe(
                        result["adCode"].toString());
                    Global.profile.locationName = result["city"].toString();
                    Global.profile.locationGoodPriceCode =
                        CommonUtil.getCityNameByGaoDe(
                            result["adCode"].toString());
                    Global.profile.locationGoodPriceName =
                        result["city"].toString();
                  }
                  catch(e){
                    Global.profile.locationCode = "allCode";
                    Global.profile.locationName = "全国";
                    Global.profile.locationGoodPriceName = "全国";
                    Global.profile.locationGoodPriceCode = "allCode";
                    _activityBloc.add(Refresh());
                  }
                  Global.saveProfile();
                }
              }
              _activityBloc.add(Refresh());
            });
          });
          _startLocation();
        }
        else {
          Global.profile.locationCode = "allCode";
          Global.profile.locationName = "全国";
          Global.profile.locationGoodPriceName = "全国";
          Global.profile.locationGoodPriceCode = "allCode";
          _activityBloc.add(Refresh());
        }
      }
      //只有同意隐私协议才能使用定位权限
    }
    catch(Ex){
      Global.profile.locationCode = "allCode";
      Global.profile.locationName = "全国";
      Global.profile.locationGoodPriceName = "全国";
      Global.profile.locationGoodPriceCode = "allCode";
    }
  }

  void _setLocationOption() {
    if (null != _locationPlugin) {
      AMapLocationOption locationOption = new AMapLocationOption();

      ///是否单次定位
      locationOption.onceLocation = true;

      ///是否需要返回逆地理信息
      locationOption.needAddress = true;

      ///逆地理信息的语言类型
      locationOption.geoLanguage = GeoLanguage.DEFAULT;

      locationOption.desiredLocationAccuracyAuthorizationMode =
          AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

      locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

      ///设置Android端连续定位的定位间隔
      locationOption.locationInterval = 2000;

      ///设置Android端的定位模式<br>
      ///可选值：<br>
      ///<li>[AMapLocationMode.Battery_Saving]</li>
      ///<li>[AMapLocationMode.Device_Sensors]</li>
      ///<li>[AMapLocationMode.Hight_Accuracy]</li>
      locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

      ///设置iOS端的定位最小更新距离<br>
      locationOption.distanceFilter = -1;

      ///设置iOS端期望的定位精度
      /// 可选值：<br>
      /// <li>[DesiredAccuracy.Best] 最高精度</li>
      /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
      /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
      /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
      /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
      locationOption.desiredAccuracy = DesiredAccuracy.HundredMeters;

      ///设置iOS端是否允许系统暂停定位
      locationOption.pausesLocationUpdatesAutomatically = false;

      ///将定位参数设置给定位插件
      _locationPlugin.setLocationOption(locationOption);
    }
  }

  ///开始定位
  void _startLocation() {
    if (null != _locationPlugin) {
      ///开始定位之前设置定位参数
      _setLocationOption();
      _locationPlugin.startLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    _title = (Global.profile.locationName.length > 3 ? Global.profile.locationName.substring(0,3) : Global.profile.locationName);
    return WillPopScope(
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _buildAppBarRow(),
          ),
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //SearchBar(),
                Expanded(
                  child: _buildTabView(),
                ),
              ],
            ),
          )
      ),
      onWillPop: () async {
        if(_lastPopTime == null || DateTime.now().difference(_lastPopTime!) > Duration(seconds: 2)){
          _lastPopTime = DateTime.now();
          ShowMessage.showToast('再按一次退出');
        }else{
          _lastPopTime = DateTime.now();
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }

        return false;
      },
    );
  }
  //view
  MyTabBarView _buildTabView(){
    return MyTabBarView(
        controller: _tabController,
        //physics: new NeverScrollableScrollPhysics(),
        children: <Widget>[
          MyFollow(),
          Recommend(isPop: widget.isPop, parentJumpShop: widget.parentJumpMyProfile,),
          CityActivity(parentJumpShop: widget.parentJumpMyProfile),
        ]
    );
  }
  //barItem 导航条内容
  Row _buildAppBarRow() {
    if(Global.profile.locationCode != _temcitycode) {
      _temcitycode = Global.profile.locationCode;
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(flex: 1, child: Container(
            alignment: Alignment.center,
            child: ProfilePictureShow(parentJumpMyProfile: widget.parentJumpMyProfile,),
          )),
          Expanded(flex: 5,
            child: TabBar(
                controller: _tabController,
                isScrollable: false,
                dragStartBehavior: DragStartBehavior.down,
                labelPadding: EdgeInsets.only(top: 15),
                indicatorWeight: 0.000001,
                tabs: <Widget>[
                  //_item("关注", 0), Alignment.bottomRight, 0, "关注", 0
                  TabBarItem(key: _itemKey1, title: "关注", bottomAlignment: Alignment.bottomRight, itemtype: 0, itemindex: 0,),
                  TabBarItem(key: _itemKey2, title: "推荐", bottomAlignment: Alignment.center, itemtype: 0, itemindex: 1,),
                  TabBarItem(key: _itemCityKey2, title: _title, bottomAlignment: Alignment.bottomLeft, itemtype: 1, itemindex: 2)
                ]),
          ),
          Expanded(flex: 1, child: InkWell(
            onTap: (){
              Navigator.pushNamed(context, '/SearchActivity');
            },
            child: Container(
              alignment: Alignment.topRight,
              child: Icon(IconFont.icon_sousuo,color: Colors.black87,size: 25,),
            ),
          )),
        ]);
  }


}

//头部的tabbar
class TabBarItem extends StatefulWidget {
  Alignment? bottomAlignment;
  int itemtype;
  String title;
  int itemindex;
  TabController? tabController;

  TabBarItem({Key? key, this.bottomAlignment, this.itemtype = 0,  this.title = "", this.itemindex = 0, this.tabController}) : super(key: key){
    //print(this.title);
  }

  @override
  _TabBarItemState createState() => _TabBarItemState(bottomAlignment!, itemtype,  itemindex);

}
class _TabBarItemState extends State<TabBarItem> {
  Alignment _bottomAlignment;
  int _itemtype;
  int _currentIndex = 1;
  int _itemindex;
  late ActivityDataBloc _activityDataBloc;
  late CityActivityDataBloc _cityActivityDataBloc;
  _TabBarItemState(this._bottomAlignment, this._itemtype,  this._itemindex);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _activityDataBloc = BlocProvider.of<ActivityDataBloc>(context);
    _cityActivityDataBloc = BlocProvider.of<CityActivityDataBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    if(_itemtype == 0){
      return item1();
    }
    else{
      return item2();
    }
  }

  Widget item1(){
    return Container(
        alignment: _bottomAlignment,
        child: Column(
          children: <Widget>[
            Text(
                widget.title,
                style: TextStyle(fontSize: _itemindex ==_currentIndex?16:14, fontWeight: _itemindex ==_currentIndex?FontWeight.w900:FontWeight.w500, color:
                _itemindex ==_currentIndex?Global.profile.backColor:Colors.black)
            ),
            Text(
                _itemindex ==_currentIndex?"—":"",
                style: TextStyle(fontSize: _itemindex ==_currentIndex?16:14, fontWeight: _itemindex ==_currentIndex?FontWeight.w900:FontWeight.w500, color:
                _itemindex ==_currentIndex?Global.profile.backColor:Colors.black)
            )
          ],
        )
    );
  }//关注和首页

  Widget item2(){
    return Container(
        alignment: _bottomAlignment,
        child: InkWell(
          child: Column(
            children: <Widget>[
              Container(
                  alignment: _bottomAlignment,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          widget.title,
                          style: TextStyle(fontSize: _itemindex ==_currentIndex?16:14, fontWeight: _itemindex ==_currentIndex?FontWeight.w900:FontWeight.w400, color:
                          _itemindex ==_currentIndex?Global.profile.backColor:Colors.black)
                      ),
                      Icon(_itemindex ==  _currentIndex?Icons.keyboard_arrow_down:null,color: _itemindex ==_currentIndex?Global.profile.backColor:Colors.black,),
                    ],)
              ),
              Container(
                margin: EdgeInsets.only(left: widget.title.length >= 3 ? 17 : 10),
                alignment: Alignment.bottomLeft,
                child: Text(
                    _itemindex ==_currentIndex?"—":"",
                    style: TextStyle(fontSize: _itemindex ==_currentIndex?16:14, fontWeight: _currentIndex ==_currentIndex?FontWeight.w900:FontWeight.w500,
                        color: _itemindex ==_currentIndex?Global.profile.backColor:Colors.black)
                ),
              )
            ],
          ),
          onTap:_itemindex ==_currentIndex? (){
            Navigator.pushNamed(context, '/ListViewProvince', arguments:null).then((dynamic value){
              if(value != null) {
                if(Global.profile.locationCode != value["code"].toString()) {
                  Global.profile.locationCode = value["code"].toString();
                  Global.profile.locationName = value["name"].toString();
                  _activityDataBloc.add(Refresh());
                  _cityActivityDataBloc.add(Refreshed(Global.profile.locationCode));
                  Global.saveProfile();
                }

                widget.title = Global.profile.locationName;
                setState(() {
                  if (widget.title.length > 3)
                    widget.title = widget.title.substring(0, 3);
                });
              }
            });

          } : null,
        )
    );
  }//城市选择页

  void onPressed(int val) {
    this._currentIndex = val;

    setState(() {
    });
  }
}
