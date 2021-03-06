import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../model/user.dart';
import '../../model/im/grouprelation.dart';
import '../../widget/my_divider.dart';
import '../../widget/captcha/block_puzzle_captcha.dart';
import '../../bloc/user/authentication_bloc.dart';
import '../../common/iconfont.dart';
import '../../service/commonjson.dart';
import '../../service/userservice.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../util/networkmanager_util.dart';

import '../../global.dart';


class MyUserId extends StatefulWidget {
  @override
  _MyUserIdEditState createState() => _MyUserIdEditState();
}

class _MyUserIdEditState extends State<MyUserId> {
  User? user;
  double fontsize = 15;
  double contentfontsize = 14;
  ImHelper _imhelper = new ImHelper();
  CommonJSONService _commonJSONService = new CommonJSONService();
  UserService _userService = new UserService();
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

  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          ShowMessage.showToast(state.error!);
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          buildWhen: (previousState, state) {
            if(state is AuthenticationAuthenticated) {
              return true;
            }
            else
              return false;
          },
          builder: (context, state) {
            user = Global.profile.user!;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.grey.shade100,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                title: Text('???????????????', style: TextStyle(color: Colors.black, fontSize: 16)),
                centerTitle: true,
              ),
              body: Container(
                margin: EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
                child: ListView(
                  children: <Widget>[
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            onTap: (){
                              Navigator.pushNamed(context, '/MyUpdateMobile').then((value){
                                setState(() {

                                });
                              });
                            },
                            title: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("?????????", style: TextStyle(fontSize: fontsize),),
                                  Text(Global.profile.user!.mobile == "" ? "?????????" : "+" + Global.profile.user!.mobile,
                                    style: TextStyle(color: Global.profile.user!.mobile != "" ? Colors.black : Colors.black45, fontSize: contentfontsize),)
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
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context){
                                    return PassWordSetDialog();
                                  }
                              );                            },
                            title: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("????????????", style: TextStyle(fontSize: fontsize),),
                                ],
                              ),
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          ),
                        ],
                      ),
                    ),//??????
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Text('??????????????????', style: TextStyle(fontSize: 14, color: Colors.black54),),
                    ),
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () async {
                              if(Global.profile.user!.aliuserid == "") {
                                String authurl = await _userService.getAliUserAuth();
                                //?????????????????????
                                User? user = await _userService.updateAliPay(
                                    Global.profile.user!.uid,
                                    Global.profile.user!.token!,
                                    authurl, false, errorCallBack);
                                if (user != null) {
                                  if (user.uid == Global.profile.user!.uid) {
                                    Global.profile.user!.aliuserid = user.aliuserid;
                                    Global.saveProfile();
                                    setState(() {

                                    });
                                  }
                                  else {
                                    //???????????????????????????????????????
                                    Navigator.pushNamed(context, '/BindUser', arguments: {"sourceuser": user, "bindtype": "?????????"}).then((value) {
                                      setState(() {

                                      });
                                    });
                                  }
                                }
                              }
                            },
                            title: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("???????????????", style: TextStyle(fontSize: fontsize),),
                                  Text(Global.profile.user!.aliuserid != ""
                                      ?  "?????????" : "?????????", style: TextStyle(color: Global.profile.user!.aliuserid != "" ? Colors.black : Colors.black45, fontSize: contentfontsize),)
                                ],
                              ),
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          ),
                          Global.isWeChatInstalled ? Padding(padding: EdgeInsets.only(left: 10, right: 10),
                            child: Divider(height: 0.1, color: Colors.black26),
                          ) : SizedBox.shrink(),
                          Global.isWeChatInstalled ? ListTile(
                            onTap: () async {
                              if(Global.profile.user!.wxuserid == "") {
                                if(_streamDemoSubscription == null) {
                                  _streamDemoSubscription =
                                      weChatResponseEventHandler.listen((
                                          res) async {
                                        if (res is WeChatAuthResponse) {
                                          if (res.code != null) {
                                            User? user = await _userService
                                                .updateWeixin(
                                                Global.profile.user!.uid,
                                                Global.profile.user!.token!,
                                                res.code!, false,
                                                errorCallBack);

                                            if (user != null) {
                                              if (user.uid ==
                                                  Global.profile.user!.uid) {
                                                Global.profile.user!.wxuserid =
                                                    user.wxuserid;
                                                Global.saveProfile();
                                                if (mounted) {
                                                  setState(() {

                                                  });
                                                }
                                              }
                                              else {
                                                //???????????????????????????????????????
                                                _streamDemoSubscription!
                                                    .cancel();
                                                _streamDemoSubscription = null;
                                                Navigator.pushNamed(
                                                    context, '/BindUser',
                                                    arguments: {
                                                      "sourceuser": user,
                                                      "bindtype": "??????"
                                                    }).then((value) {
                                                  if (mounted) {
                                                    setState(() {

                                                    });
                                                  }
                                                });
                                              }
                                            }
                                          }
                                        }
                                      });
                                }
                                await sendWeChatAuth(scope: "snsapi_userinfo",
                                    state: "wechat_sdk_demo_test");
                              }
                            },
                            title: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("????????????", style: TextStyle(fontSize: fontsize),),
                                  Text(Global.profile.user!.wxuserid != ""
                                      ?  "?????????" : "?????????", style: TextStyle(color: Global.profile.user!.wxuserid != "" ? Colors.black : Colors.black45,  fontSize: contentfontsize),)
                                ],
                              ),
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          ) : SizedBox.shrink(),
                          Platform.isIOS ? Padding(padding: EdgeInsets.only(left: 10, right: 10),
                            child: Divider(height: 0.1, color: Colors.black26),
                          ) : SizedBox.shrink(),
                          Platform.isIOS ? ListTile(
                            onTap: () async {
                              if(Global.profile.user!.iosuserid == "") {
                                final credential = await SignInWithApple.getAppleIDCredential(
                                  scopes: [
                                    AppleIDAuthorizationScopes.email,
                                    AppleIDAuthorizationScopes.fullName,
                                  ],
                                );
                                if (credential != null && credential.identityToken != null) {
                                  User? user = await _userService.updateIos(
                                      Global.profile.user!.uid,
                                      Global.profile.user!.token!,
                                      credential.identityToken!, false,
                                      credential.userIdentifier!,
                                      errorCallBack);
                                  if (user != null) {
                                    if (user.uid == Global.profile.user!.uid) {
                                      Global.profile.user!.iosuserid =
                                          user.iosuserid;
                                      Global.saveProfile();
                                      setState(() {

                                      });
                                    }
                                    else {
                                      //???????????????????????????????????????
                                      Navigator.pushNamed(context, '/BindUser',
                                          arguments: {
                                            "sourceuser": user,
                                            "bindtype": "Apple"
                                          }).then((value) {
                                        setState(() {

                                        });
                                      });
                                    }
                                  }
                                }
                              }
                            },
                            title: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Apple??????", style: TextStyle(fontSize: fontsize),),
                                  Text(Global.profile.user!.iosuserid != ""
                                      ?  "?????????" : "?????????", style: TextStyle(color: Global.profile.user!.iosuserid != "" ? Colors.black : Colors.black45, fontSize: contentfontsize),)
                                ],
                              ),
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          ) : SizedBox.shrink(),
                          Padding(padding: EdgeInsets.only(left: 10, right: 10),
                            child: Divider(height: 0.1, color: Colors.black26),
                          ),
                          ListTile(
                            onTap: (){
                              Navigator.pushNamed(context, '/Setting');
                            },
                            title: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("????????????", style: TextStyle(fontSize: fontsize),),
                                ],
                              ),
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          ),
                        ],
                      ),
                    ),//??????

                    Card(
                      elevation: 0,
                      color: Colors.white,
                      child: ListTile(
                        onTap: () async {
                          await _userService.deltoken(Global.profile.user!.token!, Global.profile.user!.uid, (String statusCode, String msg) {});
                          Global.profile.user = null;
                          Global.profile.defProfilePicture = AssetImage(Global.headimg);
                          Global.saveProfile();
                          NetworkManager.onDone(isouted: true);
                          BlocProvider.of<AuthenticationBloc>(context).add(
                              LoggedOut());
                          Navigator.pushNamedAndRemoveUntil(context, '/main',  (route) => route == null, arguments: {"ispop" : true});
                        },
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("????????????", style: TextStyle(fontSize: fontsize)),
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),//??????


                  ],
                ),
              ),
            );
          }
      ),);
  }

  void _showTel() {
    if (Global.profile.user == null) {
      Navigator.pushNamed(context, '/Login');
      return;
    }

    showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) =>
            Container(
              height: 150,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(IconFont.icon_navbar_xiaoxi_xuanzhong,
                      color: Colors.green,),
                    title: Text('????????????', style: TextStyle(color:  Colors.black87, fontSize: 15),),
                    onTap: () {
                      _telCustomerCare("");
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.mail, color: Colors.blue,),
                    title: Text(
                      '???????????????', style: TextStyle(color:  Colors.black87, fontSize: 15),),
                    onTap: () {
                      Navigator.pushNamed(context, '/HtmlContent',
                          arguments: {"parameterkey": "mail", "title": "????????????"});
                    },
                  ),
                  MyDivider(),
                  Container(
                    height: 6,
                    color: Colors.grey.shade100,
                  ),
                  Expanded(
                    child: _buildBtn(),
                  )
                ],
              ),
            )
    ).then((value) {

    });
  }

  Widget _buildBtn() {
    return Container(
        color: Colors.white,
        width: double.infinity,
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(
              child: FlatButton(
                  child: Text(
                    '??? ???', style: TextStyle(color:  Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          ],
        )
    );
  }

  Future<void> _telCustomerCare(String vcode) async {
    String timeline_id = "";
    //????????????
    int customuid = 0;
    int uid = Global.profile.user!.uid;
    customuid = await _commonJSONService.getSysCustomer(0, Global.profile.user!.uid, Global.profile.user!.token!);
    if(customuid <= 0){
      ShowMessage.showToast("??????????????????");
      return;
    }

    if (uid > customuid) {
      timeline_id = customuid.toString() + uid.toString();
    }
    else {
      timeline_id = uid.toString() + customuid.toString();
    }
    GroupRelation? groupRelation = await _imhelper.getGroupRelationByGroupid(uid, timeline_id);
    if (groupRelation == null) {
      groupRelation = await _userService.joinSingleCustomer(
          timeline_id, uid, customuid, Global.profile.user!.token!,
          vcode,  (String statusCode, String msg) {
        if(statusCode == "-1008"){
          loadingBlockPuzzle(context);
          return;
        }
        else{
          ShowMessage.showToast(msg);
        }
      }, isCustomer: 1);
    }
    if (groupRelation != null) {
      List<GroupRelation> groupRelations = [];
      groupRelations.add(groupRelation);
      int ret = await _imhelper.saveGroupRelation(groupRelations);
      if (Global.isInDebugMode) {
        print("???????????????????????????-----------------------------------");
        print(groupRelations[0].group_name1);
        //print(ret);
      }
      if (ret > 0) {
        Navigator.pushNamed(this.context, '/MyMessage', arguments: {"GroupRelation": groupRelation});
      }
    }
  }

  //????????????
  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true}) {
    showDialog<Null>(
      context: this.context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v){
            _telCustomerCare(v);
          },
          onFail: (){

          },
        );
      },
    );
  }

  errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}

