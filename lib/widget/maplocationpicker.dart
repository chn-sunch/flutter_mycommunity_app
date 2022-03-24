import 'dart:async';

import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../service/commonjson.dart';
import '../global.dart';

class SearchBarStyle {
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const SearchBarStyle(
      {this.backgroundColor = const Color.fromRGBO(142, 142, 147, .15),
        this.padding = const EdgeInsets.all(5.0),
        this.borderRadius: const BorderRadius.all(Radius.circular(5.0))});
}

class MapLocationPicker extends StatefulWidget {
  @override
  _MapLocationPickerState createState() => _MapLocationPickerState();
  Object? arguments;
  LatLng? latLng;
  String citycode = "";
  SearchBarStyle searchBarStyle = SearchBarStyle();
  bool isMapImage = false;//是否要返回地图截图

  //LatLng(26.017794, 119.41755599999999)
  MapLocationPicker({this.arguments}){
    latLng = LatLng((arguments as Map)["lat"] as double, (arguments as Map)["lng"] as double);
    citycode = (arguments as Map)["citycode"];
    // citycode = "350100";
    // latLng = LatLng(26.017794, 119.41755599999999);
    isMapImage = (arguments as Map)["isMapImage"];
  }
}

class _MapLocationPickerState extends State<MapLocationPicker> with SingleTickerProviderStateMixin, _BLoCMixin, _AnimationMixin {
  double _currentZoom = 15.0;
  final AMapApiKey amapApiKeys = AMapApiKey(androidKey: 'a957b3baabd609fb68b51968fd066aa2', iosKey: '8108c7ed76ba703c5229f5569df0045b');
  final AMapPrivacyStatement aMapPrivacyStatement = AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true);
  AMapController? _controller;
  final PanelController _panelController = PanelController();
  FocusNode _focusNode = FocusNode();
  final _indicator = 'images/indicator.png';
  final _indicator1 = 'images/3.0x/indicator.png';
  final _iconSize = 50.0;
  double _fabHeightSend = 30.0;
  double _fabHeight = 16.0;
  bool _iskeyword = false;
  bool _animate = false;
  int _page = 1;
  int _selindex = 0;
  bool _moveByUser = true;

  final _searchQueryController = TextEditingController();
  CustomStyleOptions _customStyleOptions = CustomStyleOptions(false);
  MyLocationStyleOptions _myLocationStyleOptions = MyLocationStyleOptions(false);//小蓝点
  // 当前地图中心点
  LatLng _currentCenterCoordinate = LatLng(39.909187, 116.397451);
  CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(39.909187, 116.397451),
    zoom: 15.0,
    tilt: 30,
    bearing: 0
  );
  final _poiStream = StreamController<List<MyAMapPoi>>();
  List<MyAMapPoi> _poiInfoList = [];
  CommonJSONService _commonJSONService = new CommonJSONService();

  String _searchtype = "010000|020000|030000|040000|050000|060000|070000|080000|090000|100000|110000|120201|120300|140000|150400|190600|190301";
  final Map<String, Marker> _markers = <String, Marker>{};
  MyAMapPoi? _sendMsg;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _currentCenterCoordinate =  widget.latLng!;
    _kInitialPosition = CameraPosition(
      target: widget.latLng!,
      zoom: _currentZoom,
      tilt: 30,
      bearing: 0
    );
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _panelController.open();
        _animate=true;
      }else{
        _panelController.close();
      }

    });
  }


  @override
  Widget build(BuildContext context) {

    final AMapWidget amap = AMapWidget(
      privacyStatement: AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
      apiKey: AMapApiKey(androidKey: 'a957b3baabd609fb68b51968fd066aa2', iosKey: '8108c7ed76ba703c5229f5569df0045b'),
      initialCameraPosition: _kInitialPosition,
      mapType: MapType.normal,
      buildingsEnabled: true,
      compassEnabled: false,
      labelsEnabled: true,
      scaleEnabled: false,
      touchPoiEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      onMapCreated: onMapCreated,
      customStyleOptions: _customStyleOptions,
      myLocationStyleOptions: _myLocationStyleOptions,
      onLocationChanged: _onLocationChanged,
      onCameraMove: _onCameraMove,
      onCameraMoveEnd: _onCameraMoveEnd,
      onTap: _onMapTap,
      onLongPress: _onMapLongPress,
      onPoiTouched: _onMapPoiTouched,
      markers: Set<Marker>.of(_markers.values),

    );
    final minPanelHeight = MediaQuery.of(context).size.height * 0.4;
    final maxPanelHeight = MediaQuery.of(context).size.height * 0.7;
    final widthMax = MediaQuery.of(context).size.width;

    final Image image = Image.asset(
      _indicator,
      height: _iconSize,
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SlidingUpPanel(
          controller: _panelController,
          parallaxEnabled: true,
          parallaxOffset: 0.5,
          minHeight: minPanelHeight,
          maxHeight: maxPanelHeight,
          borderRadius: BorderRadius.circular(8),
          onPanelSlide: (double pos) => setState(() {
            _fabHeightSend = pos * (maxPanelHeight - minPanelHeight) * .5 + 30;
            _fabHeight = pos * (maxPanelHeight - minPanelHeight) * .5 + 16;
          }),
          body: Column(
            children: <Widget>[
              Flexible(
                child: Stack(
                  children: <Widget>[
                    amap,
                    Center(
                      child: AnimatedBuilder(
                        animation: _tween,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              _tween.value.dx,
                              _tween.value.dy - _iconSize / 2,
                            ),
                            child: child,
                          );
                        },
                        child: image,
                      ),
                    ),
                    Positioned(
                      right: 16.0,
                      bottom: _fabHeight,
                      child: FloatingActionButton(
                        child: StreamBuilder<bool>(
                          stream: _onMyLocation.stream,
                          initialData: true,
                          builder: (context, snapshot) {
                            return Icon(
                              Icons.gps_fixed,
                              color: snapshot.data!
                                  ? Theme.of(context).primaryColor
                                  : Colors.black54,
                            );
                          },
                        ),
                        onPressed: _showMyLocation,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Positioned(
                      right: 16.0,
                      top: _fabHeightSend,
                      child: Container(
                        width: 60,
                        child: RaisedButton(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10))),

                          color: Global.profile.backColor,
                          child: Text('发送',style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),),
                          onPressed: () async{
                            Map<String, dynamic>? map;
                            if(_sendMsg != null) {
                              map = {
                                "image": null,
                                "address": _sendMsg!.address,
                                "title": _sendMsg!.name,
                                "latitude": _sendMsg!.latLng!.latitude,
                                "longitude": _sendMsg!.latLng!.longitude,
                                "provinceCode": _sendMsg!.pcode,
                                "adCode": _sendMsg!.adCode
                              };
                            }
                            if(widget.isMapImage) {
                              final Marker marker = Marker(
                                anchor: Offset(0.5, 1),
                                position: LatLng(_sendMsg!.latLng!.latitude, _sendMsg!.latLng!.longitude),
                                icon: BitmapDescriptor.fromIconPath(_indicator1),
                                //使用默认hue的方式设置Marker的图标
                              );
                              setState(() {
                                //将新的marker添加到map里
                                _markers[marker.id] = marker;
                              });
                              Future.delayed(const Duration(milliseconds: 500), () {
                                takeSnapshotReturn(map!);
                              });
                            }
                            if(!widget.isMapImage)
                              Navigator.pop(context, map);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // 用来抵消panel的最小高度
              SizedBox(height: minPanelHeight),
            ],
          ),
          panelBuilder: (scrollController) {
            return StreamBuilder<List<MyAMapPoi>>(
              stream: _poiStream.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  return EasyRefresh(
                    footer: MaterialFooter(),
                    onLoad: _handleLoadMore,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                          alignment: Alignment.center,
                          height: 39,
                          decoration: new BoxDecoration(
                            color: Colors.black12.withAlpha(10),
                            borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  width: _animate ? widthMax * .8 : widthMax,
                                  decoration: BoxDecoration(
                                      borderRadius: widget.searchBarStyle.borderRadius,
                                      //color: widget.searchBarStyle.backgroundColor,
                                      color: Colors.grey.shade200
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Theme(
                                      child: TextField(
                                        focusNode: _focusNode,
                                        keyboardType: TextInputType.text,
                                        controller: _searchQueryController,
                                        onChanged: _onTextChanged,
                                        style: TextStyle(color:  Colors.black87, fontSize: 15),
                                        decoration: InputDecoration(
                                          icon: Icon(Icons.search, size: 20,),
                                          border: InputBorder.none,
                                          hintText: "搜索地点",
                                        ),
                                      ),
                                      data: Theme.of(context).copyWith(
                                        primaryColor: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _cancel,
                                child: AnimatedOpacity(
                                  opacity: _animate ? 1.0 : 0,
                                  curve: Curves.easeIn,
                                  duration: Duration(milliseconds: _animate ? 1000 : 0),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    width:
                                    _animate ? MediaQuery.of(context).size.width * .2 : 0,
                                    child: Container(
                                      color: Colors.white,
                                      child: Center(
                                        child:  const Text("取消"),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: data!.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selindex = index;
                                  _sendMsg = data[index];
                                  _changeCameraPosition(data[index].latLng!);
                                });
                              },
                              child:  ListTile(
                                title: Text(data[index].name),
                                subtitle: Text(data[index].address),
                                trailing: _selindex == index ? Icon(Icons.check, color: Global.profile.backColor,) : SizedBox.shrink(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator( valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),));
                }
              },
            );
          }
      ),
    );
  }

  Future<void>  takeSnapshotReturn(Map<String, dynamic> map) async{
    try{
      final imageBytes = await _controller
          ?.takeSnapshot();
      map["image"] = imageBytes;
    }
    catch(e){

    }
    Navigator.pop(context, map);
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    if (null == cameraPosition) {
      return;
    }
    //这里需要保证放大缩小的时候中心点位置不变

    print('onCameraMove===> ${cameraPosition.toMap()}');
  }

  void _onCameraMoveEnd(CameraPosition cameraPosition) {
    if (null == cameraPosition) {
      return;
    }
    if(_currentZoom != cameraPosition.zoom){
      _currentZoom = cameraPosition.zoom;
    }
    if(_moveByUser){
      //如果是用户移动
      _poiInfoList = [];
      _search(cameraPosition.target);
    }
    _moveByUser = true;
    print('_onCameraMoveEnd===> ${cameraPosition.toMap()}');
  }

  void _onMapPoiTouched(AMapPoi poi) {
    if (null == poi) {
      return;
    }
    print('_onMapPoiTouched===> ${poi.toJson()}');
  }

  void _onLocationChanged(AMapLocation location) {
    if (null == location) {
      return;
    }
    print('_onLocationChanged ${location.toJson()}');
  }

  void _onMapTap(LatLng latLng) {
    if (null == latLng) {
      return;
    }
    print('_onMapTap===> ${latLng.toJson()}');
  }

  void _onMapLongPress(LatLng latLng) {
    if (null == latLng) {
      return;
    }
    print('_onMapLongPress===> ${latLng.toJson()}');
  }

  Future<void> _showMyLocation() async {
    _changeCameraPosition(widget.latLng!);//我的位置
    if(!_iskeyword){
      //如果不在文字搜索中
      _search(widget.latLng!);
    }
  }

  void onMapCreated(AMapController controller) {
    setState(() {
      _controller = controller;
      _search(widget.latLng!);
    });
  }

  void _changeCameraPosition(LatLng latlng) {
    _moveByUser = false;
    _controller?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: latlng,
            zoom: _currentZoom,
            tilt: 30,
            bearing: 0),
      ),
      animated: true,
    );
  }

  void _cancel() {
    _animate = false;
    _iskeyword = false;
    _selindex = 0;
    _focusNode.unfocus();
    _panelController.close();
  }

  _onTextChanged(String newText) async {
    _searchkeyword(newText);
    _animate = true;
  }

  Future<void> _search(LatLng location, {bool ismore = false}) async {
    if(location != null && location.latitude != null && location.longitude != null) {
      _commonJSONService.getAmapPoi("${location.latitude},${location.longitude}", _searchtype, widget.citycode, false, 10, _page, (List poiList){
        poiList.forEach((e) {
          List<double> tem = [];
          tem.add(double.parse(e['location'].toString().split(",")[1]));
          tem.add(double.parse(e['location'].toString().split(",")[0]));
          _poiInfoList.add(new MyAMapPoi(e["id"], e["name"], tem, e["address"], e["pcode"], e["adcode"]));
        });
        if(!ismore) {
          if (_poiInfoList.length > 0) {
            _sendMsg = _poiInfoList[0];
          }
          _page = 1;
        }
        _poiStream.add(_poiInfoList);
      });
      // 重置页数
    }
  }

  Future<void> _searchkeyword(String wordkeys, {bool ismore = false}) async {
    if(wordkeys != null && wordkeys.isNotEmpty) {
      _iskeyword = true;

      if(!ismore) {
        _poiInfoList = [];
        _selindex = -1;
      }
      _commonJSONService.getAmapWordKey(wordkeys, _searchtype, widget.citycode, true, 10, _page, (List poiList){
        poiList.forEach((e) {
          List<double> tem = [];
          tem.add(double.parse(e['location'].toString().split(",")[1]));
          tem.add(double.parse(e['location'].toString().split(",")[0]));
          _poiInfoList.add(new MyAMapPoi(e["id"], e["name"], tem, e["address"], e["pcode"], e["adcode"]));
        });
        if(!ismore) {
          _page = 1;
        }
        _poiStream.add(_poiInfoList);
      });
      // 重置页数
    }
  }

  Future<void> _handleLoadMore() async {
    if(_iskeyword){
      _page++;
      _searchkeyword(_searchQueryController.text, ismore: true);
    }
    else {
      _page++;
      _search(_currentCenterCoordinate, ismore: true);
    }
  }
}

mixin _BLoCMixin on State<MapLocationPicker> {
  // poi流
  final _poiStream = StreamController<List<MyAMapPoi>>();

  // 是否在我的位置
  final _onMyLocation = StreamController<bool>();

  @override
  void dispose() {
    _poiStream.close();
    _onMyLocation.close();
    super.dispose();
  }
}


mixin _AnimationMixin on SingleTickerProviderStateMixin<MapLocationPicker> {
  // 动画相关
  late AnimationController _jumpController;
  late Animation<Offset> _tween;

  @override
  void initState() {
    super.initState();
    _jumpController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _tween = Tween(begin: Offset(0, 0), end: Offset(0, -15)).animate(
        CurvedAnimation(parent: _jumpController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }
}


class MyAMapPoi {
  String id = "";
  String name = "";
  LatLng? latLng;
  String address = "";
  String pcode = "";
  String adCode = "";

  MyAMapPoi(this.id, this.name, List<double> latlng, this.address, this.pcode,
      this.adCode) {
    latLng = LatLng.fromJson(latlng);
  }
}