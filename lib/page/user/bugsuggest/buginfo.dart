import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../global.dart';
import '../../../util/common_util.dart';
import '../../../util/imhelper_util.dart';
import '../../../util/showmessage_util.dart';
import '../../../model/bugsuggestion/bug.dart';
import '../../../model/user.dart';
import '../../../model/comment.dart';
import '../../../model/commentreply.dart';
import '../../../common/iconfont.dart';
import '../../../service/imservice.dart';
import '../../../widget/circle_headimage.dart';
import '../../../widget/photo/photo_viewwrapper.dart';
import '../../../widget/captcha/block_puzzle_captcha.dart';

class BugInfo extends StatefulWidget {
  Object? arguments;
  String bugid = "";


  BugInfo({this.arguments}){
    if(arguments != null){
      bugid = (arguments as Map)["bugid"];
    }
  }

  @override
  _BugInfoState createState() => _BugInfoState();
}

class _BugInfoState extends State<BugInfo> {
  Bug? _bug;
  String _sortname = "按时间";
  List<String> _listimgs = [];
  List<Map<String, String>> imglist = [];
  double _pageWidth = 0;
  bool _islike = false, _isLikeEnter = true, _isCommentLike = true;
  String _hidemessage = "给楼主留言";
  String _message = "";
  ImService imService = new ImService();
  List<Comment> listComments = [];
  String _ordertype = "0";//排序类型， 0：按时间 1：按热度
  ImHelper imhelper = new ImHelper();
  String error = "";
  String errorstatusCode = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.bugid != null){
      getBug();
    }
  }

  getBug() async {
    _bug = await imService.getBugInfo(Global.profile.user!.uid, Global.profile.user!.token!, widget.bugid, errorCallBack);
    if(_bug != null) {
      listComments = await imService.getBugCommentList(
          _bug!.bugid, Global.profile.user!.uid, errorCallBack);
      await imhelper.selBugAndSuggestState(widget.bugid, Global.profile.user!.uid, 0, (List<String> actid){
        if(actid.length > 0)
          _islike = true;
      });
      if(listComments != null && listComments.length > 0){
        listComments = sortComment(listComments, _ordertype);
      }
      setState(() {});
    }
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
          title: Text('Bug内容', style: TextStyle(color: Colors.black, fontSize: 16)),
          centerTitle: true,
        ),
        body: _bug != null ? ListView(
          // item 内容内边距
          children: <Widget>[
            Container(
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10,bottom: 10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildHeadInfo(),
                          SizedBox(height: 10,),
                          buildContent(),
                          buildContentImg(),
                          SizedBox(height: 10,),
                        ]))),
            buildCommentContainer(listComments)
            //评论
          ],
        ) : Center(
          child: CircularProgressIndicator(
            valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
          ),
        ),
        bottomNavigationBar: buildBottomButton()
    );
  }

  //头部，社团头像。名称，等
  Container buildHeadInfo() {
    return Container(
      height: 70,
      child: Row(
        children: <Widget>[
          NoCacheCircleHeadImage(
            width: 60,
            uid: _bug!.user!.uid,
            imageUrl: _bug!.user!.profilepicture! ,
          ),
          Padding(padding: EdgeInsets.only(left: 10),),
          Expanded(
            child:           Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_bug!.user!.username, style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(CommonUtil.datetimeFormat(DateTime.parse(_bug!.createtime))),
              ],
            ),
          )
        ],
      ),
    );
  }
  //获取BUG内容
  Widget buildContent() {
    return SafeArea(
      child: Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_bug!.content, style: TextStyle(color: Colors.black87, fontSize: 14, ),),
            ],
          )
      ),
    );
  }
  //内容图片
  Widget buildContentImg() {
    if(_bug!.images == ""){
      return SizedBox.shrink();
    }
    _listimgs = _bug!.images.split(',');
    if(_listimgs.length > 0){
      for(int i=0;i<_listimgs.length;i++){
        imglist.add({"tag": UniqueKey().toString(),"img": _listimgs[i].toString()});
      }
    }


    if(Global.isInDebugMode) {
      print('${_listimgs[0]}?x-oss-process=image/resize,m_fixed,w_1080/sharpen,50/quality,q_80');
    }
    return Column(
      children: _listimgs.asMap().keys.map((i) {
        return Container(
          margin: EdgeInsets.only(top: 10),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: InkWell(
                onTap: (){
                  showPhoto(context, imglist[i], i);
                },
                child: CachedNetworkImage(
                  placeholder: (context,url)=>   Container() ,
                  imageUrl: '${_listimgs[i]}?x-oss-process=image/resize,m_fixed,w_1080/sharpen,50/quality,q_80',
                  fit: BoxFit.cover,
                ),
              )
          ),
        );
      }).toList(),
    );
  }
  //错误重新加载
  Widget buildReLoadData() {
    return InkWell(
      child: Center(
        child: Text('点击屏幕，重新加载', style: TextStyle(color: Colors.black54, fontSize: 15),),
      ),
      onTap: () {

      },
    );
  }

  Widget buildCommentContainer(List<Comment> comments){
    Widget actComment = SizedBox.shrink();
    if(comments != null && comments.length > 0){
      _isCommentLike = true;
      actComment = Container(
          margin: EdgeInsets.only(top: 10),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween,
                  children: <Widget>[
                    Text('全部留言(${comments.length.toString()})', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                    InkWell(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.menu,
                            color: Colors.black45,
                            size: 18,
                          ),
                          Text(_sortname, style: TextStyle(color: Colors.black45, fontSize: 13),)
                        ],
                      ),
                      onTap: () {
                        if (comments != null && comments.length > 0) {
                          if (_sortname == "按时间") {
                            _sortname =
                            '按热度'; //当前排序方式
                            _ordertype = "1";
                            sortComment(comments, _ordertype);
                            setState(() {

                            });
                          }
                          else {
                            _sortname = '按时间';
                            _ordertype = "0";
                            sortComment(comments, _ordertype);
                            setState(() {

                            });
                          }
                        }
                      },
                    )
                  ],
                ),
                SizedBox(height: 5,),
                buildComment(comments),

              ],
            ),
          )
      );
    }
    else {
      actComment = Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween,
                    children: <Widget>[
                      Text('全部留言', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 5,),
                  Container(height: 50, width: double.infinity, child: Center(child: Text('还没有任何留言', style: TextStyle(color: Colors.black54, fontSize: 14, )),),),
                ]
            ),
          )
      );
    }

    return actComment;
  }

  Widget buildComment(List<Comment> comments) {
    List<Widget> tem = [];
    if (comments != null && comments.length > 0) {
      listComments = comments;
      
      listComments.map((v) {
        tem.add(
            Container(
                margin: EdgeInsets.only(bottom: 10),
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
                                  NoCacheCircleHeadImage(imageUrl: v.user!.profilepicture!, width: 30, uid: v.user!.uid,),
                                  InkWell(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Text(v.user!.username,
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13),),
                                          Text(v.createtime!.substring(5, 10),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      int uid = v.user!.uid;
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
                                  IconButton(
                                    padding: EdgeInsets.all(5),
                                    alignment: Alignment.centerRight,
                                    icon: Icon((Global.profile.user == null || v.likeuid != Global.profile.user!.uid) ? IconFont.icon_dianzan1 :
                                    IconFont.icon_tubiaozhizuo_, size: 18,color:
                                    (Global.profile.user == null || v.likeuid != Global.profile.user!.uid) ? Colors.black38: Global.profile.backColor,),
                                    onPressed: () async {
                                      if(_isCommentLike) {
                                        _isCommentLike = false;
                                        if (v.likeuid == 0) {
                                          bool ret = await imService.updateBugCommentLike(v.commentid!, Global.profile.user!.uid,
                                            Global.profile.user!.token!, v.user!.uid, widget.bugid, errorCallBack);
                                          if(ret){
                                            //List<Comment> listComments = await _activityService.getCommentList(event.actid, event.user.uid, errorCallBack);
                                            comments.forEach((e){
                                                if(e.commentid == v.commentid){
                                                  e.likeuid = Global.profile.user!.uid;
                                                  e.likenum = e.likenum! + 1;
                                                }
                                            });
                                            setState(() {

                                            });
                                          }
                                        }
                                        else {
                                          bool ret = await imService.delBugCommentLike(v.commentid!, Global.profile.user!.uid,
                                              Global.profile.user!.token!, v.user!.uid, errorCallBack);
                                          if(ret){
                                            comments.forEach((e){
                                              if(e.commentid == v.commentid){
                                                e.likeuid = 0;
                                                e.likenum = e.likenum! - 1;
                                              }
                                            });
                                            setState(() {

                                            });
                                          }
                                        }
                                        _isCommentLike = true;
                                      }
                                    },
                                  ),
                                  Text(v.likenum == 0 ?'':v.likenum.toString(),style: TextStyle(color: Colors.black38),),
                                ],
                              )

                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 40),
                            child: Text(v.content!, style: TextStyle(
                                color: Colors.black, fontSize: 14),),
                          ),
                          (v.replys != null) ? buildChildComment(v.replys!):SizedBox(height: 0,),
                        ],
                      ),
                      onTap: (){
                        _hidemessage = '回复@${v.user!.username}';
                        sendMessage(v.commentid!, v.user!.uid, touser: v.user!);
                      },
                      onLongPressStart: (detail) {
                        if(Global.profile.user != null && v.user!.uid == Global.profile.user!.uid){
                          final RelativeRect position = RelativeRect.fromLTRB(
                              detail.globalPosition.dx,
                              detail.globalPosition.dy,
                              //取text高度做弹出y坐标（这样弹出就不会遮挡文本）
                              detail.globalPosition.dx,
                              detail.globalPosition.dy);
                          showMenu(context: context,
                              position: position,
                              items: <PopupMenuEntry>[
                                PopupMenuItem(
                                  child: InkWell(
                                    child: Text('删除'),
                                    onTap: () async {
                                      bool ret = await imService.delMessage( Global.profile.user!.token!, Global.profile.user!.uid,
                                          v.commentid!, widget.bugid, errorCallBack);
                                      if(ret){
                                        listComments = await imService.getBugCommentList(widget.bugid, Global.profile.user!.uid, errorCallBack);
                                        if(listComments != null && listComments.length > 0){
                                          listComments = sortComment(listComments, _ordertype);
                                        }
                                        setState(() {

                                        });
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                PopupMenuItem(
                                  child: InkWell(
                                    child: Text('取消'),
                                    onTap: (){
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                              ]
                          );
                        }
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
        child: Center(child: Text('还没有任何留言', style: TextStyle(color: Colors.black54, fontSize: 14, ),),),));
    }
    return Column(
        children: tem
    );
  }

  Widget buildBottomButton() {
    return Container(
      height: 80,
      color: Colors.white,
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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
                    Global.profile.backColor : Colors.grey,),
                    onPressed: () async {
                      if(_isLikeEnter) {
                        _isLikeEnter = false;
                        if (!_islike){
                          if(await imService.updateBugLike(widget.bugid, Global.profile.user!.uid, Global.profile.user!.token!, errorCallBack)){
                            setState(() {
                              _bug!.likenum = _bug!.likenum + 1;
                              _islike = true;
                            });
                          }
                        }
                        else {
                          if(await imService.delBugLike(widget.bugid, Global.profile.user!.uid, Global.profile.user!.token!, errorCallBack)){
                            setState(() {
                              _bug!.likenum = _bug!.likenum-1;
                              _islike = false;
                            });
                          }
                        }
                        _isLikeEnter = true;
                      }
                    },
                  ),
                  Text(_bug == null ? "0" : _bug!.likenum.toString(),
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
                        _hidemessage = "快给楼主留言吧";
                        sendMessage(0, _bug!.user!.uid);
                      }
                      else{
                        Navigator.pushNamed(context, '/Login').then((val) {

                        });
                      }
                    },
                  ),
                  Text(
                      "留言", style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void sendMessage(int commentid, int touid, {User? touser}){
    showModalBottomSheet<String>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              height: 80,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.top),  // !important
              margin: EdgeInsets.only(right: 10),
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),),
                    color: Global.profile.backColor,
                    onPressed: () async {
                      if (_message.isNotEmpty) {
                        if(commentid == 0){
                          Navigator.pop(context);
                          int retcommentid = await imService.updateBugMessage(widget.bugid, Global.profile.user!.uid,
                              Global.profile.user!.token!, touid, _message, "", errorCallBack);
                          if(retcommentid > 0) {
                            listComments.insert(0, Comment(
                                retcommentid,
                                _bug!.bugid,
                                Global.profile.user,
                                _message,
                                0,
                                CommonUtil.getTime(),
                                0));
                            setState(() {

                            });
                          }
                          else{
                            errorHandle(commentid == null ? 0 : commentid, touid, touser);
                          }
                        }
                        else{
                          Navigator.pop(context);
                          int temreplyid = await imService.updateBugCommentReply(commentid, widget.bugid, Global.profile.user!.uid,
                              Global.profile.user!.token!, touid, _message, "", errorCallBack);

                          if(temreplyid > 0){
                            listComments.forEach((e){
                              if(e.commentid == commentid){
                                if(e.replys == null ){
                                  e.replys = [];
                                }
                                e.replys!.add(CommentReply(temreplyid, commentid, Global.profile.user,
                                    touser, _message, DateTime.now().toString(), false, widget.bugid, false, "", "", 0, ""));
                              }
                            });
                            setState(() {

                            });
                          }
                          else{
                            errorHandle(commentid == null ? 0 : commentid, touid, touser!);
                          }
                        }
                      }
                      else {
                        ShowMessage.showToast('输入留言内容!');
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

  Widget buildChildComment(List<CommentReply> replys){
    replys.sort((a, b) => (a.replycreatetime!).compareTo(b.replycreatetime!));
    List<Widget> tem = [];
    replys.map((v) {
      tem.add(
          GestureDetector(
            child: InkWell(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        NoCacheCircleHeadImage(imageUrl: v.replyuser!.profilepicture!, width: 30, uid: v.replyuser!.uid,),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
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
                        )

                      ],
                    ),
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 5, bottom: 5, right: 5, left: 40),
                      child:
                      RichText(
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        text: v.touser!=null? TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: '回复 ',
                                style: TextStyle(color: Colors.black, fontSize: 14)
                            ),
                            TextSpan(
                                text: '${v.touser!.username}',
                                style: TextStyle(color: Colors.blue, fontSize: 14)
                            ),
                            TextSpan(
                                text: ':${v.replycontent}',
                                style: TextStyle(color: Colors.black, fontSize: 14)
                            )
                          ],
                        ):TextSpan(
                            text: '${v.replycontent}',
                            style: TextStyle(color: Colors.black, fontSize: 14)),
                      )
                    //              Text(v.user.username, style: TextStyle(color: Colors.blue, fontSize: 14),),
//              v.touser!=null?Text(' 回复 @',style: TextStyle(fontSize: 14),):Text(''),
//              v.touser!=null?Text(v.touser.username,style: TextStyle(fontSize: 14)):Text(''),
//              Text(': ${v.replycontent}', style: TextStyle(color: Colors.black, fontSize: 14),),
                  )
                ],
              ),
              onTap: (){
                _hidemessage = '回复@${v.replyuser!.username}';
                sendMessage(v.commentid!, v.replyuser!.uid, touser: v.replyuser);
              },
            ),
            onLongPressStart: (detail) {
              if(v.replyuser!.uid == Global.profile.user!.uid){
                final RelativeRect position = RelativeRect.fromLTRB(
                    detail.globalPosition.dx,
                    detail.globalPosition.dy,
                    //取text高度做弹出y坐标（这样弹出就不会遮挡文本）
                    detail.globalPosition.dx,
                    detail.globalPosition.dy);
                showMenu(context: context,
                    position: position,
                    items: <PopupMenuEntry>[
                      PopupMenuItem(
                        child: InkWell(
                          child: Text('删除'),
                          onTap: () async {
                            bool ret = await imService.delMessageReply( Global.profile.user!.token!, Global.profile.user!.uid, v.replyid!, widget.bugid, errorCallBack);
                            if(ret){
                              listComments = await imService.getBugCommentList(widget.bugid, Global.profile.user!.uid, errorCallBack);
                              if(listComments != null && listComments.length > 0){
                                listComments = sortComment(listComments, _ordertype);
                              }
                              setState(() {

                              });
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: InkWell(
                          child: Text('取消'),
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),

                      )
                    ]
                );
              }
            },

          )
      );
    }).toList();
    return  Container(
      margin: EdgeInsets.only(left: 40, top: 10, right: 15),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tem,
      ),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        color: Colors.black12.withAlpha(20),
      ),
    );
  }

  void showPhoto(BuildContext context, Map<String, String> img, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: imglist,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          //scrollDirection: verticalGallery ? Axis.vertical : Axis.horizontal,
        ),
      ),
    );
  }

  List<Comment> sortComment(List<Comment> comments, String ordertype){
    if(ordertype == "0")
      comments.sort((a, b) => (b.createtime!).compareTo(a.createtime!));
    else{
      comments.sort((a, b) => (b.likenum!).compareTo(a.likenum!));
    }
    return comments;
  }

  errorCallBack(String statusCode, String msg) {
    error = msg;
    errorstatusCode = statusCode;
  }

  errorHandle(int commentid, int touid, User? touser){
    if(errorstatusCode != "200"){
      if(errorstatusCode == "-1008"){
        loadingBlockPuzzle(context, commentid: commentid, touid: touid, touser: touser);
      }
      else {
        ShowMessage.showToast(error);
      }
    }
  }

  //滑动拼图
  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true,int commentid=0, int touid=0, User? touser}) {
    showDialog<Null>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (_) {
          return BlockPuzzleCaptchaPage(
            onSuccess: (v) async {
              if(commentid == 0){
                int retcommentid = await imService.updateBugMessage(widget.bugid, Global.profile.user!.uid,
                    Global.profile.user!.token!, touid, _message, v, errorCallBack);
                listComments.insert(0, Comment(retcommentid, _bug!.bugid, Global.profile.user, _message, 0, CommonUtil.getTime(), 0));
                setState(() {

                });
              }
              else{
                int temreplyid = await imService.updateBugCommentReply(commentid, widget.bugid, Global.profile.user!.uid,
                    Global.profile.user!.token!, touid, _message, v, errorCallBack);
                if(temreplyid > 0){
                  listComments.forEach((e){
                    if(e.commentid == commentid){
                      if(e.replys == null || e.replys![0] == null){
                        e.replys = [];
                      }
                      e.replys!.add(CommentReply(temreplyid, commentid, Global.profile.user,
                          touser, _message, DateTime.now().toString(), false, widget.bugid, false, "", "", 0, ""));
                    }
                  });
                  setState(() {

                  });
                }
              }
            },
            onFail: (){

            },
          );
        }
    );
  }

}
