import 'dart:io';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/showmessage_util.dart';

class MapLocationShowNav extends StatefulWidget {
  @override
  _MapLocationShowNavState createState() => _MapLocationShowNavState();
  Object? arguments;
  String lat = "";
  String lng = "";
  String title = "";
  String address = "";
  MapLocationShowNav({required this.arguments}){
    Map mapArguments = arguments as Map;
    lat = mapArguments["lat"];
    lng = mapArguments["lng"];
    title = mapArguments["title"] ?? "";
    address = mapArguments["address"] ?? "";
  }
}

class _MapLocationShowNavState extends State<MapLocationShowNav> {
  @override
  Widget build(BuildContext context) {
    final AMapWidget map = AMapWidget(
      //地图类型属性
      mapType: MapType.navi,
      zoomGesturesEnabled: true,
      initialCameraPosition: CameraPosition(
        //中心点
          target: LatLng(double.parse(widget.lat), double.parse(widget.lng)),
          //缩放级别
          zoom: 13,
          //俯仰角0°~45°（垂直与地图时为0）
          tilt: 30,
          //偏航角 0~360° (正北方为0)
          bearing: 0),
    );


    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              child: map,
            ),
            Expanded(child: Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(widget.title, style: TextStyle(fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Expanded(child: Text(widget.address, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis,),)
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: RaisedButton(
                      color: Color(0xffff2442),
                      onPressed: () async {
                        bool retamap = await canLaunch('${Platform.isAndroid ? 'android' : 'ios'}amap://navi');
                        String url = "";
                        if(retamap){
                          url = '${Platform.isAndroid ? 'android' : 'ios'}amap://navi?sourceApplication=amap&lat=${widget.lat}&lon=${widget.lng}&dev=0&style=2';
                          await launch(url);
                        }
                        else if(await canLaunch('qqmap://map/routeplan')){
                          url = 'qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&tocoord=${widget.lat},${widget.lng}&referer=IXHBZ-QIZE4-ZQ6UP-DJYEO-HC2K2-EZBXJ';
                          await launch(url);
                        }
                        else{
                          ShowMessage.showToast("请先安装高德或腾讯导航软件");
                        }
                      },
                      child: Text('导航', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
                      shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50))
                      ),
                    ),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
