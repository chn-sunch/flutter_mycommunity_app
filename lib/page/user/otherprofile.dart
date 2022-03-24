import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../activity/myactivity.dart';
import '../../service/userservice.dart';
import '../../model/user.dart';
import '../../model/im/grouprelation.dart';
import '../../common/iconfont.dart';
import '../../util/common_util.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../widget/message_dialog.dart';
import '../../widget/photo/playvoice.dart';
import '../../widget/captcha/block_puzzle_captcha.dart';
import '../../global.dart';
import 'square/mymoment.dart';

class OtherProfile extends StatefulWidget {
  final Object? arguments;
  int uid = 0;
  OtherProfile({this.arguments}){
    uid = (arguments as Map)["uid"];
  }

  @override
  _OtherProfileState  createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> with SingleTickerProviderStateMixin,TickerProviderStateMixin {

  User? user;
  ///当前滑动的位置
  double offsetDistance = 0.0;
  final double offsetRange = 70;
  double personalInfoHeight = 20;
  ///动画
  ///动画控制器
  late AnimationController animationColorController;
  late AnimationController animationColorControllerIsDown;
  ///动画值是否重置
  bool isShowDiv = false;
  ///屏幕高度
  late TabController mController;
  double headContainer = 310 ;
  double pageHeight = 0;
  double tabContent = 0;
  final double statebar = MediaQueryData.fromWindow(window).padding.top;//状态栏高度
  Color barbackgroundColor =   Colors.transparent;
  Color textbarbackgroundColor = Colors.transparent;
  double appbarHeight = 50;
  bool isScroll = false;
  ScrollController _scrollController = new ScrollController();
  bool isBlack = false;
  bool isShowAll = false;
  String strpersonalInfo = "";
  bool isMyFriend = false;
  ImHelper imHelper = new ImHelper();
  UserService _userService = new UserService();

  void srollChange(){
    if (mounted) {
      setState(() {
        this.isScroll = false;
      });
    }
  }

  void _onDragUpdate(double offest) {
    //print(offest);
    if (offest.floor() >= 227) {
      if (mounted) {
        setState(() {
          isBlack = true;
          textbarbackgroundColor = Colors.black87;
        });
      }
    }

    if (offest.floor() < 227 && textbarbackgroundColor != Colors.transparent) {
      if (mounted) {
        setState(() {
          isBlack = false;
          textbarbackgroundColor = Colors.transparent;
        });
      }
    }
  }

  Future<void> getUserInfo() async {
    User? tem =  await _userService.getOtherUser(widget.uid);
    if(tem != null) {
      user = tem;
      user = await getFollowInfo(user!);

      setState(() {

      });
    }
  }

  Future<User> getFollowInfo(User user) async {
    if(user != null && Global.profile.user != null){
      bool ret = await isFollow(user.uid, Global.profile.user!.uid);
      if(ret){
        user.isFollow = true;
      }
    }
    return user;
  }

  Future<bool> isFollow(int followed, int uid) async {
    bool isfollowed = false;
    List<int> list = await imHelper.selFollowState(
        followed, uid);
    if(list != null && list.length > 0)
      isfollowed = true;

    return isfollowed;
  }

  @override
  void initState() {
    if(Platform.isAndroid) {
      WidgetsBinding.instance!.renderView.automaticSystemUiAdjustment = false; //去掉会导致底部状态栏重绘变成黑色，系统UI重绘，，页面退出后要改成true
    }
    // TODO: implement initState
    super.initState();
    getUserInfo();
    mController = TabController(vsync: this,
      length: 2,
    );

    mController.addListener(() {
      setState(() {

      });
    });
    _scrollController.addListener((){
      if(_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent){
      }
      _onDragUpdate(_scrollController.position.pixels);
    });
    animationColorController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    animationColorControllerIsDown = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    if(Platform.isAndroid) {
      WidgetsBinding.instance!.renderView.automaticSystemUiAdjustment = true; //去掉会导致底部状态栏重绘变成黑色，系统UI重绘，，页面退出后要改成true
    }
    // TODO: implement dispose
    mController.dispose();
    animationColorController.dispose();
    animationColorControllerIsDown.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if(tabContent == 0) {
      pageHeight = MediaQuery
          .of(context)
          .size
          .height;
      tabContent = pageHeight - headContainer;
    }
    if(user == null){
      return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.shrink(),
      );
    }

    String sexinfo = user!.sex=='1'?'男生':(user!.sex=='0'?'女生':'');
    strpersonalInfo =  (user!.city!=null && user!.city!.isNotEmpty?CommonUtil.getProvinceCityName(user!.province, user!.city):"太阳系").toString() + " · "
        + CommonUtil.getAgeGroup(user!.birthday!)  + sexinfo + " · " + CommonUtil.getConstellation(user!.birthday!);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: ExtendedNestedScrollView(
        controller: _scrollController,
        pinnedHeaderSliverHeightBuilder: () {
          return 100;
        },

        headerSliverBuilder: (BuildContext context,
            bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              actions: [
                InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Container(
                        color: !isBlack?Colors.black26:Colors.transparent,
                        alignment: Alignment.center,
                        width: 30,
                        height: 30,
                        child: Icon(IconFont.icon_navbar_xiaoxi, size: 19,color: isBlack?textbarbackgroundColor:Colors.white),),
                    ),
                  ),
                  onTap: (){
                    if(Global.profile.user != null){
                      joinMessage("");
                    }
                    else{
                      logIn();
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: Container(
                          color: !isBlack?Colors.black26:Colors.transparent,
                          alignment: Alignment.center,
                          width: 30,
                          height: 30,
                          child: Icon(Icons.more_vert, size: 19,color: isBlack?textbarbackgroundColor:Colors.white),),
                      ),
                    ),
                    onTap: (){
                      showUserOperation();
                    },
                  ),
                ),
              ],
              leading: InkWell(
                child: Container(
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Container(
                      color: !isBlack?Colors.black26:Colors.transparent,
                      alignment: Alignment.center,
                      width: 30,
                      height: 30,
                      child: Icon(Icons.arrow_back_ios_new, size: 19,color: isBlack?textbarbackgroundColor:Colors.white),),
                  ),
                ),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              primary: true,
              pinned: true,
              centerTitle: true,
              title: Text(user!.username, style: TextStyle(color: textbarbackgroundColor, fontSize: 16),),
              expandedHeight: headContainer + personalInfoHeight + 20,
              flexibleSpace: FlexibleSpaceBar(
                background: Container( //头部整个背景颜色
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 130,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(user!.profilepicture!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 130),
                        color: Colors.white,
                      ),
                      buildHeadInfo(),
                      buildFsInfo(),
                      buildPersonalInfo(),
                    ],
                  ),
                ),
              ),
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Container(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: <Widget>[
                          Divider(height: 0.1, color: Colors.black12),
                          Container(
                            color: Colors.white,
                            height: 35,
                            child: TabBar(
                              indicatorSize: TabBarIndicatorSize.label,
                              indicatorColor: Colors.white,
                              controller: mController,
                              labelColor: Global.profile.backColor,
                              unselectedLabelColor: Colors.black54,
                              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
                              labelStyle:  TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              tabs: <Widget>[
                                Text('Ta的活动',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                                Text('Ta的动态',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          Divider(height: 0.1, color: Colors.black12),
                        ],
                      ),
                    )
                ),
              ),
            )
          ];
        },
        body: TabBarView(
            controller: mController,
            children: [
              GlowNotificationWidget(MyActivity(user: user!,isScroll: isScroll, srollChange: srollChange, ), showGlowLeading: false,),
              GlowNotificationWidget(MyMoment(user: user!,isScroll: isScroll, srollChange: srollChange, ), showGlowLeading: false,),
            ]),
      ),
    );
  }
  //头像，昵称，编辑
  Container buildHeadInfo(){
    //关注和消息
    Widget followandmsg = Row(
      children: [
        Expanded(
          child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius:  BorderRadius.all(Radius.circular(5))
            ),
            color: Global.profile.backColor,
            child: Text("+ 关注", style: TextStyle(fontWeight: FontWeight.w900,color: Global.profile.fontColor,fontSize: 14),),
            onPressed: (){
              if(Global.profile.user != null){
                followUser();
              }
              else{
                logIn();
              }
            },
          ),
        ),
      ],
    );
    //取消关注和发消息
    Widget cancelfollowandmsg = Row(
      children: [
        Expanded(
          child: OutlineButton(
            color: Colors.black45,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return MessageDialog(
                      title: new Text(
                        "提示",
                        style: new TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87
                        ),
                      ),
                      message: new Text(
                        "确定要取消关注?",
                        style: TextStyle(fontSize: 14.0, color: Colors.black54),
                      ),
                      negativeText: "取消",
                      positiveText: "确定",
                      containerHeight: 80,
                      onPositivePressEvent: (){
                        cancelFollow();
                        Navigator.pop(context);
                      },
                      onCloseEvent: () {
                        Navigator.pop(context,);
                      },);
                  }
              );
            },
            child: Text('已关注',style: TextStyle(fontSize: 14.0,color: Colors.black),),
            ///圆角
            shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(9))
            ),
          ),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.only(top: 115,left: 17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            child: Container(
              height: 96,
              width: 96,
              child: SizedBox.shrink(),
              decoration: BoxDecoration(
                  border: Border.all(color: Global.profile.fontColor!, width: 2),
                  borderRadius: BorderRadius.circular(50),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(user!.profilepicture!),
                  )),
            ),
            onTap: (){
              Navigator.pushNamed(context, '/PhotoViewImageHead', arguments: {"image":  user!.profilepicture, "iscache" : false});
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 10),
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.only(top: 20, left: 0, right: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        InkWell(
                          onTap: (){
                            if(user!.followers! > 0) {
                              if(Global.profile.user != null){
                                Navigator.pushNamed(context, '/MyFansUser', arguments: {"uid":user!.uid});
                              }
                              else{
                                logIn();
                              }
                            }
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Text(user!.followers == null ? '0' : CommonUtil.getNum(user!.followers!), style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),),
                                Text('粉丝',style: TextStyle(color: Colors.black45, fontSize: 13),)
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            if(user!.following! > 0) {
                              if(Global.profile.user != null){
                                Navigator.pushNamed(context, '/OtherFollowUser', arguments: {"uid": user!.uid});
                              }
                              else{
                                logIn();
                              }
                            }
                          },
                          child:Container(
                            child: Column(
                              children: <Widget>[
                                Text(user!.following == null ? '0' : CommonUtil.getNum(user!.following!), style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),),
                                Text('关注',style: TextStyle(color: Colors.black45, fontSize: 13),)
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return MessageDialog(
                                    title: Text(
                                      user!.username,
                                      style: new TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black
                                      ),
                                    ),
                                    message: Column(
                                      children: [
                                        Text(
                                          "活动、留言、评论累计获赞",
                                          style: TextStyle(fontSize: 14.0, color: Colors.black45),
                                        ),
                                        SizedBox(height: 20,),
                                        Text(
                                          user!.likenum.toString(),
                                          style: TextStyle(fontSize: 16.0, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    negativeText: "知道了",
                                    containerHeight: 80,
                                    onPositivePressEvent: (){
                                      Navigator.pop(context);
                                    },
                                    onCloseEvent: () {
                                      Navigator.pop(context,);
                                    },);
                                }
                            );
                          },
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Text(user!.likenum == null ? '0' : CommonUtil.getNum(user!.likenum!), style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),),
                                Text('点赞',style: TextStyle(color: Colors.black45, fontSize: 13),)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        width: double.infinity ,
                        margin: EdgeInsets.only(right: 10,left: 10, bottom: 10, top: 0),
                        child: AnimatedContainer(
                            duration: Duration(milliseconds: 3300),
                            child: user!.isFollow? cancelfollowandmsg : followandmsg
                        ),
                    ),
                  ],
                )
            ),
          )
        ],
      ),
    );
  }
  //个人简介 社团信息
  Container buildPersonalInfo(){
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 260, left: 17, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(user!.signature == "" ? 'Ta很神秘':user!.signature, overflow: TextOverflow.ellipsis, style: TextStyle(
                              fontSize: 13, color: Colors.black,
                            ),),),
                          ],
                        ),
                        SizedBox(height: 6,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(strpersonalInfo, style: TextStyle(
                                  fontSize: 13.0, color: Colors.black, ), overflow: TextOverflow.ellipsis,),
                            ),
                          ],
                        ),
                        SizedBox(height: 6,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text('${user!.interest!=null && user!.interest!="" ? "喜欢" + CommonUtil.getInterest(user!.interest!):"喜欢什么就是不告诉你"}',
                                style: TextStyle(color: Colors.black, fontSize: 13), overflow: TextOverflow.ellipsis,)
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                      ],
                    )
                ),
              )
            ],
          ), // buildCommunityInfo(),
        ],
      )
    );
  }
  //用户名
  Container buildFsInfo(){
    return Container(
      padding: EdgeInsets.only(top: 225,left: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 10),
            ),
          Text(
              "" + user!.username,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
              ),
            ),
          user!.voice != null && user!.voice != "" ? Padding(
            padding: EdgeInsets.only(left: 5,top: 0),
          ):SizedBox.shrink(),
          user!.voice != null && user!.voice != "" ? PlayVoice(user!.voice!):SizedBox.shrink(),
        ],
      )
    );
  }
  //社团信息邀请入团
  Widget buildCommunityInfo(){
    //加好友按钮
    Widget btnJoin =  Container(
      height: 30,
      child: OutlineButton(
        onPressed: (){
          if(Global.profile.user != null){
            Navigator.pushNamed(context, '/JoinFriend', arguments: {"uid": Global.profile.user!.uid, "touid": user!.uid, "jointype": 1});
          }
          else{
            logIn();
          }
        },
        borderSide: BorderSide(
            color: Colors.redAccent,
            width: 1,
            style: BorderStyle.solid
        ),
        color: Colors.redAccent,
        child: Text("加好友", style: TextStyle(color: Colors.redAccent, fontSize: 14),)
      ),
    );
    //分享按钮
    Widget btnMsg =  Container(
      height: 30,
      child: OutlineButton(
          onPressed: (){
//            _otherUserBloc.add(new JoinGroupMessage(Global.profile.user, Global.profile.user.mycommunity.cid));
          },
          borderSide: BorderSide(
              color: Colors.redAccent,
              width: 1,
              style: BorderStyle.solid
          ),
          color: Colors.redAccent,
          child: Text("分享", style: TextStyle(color: Colors.redAccent, fontSize: 14),)
      ),
    );

    return Container(
      margin: EdgeInsets.only(right: 10,top: 10,bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isMyFriend?Text(' 你们已经是好友了，快分享活动吧', style: TextStyle(color: Colors.black45, fontSize: 13),)
              : Text(' 成为朋友一起约起来吧', style: TextStyle(color: Colors.black45, fontSize: 13),),
          isMyFriend?btnMsg:((Global.profile.user != null) ? btnJoin: SizedBox.shrink())
        ],
      )
    );
  }
  //滑动拼图
  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v){
            joinMessage(v);
          },
          onFail: (){

          },
        );
      },
    );
  }
  //登录后返回
  logIn(){
    Navigator.pushNamed(context, '/Login').then((value){
      if(Global.profile.user != null)
        getUserInfo();
    });
  }

  Future<void> showUserOperation() async {
    if (Global.profile.user == null) {
      Navigator.pushNamed(context, '/Login');
      return;
    }

    String blackName = "";
    List<int> blackList = await imHelper.getBlacklistUid(Global.profile.user!.uid);
    if(blackList.contains(user!.uid)){
      blackName = "解除黑名单";//下面是用名称做判断，修改的话下面也要改
    }
    else{
      blackName = "加入黑名单";
    }

    showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) =>
            Container(
              height: 179,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ListTile(
                    title: Align(
                      alignment: Alignment.center,
                      child:Text(blackName, style: TextStyle(color:  Colors.black87, fontSize: 15),),
                    ),
                    onTap: () async {
                      if(blackName == "解除黑名单"){
                        bool ret = await _userService.updateBlacklist(Global.profile.user!.token!, Global.profile.user!.uid, user!.uid, (code,msg){
                          ShowMessage.showToast(msg);
                        });
                        if(ret){
                          imHelper.delBlacklistUid(Global.profile.user!.uid, user!.uid);
                        }
                        Navigator.of(context).pop();
                      }
                      else {
                        Navigator.of(context).pop();
                        await _askedConfirm();
                      }
                    },
                  ),
                  ListTile(
                    title: Align(
                      alignment: Alignment.center,
                      child:Text('举报', style: TextStyle(color:  Colors.black87, fontSize: 15),),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/ReportActivity', arguments: {"actid": user!.uid.toString(), "sourcetype": 2, "touid": widget.uid});//0活动 1商品 2用户
                    },
                  ),
                  Container(
                    height: 6,
                    color: Colors.grey.shade100,
                  ),
                  Expanded(
                    child: buildBtn(),
                  )
                ],
              ),
            )
    ).then((value) {

    });
  }

  Widget buildBtn() {
    return Container(
        color: Colors.white,
        width: double.infinity,
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(
              child: FlatButton(
                  child: Text(
                    '取 消', style: TextStyle(color:  Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          ],
        )
    );
  }

  Future<void> _askedConfirm() async {
    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('加入黑名单，他(她)将不能再给你发消息，并且不能参加你组织的活动', style: new TextStyle(fontSize: 17.0)),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () async {
                  bool ret = await _userService.updateBlacklist(Global.profile.user!.token!, Global.profile.user!.uid, user!.uid, (code,msg){
                    ShowMessage.showToast(msg);
                  });
                  if(ret){
                    imHelper.saveBlacklistUid(Global.profile.user!.uid, user!.uid);
                  }
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  Future<void> joinMessage(String captchaVerification) async {
    String timeline_id = "";
    if(Global.profile.user!.uid > user!.uid){
      timeline_id = user!.uid.toString() + Global.profile.user!.uid.toString();
    }
    else{
      timeline_id = Global.profile.user!.uid.toString() + user!.uid.toString();
    }
    GroupRelation? groupRelation = await imHelper.getGroupRelationByGroupid(Global.profile.user!.uid, timeline_id);
    if(groupRelation == null){
      groupRelation  = await _userService.joinSingle(timeline_id, Global.profile.user!.uid, user!.uid, Global.profile.user!.token!,
          captchaVerification, errorCallBack);
    }
    if(groupRelation != null){
      List<GroupRelation> groupRelations = [];
      groupRelations.add(groupRelation);
      int ret = await imHelper.saveGroupRelation(groupRelations);
      if(ret > 0) {
        Navigator.pushNamed(this.context, '/MyMessage', arguments: {"GroupRelation": groupRelation});
      }
    }
  }

  Future<void> followUser() async {
    bool ret = await _userService.Follow(Global.profile.user!.token!, Global.profile.user!.uid, user!.uid, errorCallBack);
    if(ret) {
      await imHelper.delFollowState(user!.uid, Global.profile.user!.uid);
      await imHelper.saveFollowState(user!.uid, Global.profile.user!.uid);
      Global.profile.user!.following = Global.profile.user!.following! + 1;
      Global.saveProfile();
      user!.isFollow = true;
      user!.followers = user!.followers! + 1;
      setState(() {

      });
    }
    return;
  }

  cancelFollow() async {
    bool ret = await _userService.cancelFollow(Global.profile.user!.token!, Global.profile.user!.uid, user!.uid,  errorCallBack);
    if(ret) {
      await imHelper.delFollowState(user!.uid, Global.profile.user!.uid);
      Global.profile.user!.following = Global.profile.user!.following! - 1;
      Global.saveProfile();
      user!.isFollow = false;
      user!.followers = user!.followers! - 1;
      setState(() {

      });
    }
    return;
  }

  errorCallBack(String statusCode, String msg) {
    if(statusCode == "-1008"){
      //需要进行人机验证
      loadingBlockPuzzle(context);
    }
    else {
      ShowMessage.showToast(msg);
    }
  }
}
