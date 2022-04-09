import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';


import '../../global.dart';
import '../../common/iconfont.dart';
import '../../util/showmessage_util.dart';
import '../icontext.dart';

class WXSessionShareWebPage extends StatefulWidget {
  int shareType = 0;//0会话  1朋友圈
  Map? arguments;
  String title = "一起买一起玩";
  String? description;
  String url = Global.apphost + "web/wxshare.html";
  String web = "";//如果web不是""就导航到web
  String actid = "";//分享的活动id
  String img = "";
  WXSessionShareWebPage({this.arguments}){
    description = "我分享了一个非常不错的线下聚会活动，快来参加吧。";
    if(arguments!["title"] != null && arguments!["title"] != ""){
      title = arguments!["title"];
    }

    shareType = arguments!["shareType"];
    if(arguments!["web"] != null && arguments!["web"] != "" ){
      //分享app，其他的都是分享活动
      web = arguments!["web"];
      description = "一款可以和拥有同样兴趣小伙伴线下约玩的APP，赶快来试试吧。";
    }


    if(arguments!["img"] != null && arguments!["img"] != ""){
      img = arguments!["img"];
    }
    else{
      img = Global.applogourl;
    }

    if(arguments!["actid"] != null && arguments!["actid"] != ""){
      actid = arguments!["actid"];
    }
    else{
      actid = "1";
    }
  }

  @override
  WXSessionShareWebPageState createState() {
    return new WXSessionShareWebPageState();
  }
}

class WXSessionShareWebPageState extends State<WXSessionShareWebPage> {
  WeChatScene scene = WeChatScene.SESSION;

  @override
  void initState() {
    super.initState();
    if(widget.shareType == 0) {
      handleRadioValueChanged(WeChatScene.SESSION);
    }

    if(widget.shareType == 1){
      handleRadioValueChanged(WeChatScene.TIMELINE);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget retWidget = SizedBox.shrink();
    if(widget.shareType == 0){
      retWidget = Container(
        child: IconText("微信",icon: Icon(IconFont.icon_weixin4, color: Colors.green, size: 35,),
            style: TextStyle(color: Colors.black87, fontSize: 13), direction: Axis.vertical,onTap: (){
              _share();

            }),
      );
    }
    if(widget.shareType == 1){
      retWidget = Container(
        child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 35,
                child: Image.asset('images/pengyouquan.png'),
              ),
              Text("朋友圈", style: TextStyle(color: Colors.black87, fontSize: 13))
            ],
          ),
          onTap: (){
            _share();
          },
        ),
      );
    }
    return retWidget;
  }

  void _share() async {
    var model = WeChatShareWebPageModel(widget.web != "" ? widget.web : "${widget.url}?actid=${widget.actid}",
      description: widget.description,
      title: widget.title,
      thumbnail: WeChatImage.network(widget.img),
      scene: scene,
    );


    if(Global.isWeChatInstalled) {
      shareToWeChat(model);
    }
    else{
      ShowMessage.showToast("需要先安装微信，才能使用微信分享");
    }
  }

  void handleRadioValueChanged(WeChatScene scene) {
    setState(() {
      this.scene = scene;
    });
  }
}