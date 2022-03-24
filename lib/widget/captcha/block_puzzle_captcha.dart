import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:steel_crypt/steel_crypt.dart';
import '../../util/captcha/httpmanager_util.dart';
import '../../util/captcha/encrypt_util.dart';
import 'object_utils.dart';
import 'widget_util.dart';

typedef VoidSuccessCallback = dynamic Function(String v);
class BlockPuzzleCaptchaPage extends StatefulWidget {
  final VoidSuccessCallback? onSuccess; //拖放完成后验证成功回调
  final VoidCallback? onFail; //拖放完成后验证失败回调

  BlockPuzzleCaptchaPage({this.onSuccess, this.onFail});

  @override
  _BlockPuzzleCaptchaPageState createState() => _BlockPuzzleCaptchaPageState();
}

class _BlockPuzzleCaptchaPageState extends State<BlockPuzzleCaptchaPage>
    with TickerProviderStateMixin {
//  String baseImageBase64 =
//      "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";
  String baseImageBase64 = "";
  String slideImageBase64 = "";
  String captchaToken = "";
  String secretKey = "";//加密key

  Size baseSize = Size.zero; //底部基类图片
  Size slideSize = Size.zero; //滑块图片


  var sliderColor = Colors.white; //滑块的背景色
  var sliderIcon = Icons.arrow_forward; //滑块的图标
  var movedXBorderColor = Colors.white; //滑块拖动时，左边已滑的区域边框颜色
  double sliderStartX = 0; //滑块未拖前的X坐标
  double sliderXMoved = 0;
  bool sliderMoveFinish = false; //滑块拖动结束
  bool checkResultAfterDrag = false; //拖动后的校验结果

  //-------------动画------------
  int _checkMilliseconds = 0; //滑动时间
  bool _showTimeLine = false; //是否显示动画部件
  bool _checkSuccess = false; //校验是否成功
  late AnimationController controller;

  //高度动画
  late Animation<double> offsetAnimation;

  //底部部件key
  GlobalKey _containerKey = new GlobalKey();
  //背景图key
  GlobalKey _baseImageKey = new GlobalKey();
  //滑块
  GlobalKey _slideImageKey = new GlobalKey();
  double _bottomSliderSize = 60;


  //------------动画------------

  //校验通过
  void checkSuccess(String content) {
    setState(() {
      checkResultAfterDrag = true;
      _checkSuccess = true;
      _showTimeLine = true;
    });
    _forwardAnimation();
    updateSliderColorIcon();

    //刷新验证码
    Future.delayed(Duration(milliseconds: 1000)).then((v) {
      _reverseAnimation().then((v) {
        setState(() {
          _showTimeLine = false;
        });
        //回调
        if (widget.onSuccess != null) {
          widget.onSuccess!(content);
        }
        //关闭验证码
        //print(content);
        Navigator.pop(context);
      });
    });
  }

  //校验失败
  void checkFail() {
    setState(() {
      _showTimeLine = true;
      _checkSuccess = false;
      checkResultAfterDrag = false;
    });
    _forwardAnimation();
    updateSliderColorIcon();

    //刷新验证码
    Future.delayed(Duration(milliseconds: 1000)).then((v) {
      _reverseAnimation().then((v) {
        setState(() {
          _showTimeLine = false;
        });
        loadCaptcha();
        //回调
        if (widget.onFail != null) {
          widget.onFail!();
        }
      });
    });
  }

  //重设滑动颜色与图标
  void updateSliderColorIcon() {
    var _sliderColor; //滑块的背景色
    var _sliderIcon; //滑块的图标
    var _movedXBorderColor; //滑块拖动时，左边已滑的区域边框颜色

    //滑块的背景色
    if (sliderMoveFinish) {
      //拖动结束
      _sliderColor = checkResultAfterDrag ? Colors.green : Colors.red;
      _sliderIcon = checkResultAfterDrag ? Icons.check : Icons.close;
      _movedXBorderColor = checkResultAfterDrag ? Colors.green : Colors.red;
    } else {
      //拖动未开始或正在拖动中
      _sliderColor = sliderXMoved > 0 ? Color(0xff447ab2) : Colors.white;
      _sliderIcon = Icons.arrow_forward;
      _movedXBorderColor = Color(0xff447ab2);
    }

    sliderColor = _sliderColor;
    sliderIcon = _sliderIcon;
    movedXBorderColor = _movedXBorderColor;
    setState(() {});
  }

  //加载验证码
  void loadCaptcha() {
    setState(() {
      _showTimeLine = false;
      sliderMoveFinish = false;
      checkResultAfterDrag = false;
      sliderColor = Colors.white; //滑块的背景色
      sliderIcon = Icons.arrow_forward; //滑块的图标
      movedXBorderColor = Colors.white; //滑块拖动时，左边已滑的区域边框颜色
    });
    HttpManager.requestData(
            '/user/captchaget', {"captchaType": "blockPuzzle"}, {})
        .then((res) async {
      if (res['repCode'] != '0000' || res['repData'] == null) {
        setState(() {
          secretKey = "";
        });
        return;
      }

      Map<String, dynamic> repData = res['repData'];
      sliderXMoved = 0;
      sliderStartX = 0;
      captchaToken = '';
      checkResultAfterDrag = false;

      baseImageBase64 = repData["originalImageBase64"];
      baseImageBase64 = repData["originalImageBase64"];
      secretKey = repData["secretKey"] ?? "";
      baseImageBase64 = baseImageBase64.replaceAll('\n', '');
      slideImageBase64 = repData["jigsawImageBase64"];
      slideImageBase64 = slideImageBase64.replaceAll('\n', '');
      captchaToken = repData["token"];

      var baseR = await WidgetUtil.getImageWH(
          image: Image.memory(Base64Decoder().convert(baseImageBase64)));
      baseSize = baseR.size;

      var silderR = await WidgetUtil.getImageWH(
          image: Image.memory(Base64Decoder().convert(slideImageBase64)));
      slideSize = silderR.size;

      setState(() {});
    }).catchError((error) {
      print(error);
    });
  }

  //校验验证码
  void checkCaptcha(sliderXMoved, captchaToken, {BuildContext? myContext}) {
    setState(() {
      sliderMoveFinish = true;
    });
    //滑动结束，改变滑块的图标及颜色
//    updateSliderColorIcon();

    //pointJson参数需要aes加密

//    MediaQueryData mediaQuery = MediaQuery.of(myContext);
    var pointMap = {"x": sliderXMoved, "y": 5};
    var pointStr = json.encode(pointMap);
    var cryptedStr = pointStr;

    // secretKey 不为空 进行as加密
    if(!ObjectUtils.isEmpty(secretKey)){
      var content = utf8.encode(secretKey);
      var temsecretKey = base64Encode(content);

      var aesEncrypter = AesCrypt(key:temsecretKey, padding: PaddingAES.pkcs7);
      cryptedStr = aesEncrypter.ecb.encrypt(inp: pointStr);
      var dcrypt = aesEncrypter.ecb.decrypt(enc: cryptedStr);
      Map _map = json.decode(dcrypt);
    }


    HttpManager.requestData('/user/captchacheck', {
      "pointJson": cryptedStr,
      "captchaType": "blockPuzzle",
      "token": captchaToken
    }, {}).then((res) {
      if (res['repCode'] != '0000' || res['repData'] == null) {
        checkFail();
        return;
      }

      Map<String, dynamic> repData = res['repData'];
      if (repData["result"] != null && repData["result"] == true) {
        //如果不加密  将  token  和 坐标序列化 通过  --- 链接成字符串
        var captchaVerification = "$captchaToken---$pointStr";
        if(!ObjectUtils.isEmpty(secretKey)){
          //如果加密  将  token  和 坐标序列化 通过  --- 链接成字符串 进行加密  加密密钥为 _clickWordCaptchaModel.secretKey
          captchaVerification = EncryptUtil.aesEncode(key: secretKey, content: captchaVerification);
        }
        checkSuccess(captchaVerification);
      } else {
        checkFail();
      }
    }).catchError((error) {
      loadCaptcha();
      print(error);
    });
  }

  @override
  void initState() {
    super.initState();
    initAnimation();
    loadCaptcha();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 初始化动画
  void initAnimation() {
    controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);

    offsetAnimation = Tween<double>(begin: 0.5, end: 0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.ease))
          ..addListener(() {
            this.setState(() {});
          });
  }

  // 反向执行动画
  _reverseAnimation() async {
    await controller.reverse();
  }

  // 正向执行动画
  _forwardAnimation() async {
    await controller.forward();
  }

  @override
  void didUpdateWidget(BlockPuzzleCaptchaPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return MaxScaleTextWidget(
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var dialogWidth = 0.9 * mediaQuery.size.width;
    if (dialogWidth < 330) {
      dialogWidth = mediaQuery.size.width;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          key: _containerKey,
          width: dialogWidth,
          height: 340,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _topContainer(),
              _middleContainer(),
              _bottomContainer(),
            ],
          ),
        ),
      ),
    );
  }

  ///顶部，提示+关闭
  _topContainer() {
    return Container(
      height: 50,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
              iconSize: 30,
              color: Colors.black38,
              onPressed: () {
                //退出
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  _middleContainer() {
    ////显示验证码
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        children: <Widget>[
          ///底图 310*155
          baseImageBase64.length > 0
              ? Image.memory(
            Base64Decoder().convert(baseImageBase64),
            fit: BoxFit.fitWidth,
            key: _baseImageKey,
            gaplessPlayback: true,
          )
              : Container(
            width: 310,
            height: 155,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),

          ///滑块图
          slideImageBase64.length > 0
              ? Container(
            margin: EdgeInsets.fromLTRB(sliderXMoved, 0, 0, 0),
            child: Image.memory(
              Base64Decoder().convert(slideImageBase64),
              fit: BoxFit.fitHeight,
              key: _slideImageKey,
              gaplessPlayback: true,
            ),
          )
              : Container(),

          //刷新按钮
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
                icon: Icon(Icons.refresh),
                iconSize: 30,
                color: Colors.black54,
                onPressed: () {
                  //刷新
                  loadCaptcha();
                }),
          ),
          Positioned(
              bottom: 0,
              left: -10,
              right: -10,
              child: Offstage(
                offstage: !_showTimeLine,
                child: FractionalTranslation(
                  translation: Offset(0, offsetAnimation.value),
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    color: _checkSuccess
                        ? Color(0x7F66BB6A)
                        : Color.fromRGBO(200, 100, 100, 0.4),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _checkSuccess
                          ? "${(_checkMilliseconds / (60.0 * 12)).toStringAsFixed(2)}s验证成功"
                          : "验证失败",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )),
          Positioned(
              bottom: -20,
              left: 0,
              right: 0,
              child: Offstage(
                offstage: !_showTimeLine,
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  height: 20,
                  color: Colors.white,
                ),
              ))
        ],
      ),
    );
  }
  ///底部，滑动区域
  _bottomContainer() {
    return baseSize.width >0
        ? Container(
        height: 70,
        width: baseSize.width,
//            color: Colors.cyanAccent,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: <Widget>[
            Container(
              height: _bottomSliderSize,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Color(0xffe5e5e5),
                ),
                color: Color(0xfff8f9fb),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                '向右拖动滑块填充拼图',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Container(
              width: sliderXMoved,
              height: _bottomSliderSize-2,
              decoration: BoxDecoration(
                border: Border.all(
                  width: sliderXMoved > 0 ? 1 : 0,
                  color: movedXBorderColor,
                ),
                color: Color(0xfff3fef1),
              ),
            ),
            GestureDetector(
              onPanStart: (startDetails) {///开始
                _checkMilliseconds = new DateTime.now().millisecondsSinceEpoch;
                print(startDetails.localPosition);
                sliderStartX = startDetails.localPosition.dx;
              },
              onPanUpdate: (updateDetails) { ///更新
                print(updateDetails.localPosition);
                double _w1 = _baseImageKey.currentContext!.size!.width - _slideImageKey.currentContext!.size!.width;
                double offset = updateDetails.localPosition.dx - sliderStartX;
                if(offset < 0){
                  offset = 0;
                }
                if(offset > _w1){
                  offset = _w1;
                }
                print("offset ------ $offset");
                setState(() {
                  sliderXMoved = offset;
                });
                //滑动过程，改变滑块左边框颜色
                updateSliderColorIcon();
              },
              onPanEnd: (endDetails) { //结束
                print("endDetails");
                checkCaptcha(sliderXMoved, captchaToken);
                int _nowTime = new DateTime.now().millisecondsSinceEpoch;
                _checkMilliseconds = _nowTime - _checkMilliseconds;
              },
              child: Container(
                width: _bottomSliderSize,
                height: _bottomSliderSize,
                margin: EdgeInsets.only(left: sliderXMoved > 0 ? sliderXMoved : 1),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 1,
                      color: Color(0xffe5e5e5),
                    ),
                    right: BorderSide(
                      width: 1,
                      color: Color(0xffe5e5e5),
                    ),
                    bottom: BorderSide(
                      width: 1,
                      color: Color(0xffe5e5e5),
                    ),
                  ),
                  color: sliderColor,
                ),
                child: IconButton(
                  onPressed: null,
                  icon: Icon(sliderIcon),
                  iconSize: 30,
                  color: Colors.black54,
                ),
              ),
            )
          ],
        ))
        : Container();
  }
}


class MaxScaleTextWidget extends StatelessWidget {
  final double max;
  Widget child;

  MaxScaleTextWidget({Key? key, this.max = 1.0,required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = MediaQuery.of(context);
    var textScaleFactor = min(max, data.textScaleFactor);
    return MediaQuery(data: data.copyWith(textScaleFactor: textScaleFactor), child: child);
  }
}
