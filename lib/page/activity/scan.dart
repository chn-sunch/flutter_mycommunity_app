import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_qr_reader/qrcode_reader_view.dart';

import '../../global.dart';

class ScanView extends StatefulWidget {
  ScanView({Key? key}) : super(key: key);

  @override
  _ScanViewState createState() => new _ScanViewState();
}

class _ScanViewState extends State<ScanView> {

  @override
  void initState() {
    if(Platform.isAndroid) {
      WidgetsBinding.instance!.renderView.automaticSystemUiAdjustment = false; //去掉会导致底部状态栏重绘变成黑色，系统UI重绘，，页面退出后要改成true
    }
    super.initState();
  }

  @override
  void dispose() {
    if(Platform.isAndroid) {
      WidgetsBinding.instance!.renderView.automaticSystemUiAdjustment = true; //去掉会导致底部状态栏重绘变成黑色，系统UI重绘，，页面退出后要改成true
    }
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    // return  Scaffold(
    //   body: QrcodeReaderView(
    //     onScan: onScan,
    //     boxLineColor: Colors.purple,
    //     headerWidget: AppBar(
    //       backgroundColor: Colors.transparent,
    //       elevation: 0.0,
    //     ),
    //   ),
    // );

      return SizedBox.shrink();
  }

  Future onScan(String data) async  {
    //_key.currentState.startScan();
    String uid = "";
    if(data.indexOf("userinfo") >= 0){
      uid = data.split("?")[1].split('=')[1];
      if(uid == Global.profile.user!.uid.toString()) {
        Navigator.pushReplacementNamed(context, '/MyProfile');
      }
      else
        Navigator.pushReplacementNamed(context,  '/UserProfile', arguments: {"uid":uid});
    }
    else{
      showCupertinoDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: Text("扫码结果"),
          content: Text(data),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("确认"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );}
      );
    }
  }
}


