import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';


import '../global.dart';
import '../model/appinfo.dart';
import '../service/commonjson.dart';
import '../util/appupdate_util.dart';
import '../util/showmessage_util.dart';



class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  String version = "";
  AppInfo? _appInfo;
  CommonJSONService _commonJSONService = new CommonJSONService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getVersion();
  }

  @override
  void dispose() {
    super.dispose();
  }


  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('关于出来玩吧', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset("images/ic_launcher.png", fit: BoxFit.cover,).image
                        )
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5,),
              Container(
                alignment: Alignment.center,
                child: Text("当前版本: ${version}", style: TextStyle(color: Colors.black54, fontSize: 12),),
              ),
              SizedBox(height: 5,),

              Card(
                elevation: 0,
                color: Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      onTap: (){
                        _appUpdate();
                      },
                      title: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("检查更新", style: TextStyle(fontSize: 15),),
                          ],
                        ),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                    Padding(padding: EdgeInsets.only(left: 10, right: 10),
                      child: Divider(height: 0.1, color: Colors.black26),
                    ),
                    ListTile(
                      onTap: (){
                        Navigator.pushNamed(context, '/HtmlContent', arguments: {
                          "parameterkey": "loginuseragree",
                          "title": "隐私政策"
                        });
                      },
                      title: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("隐私政策", style: TextStyle(fontSize: 15),),
                          ],
                        ),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                    Padding(padding: EdgeInsets.only(left: 10, right: 10),
                      child: Divider(height: 0.1, color: Colors.black26),
                    ),
                    ListTile(
                      onTap: (){
                        Navigator.pushNamed(context, '/HtmlContent', arguments: {
                          "parameterkey": "useragreement",
                          "title": "用户协议"
                        });
                      },
                      title: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("用户协议", style: TextStyle(fontSize: 15),),
                          ],
                        ),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    ),
                  ],
                ),
              ),//昵称
            ],
          )),
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Column(
                children: [
                  Text('Copyright©2021-2022', style: TextStyle(fontSize: 12, color: Colors.black45),),
                  Text('简单一点信息技术 版权所有', style: TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              )
          )
        ],
      ),
    );
  }

  Future<void> _appUpdate() async {
    _appInfo = await _commonJSONService.getSysVersionConfig();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (_appInfo != null && packageInfo.version != _appInfo!.versionName) {
      //版本不匹配就更新
      if(Platform.isAndroid){
        if(_appInfo!.androidUpdate!){
          _isshowUpdate(_appInfo!.apkUrl!);
        }
      }

      if(Platform.isIOS){
        if(_appInfo!.iosUpdate!){
          _isshowUpdate("https://itunes.apple.com/cn/app/id1570133391");
        }
      }
    }
    else{
      ShowMessage.showToast('您当前已经是最新版本了^_^');
    }
  }

  _isshowUpdate(String appurl){
    double pagewidth = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        //强制更新，不可以点击空白区域关闭，不需要可以不要
        barrierDismissible: true,
        builder: (BuildContext context){
          return UnconstrainedBox(
            child: Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
              width: pagewidth * 0.9,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Icon(Icons.close, size: 16,),
                    ),
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                  ),
                  Container(
                    child: Text('发现新版本:${_appInfo!.versionName}', style: TextStyle(fontSize: 16, color: Colors.black, decoration: TextDecoration.none,),),
                    alignment: Alignment.center,
                    color: Colors.white,
                  ),
                  SizedBox(height: 19,),
                  Text('${_appInfo!.updateLog}', style: TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.none,),),
                  SizedBox(height: 29,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: Container(
                        height: 39,
                        child: TextButton(
                          child: Text(
                            '立即更新',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          onPressed: (){
                            AppupdateUtil.launcherApp(appurl);
                            Navigator.of(context).pop();
                          },
                        ),
                        decoration: BoxDecoration(
                          color: Global.defredcolor,
                          borderRadius: BorderRadius.all(Radius.circular(39)),
                        ),
                      ))
                    ],
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
            ),
          );
        }
    );
  }


}

