import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../util/showmessage_util.dart';
import '../../service/userservice.dart';
import '../../widget/my_divider.dart';
import '../../model/user.dart';

import '../../global.dart';

class MyUpdateMobile extends StatefulWidget {
  @override
  _MyUpdateMobileState createState() => _MyUpdateMobileState();
}

class _MyUpdateMobileState extends State<MyUpdateMobile> {
  int _count=60;                     //初始倒计时时间
  String _vcode = "";
  bool  _isvButtonEnable=true;      //验证码按钮
  String _newmobile="";
  String _myCountry = "86";
  final UserService _userService = new UserService();
  Timer? _timer;
  String _buttonText='获取验证码';   //初始文本
  bool _isShowAccountClean = false;
  
  @override
  dispose(){
    if(_timer != null)
      _timer!.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget Content = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildCountrySelect(),
        SizedBox(height: 10.0),
        buildVerificationcode(),
        SizedBox(height: 19.0),
        buildUpdateBtn()
      ],
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('绑定手机', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20,left: 10, right: 10),
        alignment: Alignment.center,
        child: Content,
      ),
    );
  }

  ///验证码
  Container buildVerificationcode(){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                  crossAxisAlignment: CrossAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.ideographic,
        children: <Widget>[
          Expanded(
            child: Padding(padding: EdgeInsets.only(top: 1),
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(6)],
                controller: TextEditingController.fromValue(TextEditingValue(
                  text: _vcode,
                  selection: TextSelection.fromPosition(//保持光标在最后面
                    TextPosition(
                      affinity: TextAffinity.downstream,
                      offset: _vcode.length,
                    ),
                  ),
                )),
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  hintStyle: TextStyle(fontSize: 14),
                  hintText: ('请输入验证码'),
                  contentPadding: EdgeInsets.only(top: -5,bottom: 0),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                onChanged: (v){ setState(() {
                  _vcode = v;
                });},
              ),),
          ),
          Padding(padding: EdgeInsets.only(top: 13,right: 16),child: Container(width: 1, height: 30.0, color: Colors.grey,)),
          Container(
            child: FlatButton(
              disabledColor: Colors.grey.withOpacity(0.1),     //按钮禁用时的颜色
              textColor:(_isvButtonEnable&& _newmobile != "")?Global.profile.fontColor:Colors.black.withOpacity(0.2),                           //文本颜色
              splashColor: Colors.transparent,
              shape: StadiumBorder(side: BorderSide.none,),
              onPressed: (){
                if(_isvButtonEnable && _newmobile != ""){
                  if (_myCountry == "86" && _newmobile.length == 11) {_userService.sendVCode(_myCountry + _newmobile);
                  }
                  else if (_myCountry == "86" && _newmobile.length != 11) {
                    ShowMessage.showToast("请输入11位手机号!");
                    return;
                  }
                  else if (_myCountry == "852" || _myCountry == "853" || _myCountry == "886") {
                    _userService.sendVCode(_myCountry + _newmobile);
                  }
                  else {
                    ShowMessage.showToast("暂时只支持中国地区使用!");
                    return;
                  }
                }

                setState(() {
                  if (_isvButtonEnable && _newmobile != "") { //当按钮可点击时
                    _isvButtonEnable = false; //按钮状态标记
                    _timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
                      _count--;
                      setState(() {
                        if (_count == 0) {
                          timer.cancel(); //倒计时结束取消定时器
                          _isvButtonEnable = true; //按钮可点击
                          _count = 60; //重置时间
                          _buttonText = '获取验证码'; //重置按钮文本
                        } else {
                          _buttonText = '$_count秒后重试'; //更新文本内容
                        }
                      });
                    });
                  }
                });
              },
              child: Text('$_buttonText',style: TextStyle(fontSize: 15,color: _isvButtonEnable?Colors.blue: Colors.grey),),
            ),
          ),
        ],
      ),);
  }
  ///国家选择
  Widget buildCountrySelect() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: InkWell(
                child: Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("+ ${_myCountry}", style: TextStyle(color: Colors.black, fontSize: 16), overflow: TextOverflow.ellipsis),
                        ),

                        Icon(Icons.keyboard_arrow_down),
                      ],
                    )
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/PhoneCountryCodeView').then((val){
                    if(val != null && val != "") {
                      setState(() {
                        _myCountry = val.toString();
                      });
                    }
                  });

                },
              ),
            ),
            Expanded(
              flex: 13,
              child: buildAccountTextField(),
            )
          ],
        ),
        MyDivider(),

      ],
    );
  }
  ///手机号
  TextFormField buildAccountTextField() {
    return TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: TextEditingController.fromValue(TextEditingValue(
          text: _newmobile,
          selection: TextSelection.fromPosition(//保持光标在最后面
            TextPosition(
              affinity: TextAffinity.downstream,
              offset: _newmobile.length,
            ),
          ),
        )),
        decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 14),
          counterText: '',
          hintText: "请输入手机号",
          labelStyle: TextStyle(fontSize: 14),
          border: InputBorder.none,
          suffixIcon: this._isShowAccountClean==true ? IconButton(
            icon: Icon(Icons.cancel, color: Colors.grey),
            onPressed: (){
              setState(() {
                _newmobile = "";
                _isShowAccountClean = false;
              });
            },
          ) : Text(""),
        ),
        onChanged: (v){setState(() {
          _isShowAccountClean = true;
          if(v.length < 12){
            _newmobile = v;
          }
        });}
    );
  }
  ///更新
  Widget buildUpdateBtn(){
    return Container(
      height: 39,
      width:double.infinity,
      child: RaisedButton(
        child: Text('提交', style: TextStyle(color: Global.profile.fontColor),),
        color: Global.profile.backColor,
        onPressed: () async {
          if (_vcode.length > 1) {
            if(_newmobile != null && _newmobile.length > 0) {
              User? user = await _userService.updateMobile(
                  Global.profile.user!.uid, Global.profile.user!.token!, _vcode,
                  _newmobile, _myCountry, false, (code, msg) {
                ShowMessage.showToast(msg);
              });

              if (user != null) {
                if (user.uid == Global.profile.user!.uid) {
                  Global.profile.user!.mobile = user.mobile;
                  Global.saveProfile();
                  Navigator.pop(context);
                }
                else {
                  //已经注册成新用户需要换绑定
                  Navigator.pushNamed(context, '/BindUser', arguments: {"sourceuser": user, "bindtype": "手机号", "vcode" : _vcode, "mobile" : _newmobile, "myCountry" : _myCountry}).then((value) {
                    if(value == true) {
                      Navigator.pop(context);
                    }
                  });
                }
              }
            }
            else{
              ShowMessage.showToast("请输入手机号");
            }
          }
          else{
            ShowMessage.showToast("请输入验证码");
          }
        },
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(19)),
      ),
    );
  }

}

