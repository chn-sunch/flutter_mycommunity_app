import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:steel_crypt/steel_crypt.dart';

import '../../util/captcha/encrypt_util.dart';
import '../../util/captcha/httpmanager_util.dart';
import 'object_utils.dart';
import 'widget_util.dart';

typedef VoidSuccessCallback = dynamic Function(String v);
class ClickWordCaptcha extends StatefulWidget {
  final VoidSuccessCallback? onSuccess; //文字点击后验证成功回调
  final VoidCallback? onFail; //文字点击完成后验证失败回调

  const ClickWordCaptcha({Key? key, this.onSuccess, this.onFail})
      : super(key: key);

  @override
  _ClickWordCaptchaState createState() => _ClickWordCaptchaState();
}

class _ClickWordCaptchaState extends State<ClickWordCaptcha> {
  ClickWordCaptchaState _clickWordCaptchaState = ClickWordCaptchaState.none;
  List<Offset> _tapOffsetList = [];
  ClickWordCaptchaModel _clickWordCaptchaModel = ClickWordCaptchaModel();

  Color titleColor = Colors.black;
  Color borderColor = Color(0xffdddddd);
  String bottomTitle = "";
  Size baseSize = Size(310.0, 155.0);

  //改变底部样式及字段
  _changeResultState() {
    switch (_clickWordCaptchaState) {
      case ClickWordCaptchaState.normal:
        titleColor = Colors.black;
        borderColor = Color(0xffdddddd);
        break;
      case ClickWordCaptchaState.success:
        _tapOffsetList = [];
        titleColor = Colors.green;
        borderColor = Colors.green;
        bottomTitle = "验证成功";
        break;
      case ClickWordCaptchaState.fail:
        _tapOffsetList = [];
        titleColor = Colors.red;
        borderColor = Colors.red;
        bottomTitle = "验证失败";
        break;
      default:
        titleColor = Colors.black;
        borderColor = Color(0xffdddddd);
        bottomTitle = "数据加载中……";
        break;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadCaptcha();
  }

  //加载验证码
  _loadCaptcha() async {
    _tapOffsetList = [];
    _clickWordCaptchaState = ClickWordCaptchaState.none;
    _changeResultState();
    var res = await HttpManager.requestData(
        '/user/captchaget', {"captchaType": "clickWord"}, {});
    if (res['repCode'] != '0000' || res['repData'] == null) {
      _clickWordCaptchaModel.secretKey = "";
      bottomTitle = "加载失败,请刷新";
      _clickWordCaptchaState = ClickWordCaptchaState.normal;
      _changeResultState();
      return;
    } else {
      Map<String, dynamic> repData = res['repData'];
      _clickWordCaptchaModel = ClickWordCaptchaModel.fromMap(repData);

      var baseR = await WidgetUtil.getImageWH(
          image: Image.memory(
              Base64Decoder().convert(_clickWordCaptchaModel.imgStr)));
      baseSize = baseR.size;

      bottomTitle = "请依次点击【${_clickWordCaptchaModel.wordStr}】";
    }

    _clickWordCaptchaState = ClickWordCaptchaState.normal;
    _changeResultState();
  }

  //校验验证码
  _checkCaptcha() async {
    List<Map<String, dynamic>> mousePos = [];
    _tapOffsetList.map((size) {
      mousePos
          .add({"x": size.dx.roundToDouble(), "y": size.dy.roundToDouble()});
    }).toList();
    var pointStr = json.encode(mousePos);

    var cryptedStr = pointStr;

    // secretKey 不为空 进行as加密
    if(!ObjectUtils.isEmpty(_clickWordCaptchaModel.secretKey)){
      var aesEncrypter = AesCrypt(key:_clickWordCaptchaModel.secretKey, padding: PaddingAES.pkcs7).ecb;
      cryptedStr = aesEncrypter.encrypt(inp: pointStr);
      var dcrypt = aesEncrypter.decrypt(enc: cryptedStr);
    }

//    Map _map = json.decode(dcrypt);
    var res = await HttpManager.requestData('/user/captchacheck', {
      "pointJson": cryptedStr,
      "captchaType": "clickWord",
      "token": _clickWordCaptchaModel.token
    }, {});
    if (res['repCode'] != '0000' || res['repData'] == null) {
      _checkFail();
      return;
    }
    Map<String, dynamic> repData = res['repData'];
    if (repData["result"] != null && repData["result"] == true) {
      //如果不加密  将  token  和 坐标序列化 通过  --- 链接成字符串
      var captchaVerification = "${_clickWordCaptchaModel.token}---$pointStr";
      if(!ObjectUtils.isEmpty(_clickWordCaptchaModel.secretKey)){
        //如果加密  将  token  和 坐标序列化 通过  --- 链接成字符串 进行加密  加密密钥为 _clickWordCaptchaModel.secretKey
        captchaVerification = EncryptUtil.aesEncode(key: _clickWordCaptchaModel.secretKey, content: captchaVerification);
      }
      _checkSuccess(captchaVerification);
    } else {
      _checkFail();
    }
  }

  //校验失败
  _checkFail() async {
    _clickWordCaptchaState = ClickWordCaptchaState.fail;
    _changeResultState();

    await Future.delayed(Duration(milliseconds: 1000));
    _loadCaptcha();
    //回调
    if (widget.onFail != null) {
      widget.onFail!();
    }
  }

  //校验成功
  _checkSuccess(String pointJson) async {
    _clickWordCaptchaState = ClickWordCaptchaState.success;
    _changeResultState();

    await Future.delayed(Duration(milliseconds: 1000));

    var aesEncrypter = AesCrypt(key: 'BGxdEUOZkXka4HSj', padding: PaddingAES.pkcs7).ecb;
    var cryptedStr = aesEncrypter.encrypt(inp: pointJson);

    print(cryptedStr);
    //回调   pointJson 是经过es加密之后的信息
    if (widget.onSuccess != null) {
      widget.onSuccess!(cryptedStr);
    }
    //关闭
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var data = MediaQuery.of(context);
    var dialogWidth = 0.9 * data.size.width;
    var isRatioCross = false;
    if(dialogWidth < 320.0 ){
      dialogWidth = data.size.width;
      isRatioCross = true;
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: dialogWidth,
          height: 320,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              _topConttainer(),
              _captchaContainer(),
              _bottomContainer()
            ],
          ),
        ),
      ),
    );
  }

  //图片验证码
  _captchaContainer() {
    List<Widget> _widgetList = [];
    double _widgetW = 20;
    for (int i = 0; i < _tapOffsetList.length; i++) {
      Offset offset = _tapOffsetList[i];
      _widgetList.add(Positioned(
          left: offset.dx - _widgetW * 0.5,
          top: offset.dy - _widgetW * 0.5,
          child: Container(
            alignment: Alignment.center,
            width: _widgetW,
            height: _widgetW,
            decoration: BoxDecoration(
                color: Color(0xCC43A047),
                borderRadius: BorderRadius.all(Radius.circular(_widgetW))),
            child: Text(
              "${i + 1}",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          )));
    }
    _widgetList.add(//刷新按钮
        Positioned(
      top: 0,
      right: 0,
      child: IconButton(
          icon: Icon(Icons.refresh),
          iconSize: 30,
          color: Colors.deepOrangeAccent,
          onPressed: () {
            //刷新
            _loadCaptcha();
          }),
    ));

    return GestureDetector(
        onTapDown: (TapDownDetails details) {
          debugPrint(
              "onTapDown globalPosition全局坐标系位置:  ${details.globalPosition} localPosition组件坐标系位置: ${details.localPosition} ");
          if (!ObjectUtils.isListEmpty(_clickWordCaptchaModel.wordList) &&
              _tapOffsetList.length < _clickWordCaptchaModel.wordList.length) {
            _tapOffsetList.add(
                Offset(details.localPosition.dx, details.localPosition.dy));
          }
          setState(() {});
          if (!ObjectUtils.isListEmpty(_clickWordCaptchaModel.wordList) &&
              _tapOffsetList.length == _clickWordCaptchaModel.wordList.length) {
            _checkCaptcha();
          }
        },
        child: Container(
          width: baseSize.width,
          height: baseSize.height,
          decoration: BoxDecoration(
              image: ObjectUtils.isEmpty(_clickWordCaptchaModel.imgStr)
                  ? null
                  : DecorationImage(
                      image: MemoryImage(Base64Decoder()
                          .convert(_clickWordCaptchaModel.imgStr)))),
          child: Stack(
            children: _widgetList,
          ),
        ));
  }

  //底部提示部件
  _bottomContainer() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(top: 10),
      alignment: Alignment.center,
      width: baseSize.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: borderColor)),
      child:
          Text(bottomTitle, style: TextStyle(fontSize: 18, color: titleColor)),
    );
  }

  //顶部，提示+关闭
  _topConttainer() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      margin: EdgeInsets.only(bottom: 20, top: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Color(0xffe5e5e5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '请完成安全验证',
            style: TextStyle(fontSize: 18),
          ),
          IconButton(
              icon: Icon(Icons.highlight_off),
              iconSize: 35,
              color: Colors.black54,
              onPressed: () {
                //退出
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}

//校验状态
enum ClickWordCaptchaState {
  normal, //默认 可自定义描述
  success, //成功
  fail, //失败
  none, //无状态  用于加载使用
}

//请求数据模型
class ClickWordCaptchaModel {
  String imgStr; //图表url 目前用base64 data
  String token; // 获取的token 用于校验
  List wordList; //显示需要点选的字
  String wordStr; //显示需要点选的字转换为字符串
  String secretKey; //加密key

  ClickWordCaptchaModel(
      {this.imgStr = "",
      this.token = "",
      this.secretKey = "",
      this.wordList = const [],
      this.wordStr = ""});

  //解析数据转换模型
  static ClickWordCaptchaModel fromMap(Map<String, dynamic> map) {
    ClickWordCaptchaModel captchaModel = ClickWordCaptchaModel();
    captchaModel.imgStr = map["originalImageBase64"] ?? "";
    captchaModel.token = map["token"] ?? "";
    captchaModel.secretKey = map["secretKey"] ?? "";
    captchaModel.wordList = map["wordList"] ?? [];

    if (!ObjectUtils.isListEmpty(captchaModel.wordList)) {
      captchaModel.wordStr = captchaModel.wordList.join(",");
    }

    return captchaModel;
  }

  //将模型转换
  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['imgStr'] = imgStr;
    map['token'] = token;
    map['secretKey'] = token;
    map['wordList'] = wordList;
    map['wordStr'] = wordStr;
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return JsonEncoder.withIndent('  ').convert(toJson());
  }
}
