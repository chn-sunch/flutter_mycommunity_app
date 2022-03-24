import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global.dart';
import '../widget/privacyview.dart';


class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return  SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {

  String _data =
      "我们依据最新的监管要求更新了《用户协议》和《隐私政策》(点击了解更新后的详细内容),特向您说明如下：\n" +
      "1.为向您提供更优质的服务，我们会收集、使用必要的信息；\n" +
      "2.基于您的明示授权，我们可能会获取您的位置（为您提供附近的活动、商品等）、设备号信息（为保障您账号与交易安全）等信息，您有权拒绝或取消授权；\n" +
      "3.我们会采取业界新进的安全措施保护您的信息安全；\n" +
      "4.未经您同意，我们不会从第三方获取、共享或向其提供您的信息；\n" +
      "5.您可以查询、更正、删除您的个人信息，我们也提供账户注销的渠道。\n";
  @override
  void initState() {
    super.initState();
  }

  Future<void> _agreeprivacy() async {
    SharedPreferences _isagreeprivacy = await SharedPreferences.getInstance();
    _isagreeprivacy.setString("isagreeprivacy", "1");
  }

  void _goMain() {
    Navigator.of(context).pushReplacementNamed('/main');
  }

  Widget _buildSplashBg() {
    return Stack(
      children: <Widget>[
        Image.asset(
          "images/splashpage/launch_image.png",
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        Opacity(
          opacity: 0.3,
          child: Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
        Center(
          child: Container(
            padding: EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * .6,
            width: MediaQuery.of(context).size.width * .8,
            child: Column(
              children: [
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '温馨提示',
                    style: TextStyle(
                        fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: PrivacyView(
                          data: _data,
                          keys: ['《用户协议》', '《隐私政策》'],
                          keyStyle: TextStyle(color: Colors.blue, fontSize: 12),
                          style: TextStyle(color: Colors.black, fontSize: 12),
                          onTapCallback: (String key) {
                            if (key == '《用户协议》') {
                              Navigator.pushNamed(context, '/HtmlContent', arguments: {"parameterkey": "useragreement", "title": ""});
                            } else if (key == '《隐私政策》') {
                              Navigator.pushNamed(context, '/HtmlContent', arguments: {"parameterkey": "loginuseragree", "title": ""});
                            }
                          },
                        ),
                      ),
                    )),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ButtonTheme(
                        minWidth: 120.0,
                        child: OutlineButton(
                          color: Colors.white,
                          onPressed: () {
                            exit(0);
                          },
                          child: Text('不同意',style: TextStyle(fontSize: 14.0,color: Colors.black),),
                          ///圆角
                          shape: RoundedRectangleBorder(
                              side: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                        ),
                      ),
                      ButtonTheme(
                        minWidth: 120.0,//设置最小宽度
                        child: RaisedButton(
                          color: Global.defredcolor,
                          onPressed: () async {
                            _agreeprivacy();
                            _goMain();
                          },
                          child: Text('同意',style: TextStyle(fontSize: 14.0,color: Colors.white),),
                          ///圆角
                          shape: RoundedRectangleBorder(
                              side: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20,)
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        )
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: _buildSplashBg(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}