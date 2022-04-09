import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluwx/fluwx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../bloc/user/authentication_bloc.dart';
import '../../common/iconfont.dart';
import '../../util/showmessage_util.dart';
import '../../service/userservice.dart';
import '../../widget/my_divider.dart';
import '../../widget/captcha/block_puzzle_captcha.dart';
import '../../global.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isShowPwd = false;
  bool _isShowAccountClean = false;
  bool _ismobilelogin = true;//是否手机验证登录
  bool _iscaptcha = false;//默认不用人机验证，服务器返回对应错误后开器
  bool _isagree = false;//是否同意条款
  int _count=60;                     //初始倒计时时间
  String _loginNav = "手机密码登录";
  String _buttonText='获取验证码';   //初始文本
  String _myCountry = "86";
  bool  _isvButtonEnable=true;      //验证码按钮
  bool _isLoginButtonEnable = true;
  String _vcode = "";
  String _mobile="";
  String _password="";
  Timer? _timer;
  final UserService _userService = new UserService();
  FocusNode _commentFocus_mobile = FocusNode();//手机号焦点
  FocusNode _passwordFocus_mobile = FocusNode();//密码框焦点
  FocusNode _vcodeFocus = FocusNode();//验证码焦点
  late AuthenticationBloc _authenticationBloc;
  StreamSubscription? _streamDemoSubscription;


  @override
  dispose(){
    if(_timer != null)
      _timer!.cancel();
    _commentFocus_mobile.dispose();
    _passwordFocus_mobile.dispose();
    _vcodeFocus.dispose();
    if(_streamDemoSubscription != null) {
      _streamDemoSubscription!.cancel();
    }
    super.dispose();
  }

  @override
  void initState(){
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _streamDemoSubscription = weChatResponseEventHandler.listen((res) {
      if (res is WeChatAuthResponse) {
        if(res.code != null) {
          _authenticationBloc.add(LoginWeiXin(auth_code: res.code!));
        }
      }
    });



    _commentFocus_mobile.addListener(() {
      if (!_commentFocus_mobile.hasFocus) {
        setState((){
          _isShowAccountClean = false;
        });
      }
      else if(_commentFocus_mobile.hasFocus && _mobile != ""){
        setState((){
          _isShowAccountClean = true;
        });
      }
    });
  }

  Future<void> saveKeyBoardHeight(double height) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setDouble("kbheight", height).then((bool success) {
      //print(height) ;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(MediaQuery.of(context).viewInsets.bottom>0) {
      saveKeyBoardHeight(MediaQuery.of(context).viewInsets.bottom);
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.only(left: 19),
              child: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.black45,),onPressed: (){
                Navigator.pop(context);
              },),
            ),
          actions: [
            Container(
              padding: EdgeInsets.only(right: 29),
              alignment: Alignment.center,
              child: GestureDetector(
                child: Text(_loginNav,style: TextStyle(
                    color: Colors.black45,
                    fontSize: 16.0
                )),
                onTap: (){
                  setState(() {
                    _ismobilelogin = _ismobilelogin == true ? false : true;
                    _loginNav = _loginNav == "手机密码登录" ? "验证码登录" : "手机密码登录";

                    if(_ismobilelogin){
                      _password = "";
                    }
                    else{
                      _vcode = "";
                    }
                  });
                },
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              children: <Widget>[
                SizedBox(
                  height: kToolbarHeight-10,
                ),
                _buildTitle(),
                SizedBox(height: 49.0),
                _buildCountrySelect(),
                SizedBox(height: 10.0),
                !_ismobilelogin ? _buildPasswordTextField(context):SizedBox.shrink(),
                _ismobilelogin ? _buildVerificationcode():SizedBox.shrink(),
                SizedBox(height: 20.0),
                _buildLoginButton(context),
              ],
            )),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Text('一  社交账号登录  一', style: TextStyle(color: Colors.black45, fontSize: 14),),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Global.isWeChatInstalled ? IconButton(
                          onPressed: () async{
                            if(!_isagree){
                              _isagree = await _buildReadAgreement();
                              setState(() {

                              });
                            }
                            if(!_isagree) {
                              return;
                            }

                            await sendWeChatAuth(scope: "snsapi_userinfo",
                                state: "wechat_sdk_demo_test").then((
                                value) {});
                          },
                          icon: Image.asset('images/login_weixin.png', height: 28.9, width: 28.9)) : SizedBox.shrink(),
                      Global.isWeChatInstalled ? SizedBox(width: 39,): SizedBox.shrink(),
                      Global.isAliPayInstalled ? IconButton(onPressed: () async {
                        if(!_isagree){
                          _isagree = await _buildReadAgreement();
                          setState(() {

                          });
                        }
                        if(!_isagree) {
                          return;
                        }
                        _authenticationBloc.add(LoginAli());
                      }, icon: Image.asset('images/login_alipay.png', height: 28.9, width: 28.9)) : SizedBox.shrink(),
                      Platform.isIOS && Global.isAliPayInstalled ? SizedBox(width: 39,) : SizedBox.shrink(),
                      Platform.isIOS ? IconButton(onPressed: () async {
                        if(!_isagree){
                          _isagree = await _buildReadAgreement();
                          setState(() {

                          });
                        }
                        if(!_isagree) {
                          return;
                        }

                        final credential = await SignInWithApple.getAppleIDCredential(
                          scopes: [
                            AppleIDAuthorizationScopes.email,
                            AppleIDAuthorizationScopes.fullName,
                          ],
                        );
                        if(credential != null && credential.identityToken != null) {
                          _authenticationBloc.add(LoginIos(identityToken: credential.identityToken!,
                              iosuserid: credential.userIdentifier!));
                        }
                      }, icon: Image.asset('images/login_apple.png', height: 33, width: 33,)) : SizedBox.shrink(),
                    ],
                  )
                ],
              ),
            )
          ],
        )
    );
  }
  ///用户协议
  Align _builduseragree(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 9.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.start,
          children: <Widget>[
            Checkbox(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              checkColor: Colors.white,
              activeColor: Global.defredcolor,
              value: this._isagree,
              onChanged: (bool? value) {
                setState(() {
                  if(value != null)
                    this._isagree = value;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text('我已阅读并同意', style: TextStyle(color: Colors.grey, fontSize: 14),),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child:  GestureDetector(
                child: Text(
                  '《隐私政策》',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
                onTap: () {
                  //TODO 跳转到登录用户协议页面
                  Navigator.pushNamed(context, '/HtmlContent', arguments: {"parameterkey": "loginuseragree", "title": ""});
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child:  Text('和', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child:  GestureDetector(
                child: Text(
                  '《用户协议》',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
                onTap: () {
                  //TODO 跳转到登录用户协议页面
                  Navigator.pushNamed(context, '/HtmlContent', arguments: {"parameterkey": "useragreement", "title": ""});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  ///国家选择
  Widget _buildCountrySelect() {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: _myCountry.length > 2 ? (_myCountry.length > 3 ? 89 : 79) : 69,
                child: InkWell(
                  child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text("+ ${_myCountry}", style: TextStyle(color: Colors.black45, fontSize: 19), overflow: TextOverflow.ellipsis),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: Colors.black45),
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
                child: _buildAccountTextField(),
              )
            ],
          ),
          MyDivider(),
        ],
      ),
    );
  }
  ///手机号
  TextFormField _buildAccountTextField() {
    return TextFormField(
        style: TextStyle(fontSize: 19),
        keyboardType: TextInputType.number,
        cursorColor: Global.defredcolor,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: TextEditingController.fromValue(TextEditingValue(
          text: _mobile,
          selection: TextSelection.fromPosition(//保持光标在最后面
            TextPosition(
              affinity: TextAffinity.downstream,
              offset: _mobile.length,
            ),
          ),
        )),
        decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 19, color: Colors.black45),
          counterText: '',
          hintText: "请输入手机号码",
          labelStyle: TextStyle(fontSize: 19, color: Colors.black),
          border: InputBorder.none,
          suffixIcon: this._isShowAccountClean==true ? IconButton(
            icon: Icon(Icons.cancel, color: Colors.grey),
            onPressed: (){
              setState(() {
                _mobile = "";
                _isShowAccountClean = false;
              });
            },
          ) : Text(""),
        ),
        focusNode: _commentFocus_mobile,
        onChanged: (v){setState(() {
          _isShowAccountClean = true;


          if(v.length < 12 && _myCountry == "86" && _mobile.trim() != v){
            _mobile = v;

            if(v.length >= 3 && v.length < 8)
              _mobile = v.substring(0, 3) + " " + v.substring(3, v.length);
            else if(v.length >= 8)
              _mobile = v.substring(0, 3) + " " + v.substring(3, 7) + " " + v.substring(7, v.length);
          }

          else if(v.length < 12){
            _mobile = v;
          }

        });}
    );
  }
  ///密码
  Widget _buildPasswordTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            cursorColor: Global.defredcolor,
            style: TextStyle(color: Colors.black, fontSize: 19),
            focusNode: _passwordFocus_mobile,

            obscureText: !_isShowPwd,
            controller: TextEditingController.fromValue(TextEditingValue(
              text: _password,
              selection: TextSelection.fromPosition(//保持光标在最后面
                TextPosition(
                  affinity: TextAffinity.downstream,
                  offset: _password.length,
                ),
              ),
            )),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: -5,bottom: 0),
              hintStyle: TextStyle(fontSize: 19, color: Colors.black45),
              hintText: "请输入密码",
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderSide: BorderSide.none),
              suffixIcon: IconButton(icon: Icon((_isShowPwd) ? IconFont.icon_yanjing_zheng : IconFont.icon_yanjing, size: 19,), color: Colors.grey,
                onPressed: (){
                  setState(() {
                    _isShowPwd = !_isShowPwd;
                  });
                },
              ),
            ),
            onChanged: (v){setState(() {
              _password = v;
            });},
          ),
          MyDivider(),
        ],
      ),
    );
  }
  ///验证码
  Container _buildVerificationcode(){
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(padding: EdgeInsets.only(top: 0),
                  child: TextFormField(
                    style: TextStyle(fontSize: 19),
                    cursorColor: Global.defredcolor,
                    focusNode: _vcodeFocus,
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
                      hintStyle: TextStyle(fontSize: 19, color: Colors.black45),
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
              Container(
                alignment: Alignment.center,
                child: FlatButton(
                  disabledColor: Colors.black45,     //按钮禁用时的颜色
                  textColor:(_isvButtonEnable&& _mobile != "")?Global.profile.fontColor:Colors.black.withOpacity(0.2),                           //文本颜色
                  splashColor: Colors.transparent,
                  shape: StadiumBorder(side: BorderSide.none,),
                  onPressed: (){
                    if(_isvButtonEnable && _mobile != ""){
                      if(_myCountry == "86" && _mobile.trim().replaceAll(' ', '').length == 11) {
                        _userService.sendVCode(_myCountry + _mobile.trim().replaceAll(' ', ''));
                      }
                      else if(_myCountry == "86" && _mobile.trim().replaceAll(' ', '').length != 11){
                        ShowMessage.showToast("请输入11位手机号!");
                        return;
                      }
                      else if(_myCountry == "852" || _myCountry=="853" || _myCountry=="886"){
                        _userService.sendVCode(_myCountry + _mobile);
                      }
                      else {
                        ShowMessage.showToast("暂时只支持中国地区使用!");
                        return;
                      }
                    }
                    setState(() {
                      if(_isvButtonEnable && _mobile != ""){         //当按钮可点击时
                        _isvButtonEnable=false;   //按钮状态标记
                        _timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
                          _count--;
                          setState(() {
                            if(_count==0){
                              timer.cancel();             //倒计时结束取消定时器
                              _isvButtonEnable=true;        //按钮可点击
                              _count=60;                   //重置时间
                              _buttonText='获取验证码';     //重置按钮文本
                            }else{
                              _buttonText='$_count秒后重试' ;  //更新文本内容
                            }
                          });
                        });
                      }
                    });
                  },
                  child: _myCountry == "86" && _mobile.trim().replaceAll(' ', '').length == 11 || _myCountry != "86" && _mobile != ""?
                    Text('$_buttonText',style: TextStyle(fontSize: 16,color: _isvButtonEnable ? Colors.blue: Colors.grey),): SizedBox.shrink(),
                ),
              ),
            ],
          ),
          MyDivider(),
        ],
      )
    );
  }
  ///登录按钮
  Widget _buildLoginButton(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          if(state.errorstatusCode == "-1008"){
            //需要进行人机验证
            _iscaptcha = true;
            _loadingBlockPuzzle(context);
          }
          else {
            ShowMessage.showToast(state.error!);
          }
          _isLoginButtonEnable = true;
        }
        if (state is AuthenticationAuthenticated){
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Column(
                children: <Widget>[
                  Container(
                    width: 300,
                    height: 43,
                    child: TextButton(
                        child: Text('登录',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),),
                        style: ((_myCountry == "86" && _mobile.trim().replaceAll(' ', '').length == 11 || _myCountry != "86" && _mobile != "") && (_vcode !="" || _password != "")) ? ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Global.defredcolor),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        18.67))),
                        ) : ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Global.defredcolor.withAlpha(119)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                      18.67))),

                        ),
                        onPressed: () async{
                          try{
                            //输入框取消焦点
                            _passwordFocus_mobile.unfocus();
                            _vcodeFocus.unfocus();
                            _commentFocus_mobile.unfocus();

                            if(!_isagree){
                              _isagree = await _buildReadAgreement();
                              setState(() {

                              });
                            }
                            if(!_isagree) {
                              return;
                            }

                            if(_mobile != "" && (_vcode !="" || _password != "") && _isLoginButtonEnable){
                              if(_ismobilelogin){
                                if(_myCountry == "86" && _mobile.trim().replaceAll(' ', '').length == 11) {
                                  _isLoginButtonEnable = false;
                                  _authenticationBloc.add(
                                    LoginButtonPressed(
                                        mobile: _mobile.trim().replaceAll(' ', ''),
                                        password: _password,
                                        vcode: _vcode,
                                        type: 2,
                                        captchaVerification: "",
                                        country: _myCountry
                                    ),
                                  );
                                }
                                else
                                  ShowMessage.showToast("手机号格式错误");
                              }
                              else {
                                if (_iscaptcha) {
                                  _loadingBlockPuzzle(context);
                                }
                                else {
                                  _isLoginButtonEnable = false;
                                  _authenticationBloc.add(
                                    LoginButtonPressed(
                                        mobile: _mobile.trim().replaceAll(' ', ''),
                                        password: _password,
                                        vcode: _vcode,
                                        type: 1,
                                        captchaVerification: "",
                                        country: _myCountry
                                    ),
                                  );
                                }
                              }
                            }
                          }catch(e){
                            _isLoginButtonEnable = true;
                            ShowMessage.showToast("网络不给力，请再试一下!");}
                        }
                    ),
                  ),
                  SizedBox(height: 20.0),
                  _builduseragree(context),
                  SizedBox(height: 20.0),
                  Container(
                    child: state is LoginLoading ? CircularProgressIndicator(
                      valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                    ) : null,
                  ),
                ]
            );
          }
        )
      );
  }

  Widget _buildTitle() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        '登录后更精彩',
        style: TextStyle(fontSize: 30.0,
            color: Colors.black,
        ),
      ),
    );
  }

  //弹出底部菜单确认是否已阅读条款
  Future<bool> _buildReadAgreement() async {
    bool ret = await showModalBottomSheet<bool>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          child: Container(
              alignment: Alignment.center,
              height: 200,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.top),  // !important
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text('请阅读并同意以下条款'),
                      ),
                      SizedBox(height: 40,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Text(
                              '《隐私政策》',
                              style: TextStyle(color: Colors.blue, fontSize: 12),
                            ),
                            onTap: () {
                              //TODO 跳转到登录用户协议页面
                              Navigator.pushNamed(context, '/HtmlContent', arguments: {"parameterkey": "loginuseragree", "title": ""});
                            },
                          ),
                          Text('和', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          GestureDetector(
                            child: Text(
                              '《用户协议》',
                              style: TextStyle(color: Colors.blue, fontSize: 12),
                            ),
                            onTap: () {
                              //TODO 跳转到登录用户协议页面
                              Navigator.pushNamed(context, '/HtmlContent', arguments: {"parameterkey": "useragreement", "title": ""});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    height: 39,
                    width: double.infinity,
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Global.defredcolor),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.67))),
                      ) ,
                      child: Text('同意并继续',
                        style: TextStyle(color: Colors.white, fontSize: 14),),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  )
                ],
              ),
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(9.0), topRight: Radius.circular(9.0)),)),
        );
      },
    ).then((value) async {
      if(value != null){
        return true;
      }
      return false;
    });

    return ret;
  }

  //滑动拼图
  _loadingBlockPuzzle(BuildContext context, {barrierDismissible = true}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v){
            _isLoginButtonEnable = false;
            _authenticationBloc.add(
              LoginButtonPressed(
                  mobile: _mobile.trim().replaceAll(' ', ''),
                  password: _password,
                  vcode: _vcode,
                  type: 1,
                  captchaVerification: v,
                  country: _myCountry

              ),
            );
          },
          onFail: (){

          },
        );
      },
    );
  }
}