class PassWordSetDialog extends Dialog{
  String _password1 = "";
  String _password2 = "";

  PassWordSetDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.all(12.0),
        child: new Material(
            type: MaterialType.transparency,
            child: Center(
                child: Container(
                  width: double.infinity,
                  height: 230,
                  decoration: ShapeDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ))),
                  margin: const EdgeInsets.only(left: 10,right: 10),
                  child: Padding(
                    padding: EdgeInsets.only(top: 10,left: 10, right: 10),
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Text('????????????', style: TextStyle(color: Colors.black, fontSize: 15),),
                        ),
                        SizedBox(height: 10,),
                        MyDivider(),
                        Row(
                          children: <Widget>[ //
                            Expanded(
//                              flex: 7,
                                child:TextField(
                                    obscureText: true,
                                    controller: TextEditingController.fromValue(TextEditingValue(
                                      // ????????????
                                        text: _password1,
                                        // ?????????????????????
                                        selection: TextSelection.fromPosition(TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: _password1.length)))),
                                    maxLength: 15,//?????????????????????????????????TextField????????????????????????????????????????????????
                                    maxLines: 1,//????????????
                                    autocorrect: true,//??????????????????
                                    autofocus: false,//??????????????????
                                    textAlign: TextAlign.left,//??????????????????
                                    style: TextStyle(fontSize: 18.0, color: Colors.black),//?????????????????????
                                    onChanged: (text) {//?????????????????????
                                      _password1 = text;
                                    },



                                    decoration: InputDecoration(
                                        counterText: "",//????????????????????????????????????
                                        hintStyle: TextStyle(fontSize: 14),
                                        hintText: "6~15???????????????????????????",
                                        border: InputBorder.none
                                    )
                                )),
                          ],
                        ),
                        Row(
                          children: <Widget>[
//                          Expanded(
//                            child: Text('????????????', style: TextStyle(color: Colors.black, fontSize: 18),),
//                            flex: 2,
//                          ),
                            Expanded(
//                              flex: 7,
                                child:TextField(
                                    controller: TextEditingController.fromValue(TextEditingValue(
                                      // ????????????
                                        text: _password2,
                                        // ?????????????????????
                                        selection: TextSelection.fromPosition(TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: _password2.length)))),
                                    maxLength: 15,//?????????????????????????????????TextField????????????????????????????????????????????????
                                    maxLines: 1,//????????????
                                    obscureText: true,
                                    autocorrect: true,//??????????????????
                                    autofocus: false,//??????????????????
                                    textAlign: TextAlign.left,//??????????????????
                                    style: TextStyle(fontSize: 18.0, color: Colors.black),//?????????????????????
                                    onChanged: (text) {//?????????????????????
                                      _password2 = text;
                                    },
                                    decoration: InputDecoration(
                                        counterText: "",//????????????????????????????????????
                                        hintStyle: TextStyle(fontSize: 14),

                                        hintText: "????????????????????????",
                                        border: InputBorder.none
                                    )
                                )),
                          ],
                        ),
                        MyDivider(),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                child: Text('???????????????', style: TextStyle(color: Global.profile.fontColor, fontSize: 14),),
                                color: Global.profile.backColor,
                                onPressed: () async {
                                  if (_password1 == _password2) {
                                    if(_password1.length >= 6){
                                      BlocProvider.of<AuthenticationBloc>(context).add(
                                          UpdateUserPasswordPressed(user: Global.profile.user!, password: _password1));
                                      Navigator.pop(context);
                                    }
                                    else{
                                      ShowMessage.showToast("?????????????????????6-15?????????????????????????????????");
                                    }
                                  }
                                  else {
                                    ShowMessage.showToast("?????????????????????,???????????????");
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
            )
        )
    );
  }
}




