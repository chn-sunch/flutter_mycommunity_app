import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluwx_no_pay/fluwx_no_pay.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../model/user.dart';
import '../../widget/circle_headimage.dart';
import '../../service/userservice.dart';
import '../../util/showmessage_util.dart';

import '../../global.dart';

class BindUser extends StatefulWidget {
  Object? arguments;
  User? sourceuser;
  String bindtype = "";
  String vcode = "";//手机验证码
  String mobile = "";//新手机
  String myCountry = "";//手机国家
  BindUser({this.arguments}){
    if(arguments != null){
      Map map = arguments as Map;
      bindtype = map["bindtype"];
      sourceuser = map["sourceuser"];

      vcode = map["vcode"] != null ? map["vcode"] : "";
      mobile = map["mobile"] != null ? map["mobile"] : "";
      myCountry = map["myCountry"] != null ? map["myCountry"] : "";

    }
  }

  @override
  _BindUserState createState() => _BindUserState();
}

class _BindUserState extends State<BindUser> {
  UserService _userService = new UserService();
  String wxcode = "";
  StreamSubscription? _streamDemoSubscription;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(_streamDemoSubscription != null) {
      _streamDemoSubscription!.cancel();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamDemoSubscription = weChatResponseEventHandler.listen((res) async {
      if (res is WeChatAuthResponse) {
        if(res.code != null && res.code != wxcode) {
          wxcode = res.code.toString();
          User? user = await _userService.updateWeixin(
              Global.profile.user!.uid,
              Global.profile.user!.token!,
              res.code!, true, errorCallBack);

          if (user != null) {
            if (user.uid != Global.profile.user!.uid) {
              Global.profile.user!.wxuserid = user.wxuserid;
              Global.saveProfile();
              Navigator.pop(context);
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: Text('绑定失败', style: TextStyle(fontSize: 16),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),

      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              child: Text('你的${widget.bindtype}账号 已被下方账号所绑定', style: TextStyle(fontSize: 16, color: Colors.black),),
            ),
            SizedBox(height: 15,),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 1,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRectOhterHeadImage(
                        width: 50,
                        imageUrl: widget.sourceuser!.profilepicture!,
                        cir: 50,
                      ),
                      SizedBox(width: 10,),
                      Expanded(child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child:  Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(widget.sourceuser!.username, style: TextStyle(
                                    fontSize: 14, color: Colors.black
                                ),),
                              ),
                              SizedBox(height: 10,),
                              Container(
                                child: Text(widget.sourceuser!.signature == "" ? "Ta很神秘": widget.sourceuser!.signature,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black45, overflow: TextOverflow.ellipsis
                                  ),),
                              ),
                            ],
                          ),),
                          SizedBox(
                            width: 69,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: new Border.all(color: Global.defredcolor, width: 0.5),
                              ),
                              child: Text('当前绑定', style: TextStyle(color: Global.defredcolor, fontSize: 12),),
                            ),
                          )
                        ],
                      ))
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            Container(
              alignment: Alignment.center,
              child: Text('是否换绑定至当前账号', style: TextStyle(fontSize: 16, color: Colors.black),),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 1,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRectOhterHeadImage(
                        width: 50,
                        imageUrl: Global.profile.user!.profilepicture!,
                        cir: 50,
                      ),
                      SizedBox(width: 10,),
                      Expanded(child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child:  Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(Global.profile.user!.username, style: TextStyle(
                                    fontSize: 14, color: Colors.black
                                ),),
                              ),
                              SizedBox(height: 10,),
                              Container(
                                child: Text(Global.profile.user!.signature == "" ? "Ta很神秘": widget.sourceuser!.signature,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black45, overflow: TextOverflow.ellipsis
                                  ),),
                              ),
                            ],
                          ),),
                          SizedBox(
                            width: 69,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: new Border.all(color: Colors.black45, width: 0.5),
                              ),
                              child: Text('当前登录', style: TextStyle(color: Colors.black45, fontSize: 12),),
                            ),
                          )
                        ],
                      ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubBtn(),
    );
  }

  Widget _buildSubBtn(){
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      height: 60,
      child: FlatButton(
        color: Global.defredcolor,
        child: Text(
          '换绑到当前账号',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          if(widget.bindtype == "支付宝"){
            bool ret = await _bindAlipay();
            if(ret){
              Navigator.pop(context);
            }
          }

          if(widget.bindtype == "微信"){
            await _bindWeixin();
          }

          if(widget.bindtype == "Apple"){
            bool ret = await _bindIos();
            if(ret){
              Navigator.pop(context);
            }
          }

          if(widget.bindtype == "手机号"){
            bool ret = await _bindMobile();
            if(ret){
              Navigator.pop(context, true);
            }
          }
        },
      ),
    );
  }

  Future<bool> _bindAlipay() async {
    String authurl = await _userService.getAliUserAuth();
    //绑定支付宝账号
    User? user = await _userService.updateAliPay(Global.profile.user!.uid, Global.profile.user!.token!,
        authurl, true, errorCallBack);
    if(user != null) {
      if (user.uid != Global.profile.user!.uid) {
        Global.profile.user!.aliuserid = user.aliuserid;
        Global.saveProfile();
        return true;
      }
    }

    return false;
  }

  Future<void> _bindWeixin() async {
    await sendWeChatAuth(scope: "snsapi_userinfo",
        state: "wechat_sdk_demo_test").then((value){
    });
  }

  Future<bool> _bindIos() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    if(credential != null && credential.identityToken != null) {
      User? user = await _userService.updateIos(Global.profile.user!.uid, Global.profile.user!.token!,
          credential.identityToken!, true, credential.userIdentifier!,  errorCallBack);
      if (user != null) {
        if (user.uid != Global.profile.user!.uid) {
          Global.profile.user!.iosuserid = user.iosuserid;
          Global.saveProfile();
          return true;
        }
      }

      return false;
    }

    return false;
  }

  Future<bool> _bindMobile() async {
    User? user = await _userService.updateMobile(
        Global.profile.user!.uid, Global.profile.user!.token!, widget.vcode,
        widget.mobile, widget.myCountry, true, (code, msg) {
      ShowMessage.showToast(msg);
    });

    if (user != null) {
      if (user.uid != Global.profile.user!.uid) {
        Global.profile.user!.mobile = user.mobile;
        Global.saveProfile();
        return true;
      }
    }

    return false;
  }


  errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}
