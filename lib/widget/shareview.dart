import 'package:flutter/material.dart';

import '../util/imhelper_util.dart';
import '../common/iconfont.dart';
import '../service/userservice.dart';
import '../util/showmessage_util.dart';
import '../service/imservice.dart';
import '../global.dart';
import 'icontext.dart';
import 'my_divider.dart';
import 'weixing/wx_sessionshare_webpage.dart';

class ShareView extends StatefulWidget {
  final Widget? icon;
  String? content;//描述内容
  String? contentid;//根据类型匹配的id
  String? image;//图片
  String? sharedtype;//分享类型 0 活动 1商品 2用户动态
  String? actid;
  int? createuid;//是谁发布的
  Function? activityHomeLongPress;
  Function? activityHomeOnTap;

  ShareView({this.icon, this.sharedtype, this.content, this.contentid, this.image, this.actid, this.createuid,
    this.activityHomeLongPress, this.activityHomeOnTap});

  @override
  _ShareViewState createState() =>_ShareViewState();

}

class _ShareViewState extends State<ShareView> {
  ImHelper _imHelper = new ImHelper();
  UserService _userService  = new UserService();
  ImService _imService = new ImService();
  bool _isGoodPriceInterests = true;//是否对他的好价感兴趣
  bool _isActivityInterests = true;//是否对他的活动感兴趣
  String _strnotinterest = "不看Ta";
  List<int>? _notInterests;
  List<int>? _goodPriceNotInterests;
  bool _isMySelf = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Global.profile.user != null) {
      if (widget.createuid == Global.profile.user!.uid){
        _isMySelf = true;
      }
    }
    // getNotInteresteduid();
  }

  getNotInteresteduid() async {
    if(widget.sharedtype == "0" || widget.sharedtype == "2"  && Global.profile.user != null){
      if(_notInterests == null){
        _notInterests = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
      }

    }

    if(widget.sharedtype == "1" && Global.profile.user != null){
      if(_goodPriceNotInterests == null && Global.profile.user != null){
        _goodPriceNotInterests = await _imHelper.getGoodPriceNotInteresteduids(Global.profile.user!.uid);
      }

    }

    setState(() {

    });

  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        if(Global.profile.user == null){
          Navigator.pushNamed(context, '/Login');
          return;
        }

        showShareView();
      },
      child: widget.icon,
      onTap: () {
        if(widget.activityHomeOnTap != null){
          widget.activityHomeOnTap!();
          return;
        }
        if(Global.profile.user == null){
          Navigator.pushNamed(context, '/Login');
          return;
        }
        showShareView();
      },
    );
  }

  Widget buildBtn(){
    return Container(
        color: Colors.white,
        width: double.infinity,
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(
              child: FlatButton(
                  child: Text('取消', style: TextStyle(color:  Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),),
                  onPressed: (){
                    Navigator.pop(context);
                  }),
            ),
          ],
        )
    );
  }

  Future<void> showShareView() async {
    String img = "";
    if(widget.image != null && widget.image != ""){
      Uri u = Uri.parse(widget.image!);
      img = u.path.substring(1, u.path.length);
    }
    if(widget.sharedtype == "0" || widget.sharedtype == "2" ) {
      _notInterests = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
      if(_notInterests!.contains(widget.createuid)){
        _isActivityInterests = false;
      }
      else{
        _isActivityInterests = true;
      }
    }
    else {
      _goodPriceNotInterests = await _imHelper.getGoodPriceNotInteresteduids(Global.profile.user!.uid);
      if(_goodPriceNotInterests!.contains(widget.createuid)){
        _isGoodPriceInterests = false;
      }
      else{
        _isGoodPriceInterests = true;
      }
    }

    if(widget.sharedtype == "0" || widget.sharedtype == "2"){
      if(_isActivityInterests){
        _strnotinterest = "不看Ta";
      }
      else{
        _strnotinterest = "看Ta";
      }
    }
    else{
      if(_isGoodPriceInterests){
        _strnotinterest = "不看Ta";
      }
      else{
        _strnotinterest = "看Ta";
      }
    }

    Widget gohomepage = Container(
      width: 50,
      alignment: Alignment.center,
      child: IconText("去主页",icon: Icon(IconFont.icon_home_fill, color: Colors.orange, size: 30,),
        style: TextStyle(color: Colors.black87, fontSize: 13), direction: Axis.vertical, onTap: (){
          if(Global.profile.user == null) {
            if(widget.createuid != null)
              Navigator.pushNamed(context, '/OtherProfile', arguments: {"uid": widget.createuid});
          }
          else if(widget.createuid != null && widget.createuid != Global.profile.user!.uid){
            Navigator.pushNamed(context, '/OtherProfile',
                arguments: {"uid": widget.createuid});
          }
          else if(widget.createuid != null && widget.createuid == Global.profile.user!.uid)
            Navigator.pushNamed(context, '/MyProfile');
        },),
    );
    Widget report = Container(
      width: 50,
      alignment: Alignment.center,
      child: _isMySelf ? SizedBox.shrink() : IconText("举报",icon: Icon(IconFont.icon_jubao, color: Colors.red, size: 30,),
        style: TextStyle(color: Colors.black87, fontSize: 13), direction: Axis.vertical, onTap: (){
          Navigator.pushNamed(context, '/ReportActivity', arguments: {"actid": widget.actid, "sourcetype":
          int.parse(widget.sharedtype!), "touid": widget.createuid});
        },),
    );
    Widget like = Container(
      width: 50,
      alignment: Alignment.center,
      child: _isMySelf ? SizedBox.shrink() : IconText(_strnotinterest,icon: Icon(IconFont.icon_buganxingqumian, color: Colors.blueGrey, size: 30,),
        style: TextStyle(color: Colors.black87, fontSize: 13), direction: Axis.vertical, onTap: () async {
          if(widget.createuid == Global.profile.user!.uid){
            ShowMessage.showToast("不能对自己执行这种操作哦~");
            Navigator.pop(context);
            return;
          }
          if(widget.sharedtype == "0" || widget.sharedtype == "2"){
            if(_isActivityInterests){
              //设置不看
              bool ret = await _userService.updateNotinteresteduids(Global.profile.user!.token!,
                  Global.profile.user!.uid,
                  widget.createuid!, (errcode, msg){
                    ShowMessage.showToast(msg);
                  });
              if(ret){
                _imHelper.saveNotInteresteduids(Global.profile.user!.uid, widget.createuid!);
                //这里直接返回首页，首页在长按时弹出分享有点乱了。。
                if(widget.activityHomeLongPress != null){
                  widget.activityHomeLongPress!(true);
                  Navigator.pop(context);
                  return;
                }
                setState(() {
                  _isActivityInterests = false;
                });
              }
            }
            else{
              //取消不看
              bool ret = await _userService.updateNotinteresteduids(Global.profile.user!.token!,
                  Global.profile.user!.uid,
                  widget.createuid!, (errcode, msg){
                    ShowMessage.showToast(msg);
                  });
              if(ret){
                _imHelper.delNotInteresteduids(Global.profile.user!.uid, widget.createuid!);
                setState(() {
                  _isActivityInterests = true;
                });
              }
            }
          }
          else{
            if(_isGoodPriceInterests){
              //设置不看
              bool ret = await _userService.goodpricenotinteresteduids(Global.profile.user!.token!,
                  Global.profile.user!.uid,
                  widget.createuid!, (errcode, msg){
                    ShowMessage.showToast(msg);
                  });
              if(ret){
                _imHelper.saveGoodPriceNotInteresteduids(Global.profile.user!.uid,
                    widget.createuid!);
                //这里直接返回首页，首页在长按时弹出分享有点乱了。。
                if(widget.activityHomeLongPress != null){
                  widget.activityHomeLongPress!(true);
                  Navigator.pop(context);
                  return;
                }
                setState(() {
                  _isGoodPriceInterests = false;
                });
              }
            }
            else{
              //取消不看
              bool ret = await _userService.goodpricenotinteresteduids(Global.profile.user!.token!,
                  Global.profile.user!.uid,
                  widget.createuid!, (errcode, msg){
                    ShowMessage.showToast(msg);
                  });
              if(ret){
                _imHelper.delGoodPriceNotInteresteduids(Global.profile.user!.uid,
                    widget.createuid!);
                setState(() {
                  _isGoodPriceInterests = true;
                });
              }
            }
          }

          Navigator.pop(context);
        },),
    );
    Widget padding = Container(
      width: 50,
      alignment: Alignment.center,
      child: SizedBox.shrink(),
    );

    List<Widget> buttons = [];
    if(widget.sharedtype == "2" && _isMySelf) {
      //如果是自己的动态可以删除
      Widget del = Container(
        width: 50,
        child: IconText("删除",icon: Icon(Icons.delete, color: Colors.red, size: 33,),
          style: TextStyle(color: Colors.black87, fontSize: 13), direction: Axis.vertical, onTap: () async {
            Navigator.pop(context);
            await _asked().then((value){
              if(value){
                Navigator.pop(context, "refresh");
              }
            });
          },),
      );
      buttons.add(del);
      buttons.add(padding);
      buttons.add(padding);
      buttons.add(padding);
    }
    else{
      buttons.add(gohomepage);
      buttons.add(report);
      buttons.add(like);
      buttons.add(padding);
    }



    showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) =>
            Container(
              height: 250,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 10, top: 10),
                    child: Text('分享到', style: TextStyle(color:  Colors.black87, fontSize: 15),),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: IconText("聊天",icon: Icon(IconFont.icon_navbar_xiaoxi_xuanzhong, color: Colors.cyan, size: 30,),
                            style: TextStyle(color: Colors.black87, fontSize: 13), direction: Axis.vertical, onTap: (){
                              Navigator.pushNamed(context, '/SharedRelationList', arguments: {"content": widget.content, "contentid": widget.contentid,
                                "sharedtype": widget.sharedtype, "image": img, "localimg": widget.image});
                            },),
                        ),
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: widget.sharedtype == "0" && widget.sharedtype != "2" ? IconText("粉丝",icon: Icon(IconFont.icon_haoyou, color: Colors.pinkAccent, size: 35,),
                              style:  TextStyle(color: Colors.black87, fontSize: 13), direction: Axis.vertical,onTap: (){
                                Navigator.pushNamed(context, '/ShardeFansList', arguments: {"content": widget.content, "contentid": widget.contentid,
                                  "sharedtype": widget.sharedtype, "image": img, "localimg": widget.image});
                              }) : SizedBox(width: 39,),
                        ),
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: widget.sharedtype == "0" && widget.sharedtype != "2"  ?
                            WXSessionShareWebPage(arguments: {"title": widget.content, "shareType": 0, "img": widget.image, "actid": widget.actid}) : SizedBox(width: 39,),
                        ),
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: widget.sharedtype == "0" && widget.sharedtype != "2"  ?
                            WXSessionShareWebPage(arguments: {"title": widget.content, "shareType": 1, "img": widget.image, "actid": widget.actid}) : SizedBox(width: 39,),
                        ),
                      ],
                    ),
                  ) ,
                  MyDivider(),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: buttons,
                    ),
                  ),
                  Container(
                    height: 10,
                    color: Colors.grey.shade100,
                  ),
                  Expanded(
                    child: buildBtn(),
                  )
                ],
              ),
            )
    ).then((value)  {

    });
  }

  Future<bool> _asked() async {
    String msg = "确认要删除吗?";

    bool? ret = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(msg , style: new TextStyle(fontSize: 17.0)),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () async {
                  bool ret = await _imService.delMoment(Global.profile.user!.token!, Global.profile.user!.uid,
                      widget.contentid!, (String statusCode, String msg){
                        ShowMessage.showToast(msg);
                      });
                  if(ret){
                    ShowMessage.showToast("删除成功");
                    Navigator.pop(context, true);
                  }
                  else{
                    Navigator.pop(context, false);
                  }
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: (){
                  Navigator.pop(context, false);
                },
              )
            ],
          );
        }
    );
    if(ret != null)
      return ret;
    else
      return false;
  }

}
