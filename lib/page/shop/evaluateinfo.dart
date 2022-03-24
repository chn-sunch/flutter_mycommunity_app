
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/evaluateactivityreply.dart';
import '../../model/user.dart';
import '../../service/activity.dart';
import '../../service/gpservice.dart';
import '../../util/showmessage_util.dart';
import '../../global.dart';
import '../../model/evaluateactivity.dart';
import '../../common/iconfont.dart';
import '../../widget/circle_headimage.dart';


class EvaluateInfo extends StatefulWidget {
  Object? arguments;
  late EvaluateActivity evaluateActivity;

  EvaluateInfo({this.arguments}){
    this.evaluateActivity = (arguments as Map)["evaluateActivity"];
  }

  @override
  _EvaluateInfoState createState() => _EvaluateInfoState();
}

class _EvaluateInfoState extends State<EvaluateInfo> {
  String _message = "";
  bool isEnter = true;
  bool _isLikeEnter = true;
  String _hidemessage = "留言问问活动细节吧~";
  List<EvaluateActivityReply> evaluateReplys = [];
  final ActivityService _activityService = new ActivityService();
  final GPService _gpService = GPService();

  double _pageWidth = 0;
  int temreplyid = -1;

  getEvaluateReplys() async {
    evaluateReplys = await _activityService.getEvaluateReplyList(widget.evaluateActivity.evaluateid!, errorCallBack);
    setState(() {

    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEvaluateReplys();
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    _pageWidth = MediaQuery.of(context).size.width - 28; //28是左右间隔

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('评价详情', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          NoCacheCircleHeadImage(imageUrl: widget.evaluateActivity.user!.profilepicture!,
                            width: 45, uid: widget.evaluateActivity.user!.uid,),
                          InkWell(
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                mainAxisAlignment: MainAxisAlignment
                                    .start,
                                children: <Widget>[
                                  Text(widget.evaluateActivity.user!.username,
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14),),
                                  Text(widget.evaluateActivity.createtime!.substring(0, 10),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14),),
                                ],
                              ),
                            ),
                            onTap: () {
                              int uid = widget.evaluateActivity.user!.uid;
                              if(Global.profile.user == null) {
                                if(uid != null)
                                  Navigator.pushNamed(context, '/OtherProfile', arguments: {"uid": uid});
                              }
                              else if(uid != null && uid != Global.profile.user!.uid){
                                Navigator.pushNamed(context, '/OtherProfile',
                                    arguments: {"uid": uid});
                              }
                              else if(uid != null && uid == Global.profile.user!.uid)
                                Navigator.pushNamed(context, '/MyProfile');
                            },
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          widget.evaluateActivity.liketype == 1 ? Icon(IconFont.icon_haoping1, color: Colors.redAccent,) : SizedBox.shrink()
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.all(10),
                  child: Text(widget.evaluateActivity.content!, style: TextStyle(
                      color: Colors.black, fontSize: 14),),
                ),
                widget.evaluateActivity.imagepaths! != null && widget.evaluateActivity.imagepaths!.isNotEmpty ? Container(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Column(
                      children: getImageList(widget.evaluateActivity.imagepaths!),
                    )
                ) : SizedBox.shrink(),
              ],
            ),
          ),
          buildReply()
        ],
      ),
      bottomNavigationBar:buildBottomButton()
    );
  }

  List<Widget> getImageList(String imagepaths){
    List<String> paths = imagepaths.split(',');
    List<Widget> images = [];
    paths.map((e){
      images.add(
        Padding(
          padding: EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(0)),
            child: CachedNetworkImage(
              imageUrl: '${e.toString()}?x-oss-process=image/resize,m_fixed,w_1080/sharpen,50/quality,q_80',
              fit: BoxFit.cover,
            ),
          ),
        )
      );
    }).toList();

    return images;
  }

  Widget buildBottomButton() {
    bool _islike = widget.evaluateActivity.likeuid == Global.profile.user!.uid;

    return Container(
      height: 70,
      color: Colors.white,
      padding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(_islike ? IconFont.icon_zan1   : IconFont
                        .icon_aixin, color: _islike ?
                    Colors.redAccent : Colors.grey,),
                    onPressed: () async {
                      if (_isLikeEnter) {
                        _isLikeEnter = false;
                        if (!_islike) {
                          bool ret = await _activityService.updateEvaluateLike(widget.evaluateActivity.evaluateid!, Global.profile.user!.uid,
                              Global.profile.user!.token!, widget.evaluateActivity.user!.uid, "", errorCallBack);
                          if(ret){
                            setState(() {
                              _isLikeEnter = true;
                              widget.evaluateActivity.likeuid = Global.profile.user!.uid;
                              widget.evaluateActivity.likenum = widget.evaluateActivity.likenum! + 1;
                            });
                          }
                        }
                        else{
                          bool ret = await _activityService.delEvaluateLike(widget.evaluateActivity.evaluateid!, Global.profile.user!.uid,
                              Global.profile.user!.token!, widget.evaluateActivity.user!.uid, errorCallBack);
                          if(ret){
                            setState(() {
                              widget.evaluateActivity.likeuid = 0;
                              widget.evaluateActivity.likenum = widget.evaluateActivity.likenum! - 1;
                            });
                          }
                        }
                      }
                    }
                  ),
                  Text(widget.evaluateActivity.likenum.toString(),
                      style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(IconFont.icon_liuyan, color: Colors.grey,),
                    onPressed: () {
                      if(Global.profile.user != null) {
                        _hidemessage = "留言问问活动细节吧~";
                        sendMessage(widget.evaluateActivity.evaluateid!, widget.evaluateActivity.user!.uid, widget.evaluateActivity.user!);
                      }
                      else{
                        Navigator.pushNamed(context, '/Login').then((val) {
                          if (Global.profile.user != null) {
                            setState(() {
                            });
                          }
                        });
                      }
                    },
                  ),
                  Text(
                      "回复", style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  //留言输入框
  void sendMessage(int evaluateid, int touid, User user){
    showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),  // !important
              margin: EdgeInsets.only(right: 10),
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.keyboard_hide,
                      color: Colors.black54,),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                        maxLength: 255,
                        maxLines: null,
                        autofocus: true,
                        onChanged: (val) {
                          _message = val;
                        },

                        decoration: InputDecoration(
                            fillColor: Colors.grey,
                            border: InputBorder.none,
                            hintText: _hidemessage,
                            counterText: ''
                        )
                    ),
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.all(
                            Radius.circular(5))),
                    child: Text('发送',
                      style: TextStyle(color: Colors.white),),
                    color: Colors.redAccent,
                    onPressed: () async {
                      if (_message.isNotEmpty) {
                        bool ret = await _activityService.evaluateReply(widget.evaluateActivity.evaluateid!,
                            Global.profile.user!.uid,Global.profile.user!.token!, touid, _message, errorCallBack);
                        if(ret){
                           setState(() {
                             temreplyid -= 1;
                             evaluateReplys.insert(0, EvaluateActivityReply(temreplyid, widget.evaluateActivity.evaluateid,
                               Global.profile.user, user, _message, DateTime.now().toString(), false,"",false,"","",""));
                             widget.evaluateActivity.replynum = widget.evaluateActivity.replynum! + 1;
                           });
                        }
                        Navigator.pop(context);
                      }
                      else {
                        ShowMessage.showToast('输入回复内容!');
                      }
                    },
                  )
                ],
              )
          ),
        );
      },
    ).then((value) async {

    });
  }
  //获取回复列表
  Widget buildReply(){
    return Container(
        margin: EdgeInsets.only(top: 10),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(' ${widget.evaluateActivity.replynum} 条回复',
                      style: TextStyle(color: Colors.black87, fontSize: 14)),
                ],
              ),
              SizedBox(height: 10,),
              buildComment(evaluateReplys),
            ],
          ),
        )
    );
  }

  Widget buildComment(List<EvaluateActivityReply> listEvaluateReplys ) {
    List<Widget> tem = [];
    if (listEvaluateReplys != null && listEvaluateReplys.length > 0) {
      listEvaluateReplys.map((v) {
        String toname = "";
        if(v.touser!.uid != widget.evaluateActivity.user!.uid){
          toname = "回复${v.touser!.username} ";
        }
        tem.add(
            Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  NoCacheCircleHeadImage(imageUrl: v.replyuser!.profilepicture!, width: 30, uid: v.replyuser!.uid,),
                                  InkWell(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Text(v.replyuser!.username,
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13),),
                                          Text(v.replycreatetime!.substring(5, 10),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      int uid = v.replyuser!.uid;
                                      if(Global.profile.user == null) {
                                        if(uid != null)
                                          Navigator.pushNamed(context, '/OtherProfile', arguments: {"uid": uid});
                                      }
                                      else if(uid != null && uid != Global.profile.user!.uid){
                                        Navigator.pushNamed(context, '/OtherProfile',
                                            arguments: {"uid": uid});
                                      }
                                      else if(uid != null && uid == Global.profile.user!.uid)
                                        Navigator.pushNamed(context, '/MyProfile');
                                    },
                                  )
                                ],
                              ),

                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 30,top: 5),
                            child: Text('${toname}${v.replycontent}', style: TextStyle(
                                color: Colors.black, fontSize: 14),),
                          ),
                        ],
                      ),
                      onTap: (){
                        _hidemessage = '回复@${v.replyuser!.username}';
                        sendMessage(v.evaluateid!, v.replyuser!.uid, v.replyuser!);
                      },
                    ),
                  ],
                )
            )
        );
      }).toList();
    }
    else {
      tem.add(Container(height: 50, width: double.infinity,
        child: Center(child: Text('还没有任何留言'),),));
    }
    return Column(
        children: tem
    );
  }


  errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}
