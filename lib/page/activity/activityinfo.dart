import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/user.dart';
import '../../model/comment.dart';
import '../../model/commentreply.dart';
import '../../model/activity.dart';
import '../../model/im/grouprelation.dart';
import '../../common/iconfont.dart';
import '../../util/showmessage_util.dart';
import '../../util/common_util.dart';
import '../../util/imhelper_util.dart';
import '../../service/activity.dart';
import '../../widget/shareview.dart';
import '../../widget/photo/photo_viewwrapper.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/captcha/block_puzzle_captcha.dart';
import '../../global.dart';

class ActivityInfo extends StatefulWidget {
  String actid = "";
  int commentid = 0;
  Object? arguments;

  ActivityInfo({this.arguments}){
    if(arguments != null){
      Map map = arguments as Map;
      actid = map["actid"];
    }
  }

  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<ActivityInfo> {
  bool _isShowComment = false;//是否只显示评论
  bool _isShowAll = false;//是否显示所有评论，在只显示评论状态才有效
  List<String> _listimgs = [];
  double _pageWidth = 0;
  int _commentid = 0;
  Activity? _activity;
  List<Comment> _listComments = [];
  List<Activity> _moreActivity = [];

  ActivityService _activityService = new ActivityService();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int blockcommentid = 0;
  int blocktouid = 0;
  String _message = "";
  String _hidemessage = "提交留言，问问活动细节";
  String _sortname = "按时间";
  String _ordertype = "0";//排序类型， 0：按时间 1：按热度
  bool _islike = false, _iscollection = false;
  bool _isLikeEnter = true, _isCollectEnter = true, _isCommentLike = true;
  String _bottombutton = "我想参加";//底部按钮，加入或者管理
  double _moreHeight = 0.0;
  final Key moreKey = UniqueKey();
  Widget actContent = SizedBox.shrink();
  Widget actMember = SizedBox.shrink();//活动成员
  Widget actComment = SizedBox.shrink();//活动评价
  List<Map<String, String>> imglist = [];
  bool isgotogoodprice = false;
  ImHelper imhelper = new ImHelper();

  Widget promptWidget = Center(
    child: CircularProgressIndicator(
      valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
    ),
  );

  Widget actMore = Container(
      margin: EdgeInsets.only(top: 10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start,
          children: <Widget>[
            Container(
              child:  Text('相关推荐', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 5,),
            Container(height: 50, width: double.infinity, child: Center(child: Text('暂无相关活动', style: TextStyle(color: Colors.black54, fontSize: 14, ),),),),
          ],
        ),
      )
  );//更多的活动

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
      super.initState();
      getActivityInfo();
  }

  @override
  Widget build(BuildContext context) {
    _pageWidth = MediaQuery.of(context).size.width - 28; //28是左右间隔

    if(_activity != null){
      actContent = Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10,bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeadInfo(),
                buildRequirements(),
                _activity!.addresstitle != null && _activity!.addresstitle!.isNotEmpty ? buildLocation():SizedBox.shrink(),
                buildContent(),
                _activity!.actimagespath != null && _activity!.actimagespath!.isNotEmpty ? buildActivityImg() : SizedBox.shrink(),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.centerRight,
                  child: Text('${_activity!.joinnum! + 1}人想参加 · 浏览${_activity!.viewnum}', style: TextStyle(fontSize: 12, color: Colors.black45),),
                )
              ],
            ),
          )
      );
      actMember = Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 10),
        child: buildMembers(),
      );
      actComment = Container(
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
                    Text('全部留言(${_listComments.length.toString()})', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                    _listComments.length == 0 ? SizedBox.shrink() : InkWell(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.menu,
                            color: Colors.black45,
                            size: 18,
                          ),
                          Text(_sortname,
                            style: TextStyle(color: Colors.black45, fontSize: 13),)
                        ],
                      ),
                      onTap: () {
                        if (_listComments != null && _listComments.length > 0) {
                          if (_sortname == "按时间") {
                            _sortname = '按热度'; //当前排序方式
                            _ordertype = "1";
                            sortComment();
                          }
                          else {
                            _sortname = '按时间';
                            _ordertype = "0";
                            sortComment();
                          }
                        }
                      },
                    )
                  ],
                ),
                SizedBox(height: 5,),
                _listComments.length > 0 ? buildComment() : Container(height: 50, width: double.infinity,
                  child: Center(child: Text('还没有任何留言', style:  TextStyle(color: Colors.black54, fontSize: 14, )),),),
                (_isShowComment && !_isShowAll) ? buildShowAllComment() : SizedBox.shrink(),
              ],
            ),
          )
      );
    }

    if(_moreActivity != null && _moreActivity.length > 0) {
      actMore = Container(
          margin: EdgeInsets.only(top: 10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .start,
              children: <Widget>[
                Container(
                  child: Text('相关推荐', style: TextStyle(color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 5,),
                buildMoreActivity(_moreActivity),
              ],
            ),
          )
      );
    }


    return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            toolbarHeight: 39,
            leading: IconButton(icon: Icon(Icons.arrow_back_ios, size: 20,),
              color: Colors.black,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[
              _activity != null ? Padding(
                padding: EdgeInsets.only(right: 10),
                child: Global.profile.user != null ? ShareView(icon: Icon(Icons.more_horiz, color: Colors.black),
                  image: _activity!.coverimg, contentid: _activity!.actid,
                  content: _activity!.content, sharedtype: "0", actid: _activity!.actid, createuid: _activity!.user!.uid,) :
                IconButton(icon: Icon(Icons.more_horiz, color: Colors.black), onPressed: (){
                  _islogin();
                },),
              ): SizedBox.shrink() //  String sharedtype;//分享类型 0 活动 1商品 2拼玩
            ],
          ),
          body: _activity != null ?  SmartRefresher(
              enablePullDown: false,
              enablePullUp: true,
              footer: CustomFooter(
                builder: (BuildContext context,LoadStatus? mode){
                  Widget body ;
                  if(mode==LoadStatus.idle){
                    body =  Text("加载更多", style: TextStyle(color: Colors.black45, fontSize: 13));
                  }
                  else if(mode==LoadStatus.loading){
                    body =  Center(
                      child: CircularProgressIndicator(
                        valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                      ),
                    );
                  }
                  else if(mode == LoadStatus.failed){
                    body = Text("加载失败!点击重试!", style: TextStyle(color: Colors.black45, fontSize: 13));
                  }
                  else if(mode == LoadStatus.canLoading){
                    body = Text("放开我,加载更多!", style: TextStyle(color: Colors.black45, fontSize: 13));
                  }
                  else{
                    body = Text("—————— 我也是有底线的 ——————", style: TextStyle(color: Colors.black45, fontSize: 13));
                  }
                  print(mode);
                  return Container(
                    height: 55.0,
                    child: Center(child:body),
                  );
                },
              ),
              controller: _refreshController,
              onLoading: _onLoading,
              child: ListView(
                // item 内容内边距
                children: <Widget>[
                  actContent,
                  actMember,
                  actComment,
                  actMore
                ],
              )
          ): promptWidget,
          bottomNavigationBar: _activity != null ? buildBottomButton() : SizedBox.shrink(),
        );
  }

  Future<void> getActivityInfo() async {
    _activity = await _activityService.getActivityInfo(widget.actid,  errorCallBack);
    if(_activity == null){
      promptWidget = Center(
        child: Text('活动已经被删除了'),
      );
      setState(() {

      });
      return;
    }

    if(Global.profile.user == null) {
      _listComments = await _activityService.getCommentList(widget.actid, 0, errorCallBack);
    }
    else{
      imhelper.saveBrowseHistory(_activity!.actid, _activity!.content, _activity!.coverimg ?? "", _activity!.coverimgwh, _activity!.user!.profilepicture ?? "",
          _activity!.user!.username, _activity!.peoplenum ?? 0, _activity!.goodPiceModel!.mincost, _activity!.goodPiceModel!.maxcost);
      Map likecollectionstate = await _activityService.getLikeCollectionState(widget.actid, Global.profile.user!.uid);
      _islike = likecollectionstate["islike"];
      _iscollection = likecollectionstate["iscollection"];
      _listComments = await _activityService.getCommentList(widget.actid, Global.profile.user!.uid, errorCallBack);
    }
    if(mounted)
    setState(() {

    });
    getActivityMore(_activity!);//更多相关活动
  }

  Future<void> getActivityMore(Activity activity) async {
    _moreActivity = await _activityService.searchMoreLikeActivity(
        activity.actcity ?? "",  0,  activity.content, activity.actid, errorCallBack); //
    if(_moreActivity == null || _moreActivity.length <= 0){
      return;
    }

    setState(() {

    });
  }

  void _onLoading() async{
    if(_moreActivity == null || _moreActivity.length < 25){
      _refreshController.loadNoData();
      return;
    }
    List<Activity> tem = await _activityService.searchMoreLikeActivity(
        _activity!.actcity ?? "",  _moreActivity.length,  _activity!.content, _activity!.actid, errorCallBack); //

    if(tem.length > 0)
      _moreActivity = _moreActivity + tem;

    if(_moreActivity.length >= 25)
      _refreshController.loadComplete();
    else{
      _refreshController.loadNoData();
    }

    if(mounted)
      setState(() {

      });
  }

  bool _islogin(){
    if(Global.profile.user == null) {
      Navigator.pushNamed(context, '/Login').then((value) async {
        if (Global.profile.user != null) {
          getActivityInfo();
        }
      });

      return false;
    }
    else{
      return true;
    }
  }

  void sortComment(){
    if(_ordertype == "0")
      _listComments.sort((a, b) => (b.createtime!).compareTo(a.createtime!));
    else{
      _listComments.sort((a, b) => (b.likenum!).compareTo(a.likenum!));
    }
    setState(() {

    });
  }

  void errorCallBack(String statusCode, String msg, {touid, commentid, touser}) {
    if(statusCode == "-1008"){
      //需要进行人机验证
      loadingBlockPuzzle(context);
    }
    ShowMessage.showToast(msg);
  }

  //是否显示所有评论
  Widget buildShowAllComment(){
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 20, bottom: 10),
        child: Column(
          children: <Widget>[
            Text('查看所有评论', style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),),
            Icon(Icons.keyboard_arrow_down)
          ],
        ),
      ),
      onTap: (){
        _isShowAll = true;
        setState(() {

        });
      },
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
            uid: _activity!.user!.uid,
            imageUrl: _activity!.user!.profilepicture ?? "",
          ),
          Padding(padding: EdgeInsets.only(left: 10),),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_activity!.user!.username, style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: Text('${_activity!.user!.signature == "" ? "Ta很神秘" : _activity!.user!.signature} ',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                        maxLines: 1, overflow: TextOverflow.ellipsis,                   )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('${CommonUtil.datetimeFormat(DateTime.parse(_activity!.user!.updatetime!))}来过 ${CommonUtil.getAgeGroup(_activity!.user!.birthday!)} '
                        '${CommonUtil.getConstellation(_activity!.user!.birthday!)} ${_activity!.user!.sex == "0" ?
                    "女":(_activity!.user!.sex == '2'?"":"男")}',style: TextStyle(color: Colors.black54, fontSize: 13))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  //获取活动要求
  Container buildRequirements() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 15),),
          _activity!.goodpriceid != null && _activity!.goodpriceid!.isNotEmpty ? Padding(padding: EdgeInsets.only(left: 1), child: buildGoodPrice(),) :SizedBox.shrink(),
        ],
      ),
    );
  }
  //活动位置
  Widget buildLocation(){
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, '/MapLocationShowNav', arguments: {"lat" : _activity!.lat.toString(), "lng" : _activity!.lng.toString(),
          "title": _activity!.addresstitle, "address": _activity!.address});
      },
      child: Container(
        margin: EdgeInsets.only(top: 0, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.location_on, size: 25, color: Colors.blue,),
            SizedBox(width: 5,),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _activity!.addresstitle != null && _activity!.addresstitle!.isNotEmpty ? Text("${_activity!.addresstitle}",
                      style: TextStyle(color: Colors.black87, fontSize: 13), overflow: TextOverflow.ellipsis,) : Text("", style: TextStyle(color: Colors.black87, fontSize: 13)),
                    Row(
                      children: [
                        _activity!.address != null && _activity!.address!.isNotEmpty ? Expanded(child: Text("(${_activity!.address})",
                          style:  TextStyle(color: Colors.black54, fontSize: 12, ), overflow: TextOverflow.ellipsis,)): SizedBox.shrink(),
                      ],
                    )
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }


  //获取活动内容
  Widget buildContent() {
    return SafeArea(
      child: Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_activity!.content, style: TextStyle(color: Colors.black87, fontSize: 14, ),),
            ],
          )
      ),
    );
  }
  //获取活动图片
  Column buildActivityImg() {
    _listimgs = _activity!.actimagespath!.split(',');
    if(_listimgs.length > 0){
      for(int i=0;i<_listimgs.length;i++){
        imglist.add({"tag": UniqueKey().toString(),"img": _listimgs[i].toString()});
      }
    }
    double initheigth = 0;

    if(_activity!.coverimgwh != null){
      List<String> wh = _activity!.coverimgwh.split(',');
      if(wh.length > 0){
        initheigth = getImageWH(_activity!);
      }
    }

    return Column(
      children: _listimgs.asMap().keys.map((i) {
        initheigth = i > 0 ? 0 : initheigth;
        return Container(
          height: i == 0 ?initheigth: null,
          margin: EdgeInsets.only(top: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: InkWell(
              onTap: (){
                showPhoto(context, imglist[i], i);
              },
              child: CachedNetworkImage(
                placeholder: (context,url)=>   Container(
                  height: i==0?initheigth:null,
                  width: i==0?_pageWidth.floor().toDouble():null,
//                alignment: Alignment.center,
//                child: CircularProgressIndicator(
//                  valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
//                ),
                ) ,
                imageUrl: '${_listimgs[i]}?x-oss-process=image/resize,m_fixed,w_1080/quality,q_80',
                fit: BoxFit.cover,
              ),
            )
          ),
        );
      }).toList(),
    );
  }
  //底部按钮
  Widget buildBottomButton() {
    Color btncolor = Colors.blue;
    bool isjoin = false;//是否已经参加

    if(Global.profile.user != null){
      _activity!.members!.forEach((element) {
        if(Global.isInDebugMode){
          print("activity member" + element.uid.toString());
        }
        if(element.uid == Global.profile.user!.uid){
          isjoin=true;
        }
      });
      //活动状态
      if(_activity!.status == 0){
        if(_activity!.user!.uid == Global.profile.user!.uid) {
          _bottombutton = "活动管理";
          btncolor = Colors.blue;
        }
        else{
          if(isjoin){
            //已经加入
            _bottombutton = "去活动群";
          }
          else{
            _bottombutton = "我想参加";
          }
          btncolor = Global.profile.backColor!;
        }
      }
      else{
        //活动已经结束
        _bottombutton="已经结束";
        btncolor = Colors.black26;
      }
    }

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
                    icon: Icon(_islike ? IconFont.icon_zan1 : IconFont.icon_aixin, color: _islike ?
                    Global.profile.backColor : Colors.grey,),
                    onPressed: () {
                      if(!_islogin())
                        return;

                      if(_isLikeEnter) {
                        _isLikeEnter = false;
                        if (!_islike){
                          updateLike();//点赞
                        }
                        else{
                          updateDelLike();
                        }
                      }
                    },
                  ),
                  Text(_activity == null ? "0" : _activity!.likenum.toString(),
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
                        _hidemessage = "活动留言";
                        messageWidget(0, _activity!.user!.uid);
                      }
                      else{
                        _islogin();
                      }
                    },
                  ),
                  Text(
                    "留言", style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                        _iscollection ? IconFont.icon_collection_b : IconFont
                            .icon_shoucang, color:
                    _iscollection ? Colors.blueAccent : Colors.grey),
                    onPressed: () {
                      if(_isCollectEnter) {
                        _isCollectEnter = false;
                        if (!_iscollection)
                          updateCollection();
                        else
                          updateDelCollection();
                      }
                    },
                  ),
                  Text(_activity == null ? "0" : _activity!.collectionnum
                      .toString(),
                    style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),),
                ],
              )
            ],
          ),
          FlatButton(
            shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Text(_bottombutton, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),),
            color: btncolor,
            onPressed: () {
              if(!_islogin()){
                return;
              }

              if( Global.profile.user != null && _activity!.user!.uid == Global.profile.user!.uid) {
                if (_activity!.status == 0)
                  _openSimpleDialog();
                else{
                  joinActivity();
                }
              }
              else{
                if(_activity!.status == 0 && !isjoin) {
                  joinActivity();
                }
                else{
                  joinGroupMessage();
                }
              }
            },
          )
        ],
      ),
    );
  }

  Future<void> updateLike() async {
    bool ret = await _activityService.updateLike(_activity!.actid, Global.profile.user!.uid,  Global.profile.user!.token!, errorCallBack);
    if(ret) {
      _activity!.likenum = _activity!.likenum + 1;
      setState(() {
        _islike = true;
      });
    }
    _isLikeEnter = true;

  }

  Future<void> updateDelLike() async {
    bool ret = await _activityService.delLike(_activity!.actid, Global.profile.user!.uid,  Global.profile.user!.token!, errorCallBack);
    if(ret) {
      _activity!.likenum = _activity!.likenum - 1;
      setState(() {
        _islike = false;
      });
    }
    _isLikeEnter = true;
  }

  Future<void> updateCollection() async {
    bool ret = await _activityService.updateCollection(_activity!, Global.profile.user!.uid,  Global.profile.user!.token!, errorCallBack);
    if(ret) {
      _activity!.collectionnum =  _activity!.collectionnum + 1;
      setState(() {
        _iscollection = true;
      });
    }
    _isCollectEnter = true;
  }

  Future<void> updateDelCollection() async {
    bool ret = await _activityService.delCollection(_activity!.actid, Global.profile.user!.uid,  Global.profile.user!.token!, errorCallBack);
    if(ret) {
      _activity!.collectionnum =  _activity!.collectionnum - 1;
      setState(() {
        _iscollection = false;
      });
    }
    _isCollectEnter = true;
  }

  Future<void> joinActivity() async {
    //如果已经加入，就直接进入群聊
    GroupRelation? groupRelation = await imhelper.getGroupRelationByGroupid(Global.profile.user!.uid, _activity!.actid);
    if(groupRelation != null && groupRelation.isnotservice == 0){
      Navigator.pushNamed(context, '/MyMessage', arguments: {"GroupRelation": groupRelation}).
        then((value) => getActivityInfo());
      return;
    }

    if(Global.isInDebugMode){
      print("是否已经加入群聊: ---------------------------------------");
      print(groupRelation);
    }

    if(_activity!.status != 0){
      ShowMessage.showToast('活动已结束');
      return;
    }

    groupRelation = await _activityService.joinActivity(
        _activity!.actid, Global.profile.user!.uid, Global.profile.user!.token!,
        Global.profile.user!.username,
        Global.profile.user!.sex ?? "0", errorCallBack);

    if(groupRelation != null){
      List<GroupRelation> groupRelations = [];
      groupRelations.add(groupRelation);
      int ret = await imhelper.saveGroupRelation(groupRelations);
      await imhelper.updateGroupRelationIsNotService(_activity!.actid);
      if(ret > 0){
        //服务器传回的grouprelation再重新获取下，有些属性可能为空
        groupRelation = await imhelper.getGroupRelationByGroupid(Global.profile.user!.uid, _activity!.actid);
      }

      if(Global.isInDebugMode) {
        print("保存本地是否成功：-----------------------------------");
        print(groupRelations[0].group_name1);
        print(ret);
      }
      if(ret > 0){
        Navigator.pushNamed(context, '/MyMessage', arguments: {"GroupRelation": groupRelation, "millisecond": DateTime.now().millisecond}).
          then((value) => getActivityInfo());
      }
      else{
        ShowMessage.showToast('加入活动群失败，请退出重试');
      }
    }
  }

  Future<void> joinGroupMessage() async {
    GroupRelation? groupRelation = await imhelper.getGroupRelationByGroupid(Global.profile.user!.uid, _activity!.actid);
    if(groupRelation != null){
      Navigator.pushNamed(context, '/MyMessage', arguments: {"GroupRelation": groupRelation}).
        then((value) => getActivityInfo());
      return;
    }
    else {
      groupRelation = await _activityService.getGroupConversation(_activity!.actid, Global.profile.user!.uid, Global.profile.user!.token!, errorCallBack);
      if(groupRelation != null) {
        List<GroupRelation> grouprelations = [];
        grouprelations.add(groupRelation);
        imhelper.saveGroupRelation(grouprelations);
        Navigator.pushNamed(context, '/MyMessage', arguments: {"GroupRelation": groupRelation}).
          then((value) => getActivityInfo());
        return;
      }
    }
  }

  Future<void> updateCommentLike(commentid, int touid) async {
    bool ret = await _activityService.updateCommentLike(commentid, Global.profile.user!.uid, Global.profile.user!.token!,
        touid, _activity!.actid, errorCallBack);
    if(ret) {
      _listComments.forEach((e) {
        if (e.commentid == commentid) {
          e.likeuid = Global.profile.user!.uid;
          e.likenum = e.likenum! + 1;
        }
      });
      sortComment();
      setState(() {

      });
    }
    _isCommentLike = true;
  }

  Future<void> updateDelCommentLike(commentid, int touid) async {
    bool ret = await _activityService.delCommentLike(commentid, Global.profile.user!.uid, Global.profile.user!.token!,
        touid, errorCallBack);
    if(ret) {
      _listComments.forEach((e) {
        if (e.commentid == commentid) {
          e.likeuid = 0;
          e.likenum = e.likenum! - 1;
        }
      });
      sortComment();
      setState(() {

      });
    }
    _isCommentLike = true;
  }

  Future<void> updatedelMessageReply(int replyid) async{
    bool ret = await _activityService.delMessageReply(Global.profile.user!.token!, Global.profile.user!.uid, replyid, _activity!.actid, errorCallBack);
    if(ret){
      _listComments = await _activityService.getCommentList(_activity!.actid, Global.profile.user!.uid, errorCallBack);
      sortComment();
    }
  }

  Future<void> updateDelMessage(int commentid) async {
    bool ret = await _activityService.delMessage(Global.profile.user!.token!, Global.profile.user!.uid, commentid,  _activity!.actid, errorCallBack);
    if(ret){
      _listComments = await _activityService.getCommentList(_activity!.actid, Global.profile.user!.uid, errorCallBack);
      sortComment();
    }
  }

  updateActivityTime() async {
    await _activityService.updateActivityTime(_activity!.actid, Global.profile.user!.uid, Global.profile.user!.token!,   errorCallBack);
  }

  Future<void> sendToMessage(int commentid, int touid, String content, {User? touser, String captchaVerification = ""}) async {
    blockcommentid = commentid;
    blocktouid = touid;
    if (commentid == 0) {
      commentid = await _activityService.updateMessage(
          _activity!.actid,
          Global.profile.user!.uid,
          Global.profile.user!.token!,
          touid,
          content,
          captchaVerification,
          errorCallBack);
      if (commentid > 0) {
        _listComments.insert(0, Comment(
            commentid,
            _activity!.actid,
            Global.profile.user!,
            content,
            0,
            CommonUtil.getTime(),
            0));
        sortComment();
      }
    }
    else {
      int temreplyid = await _activityService.updateCommentReply(
          commentid,
          _activity!.actid,
          Global.profile.user!.uid,
          Global.profile.user!.token!,
          touid,
          content,
          captchaVerification,
          errorCallBack);
      if (temreplyid > 0) {
        _listComments.forEach((e) {
          if (e.commentid == commentid) {
            if (e.replys == null || e.replys![0] == null) {
              e.replys = [];
            }
            e.replys!.add(CommentReply(
                temreplyid,
                commentid,
                Global.profile.user,
                touser,
                content,
                DateTime.now().toString(),
                false,
                _activity!.actid,
                false,
                "",
                "",
                0,
                ""));
          }
        });
        sortComment();
      }
      else {

      }
    }
  }
  //活动管理获取活动成员
  Widget buildMembers(){
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text('活动成员', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),),
          ),
          Wrap(
            children: buildMemberList(),
          ),
        ],
      ),
    );
  }

  List<Widget> buildMemberList(){
    int index = 0;
    int count = ((_pageWidth-35) / 65).floor();
    List<User> members = [];
    count = _activity!.members!.length > count ? count : _activity!.members!.length;
    for(int i = 0; i < count; i++){
      members.add(_activity!.members![i]);
    }

    List<Widget> widgets = members.map((item){
      if(index == 0){
        index++;
        return Padding(
          padding: EdgeInsets.only(right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  NoCacheClipRRectHeadImage(
                    width: 46,
                    uid: item.uid,
                    cir: 50,
                    imageUrl: '${item.profilepicture}',
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    margin: EdgeInsets.only(top: 28, left: 28),
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular((5.0)), // 圆角度
                      color: Colors.white,

                    ),
                    child: Container(
                      margin: EdgeInsets.only(top: 2, left: 2),
                      decoration: BoxDecoration(
                          borderRadius: new BorderRadius.circular((5.0)), // 圆角度
                          color: Global.profile.backColor,
                      ),
                      width: 15,
                      height: 15,
                      child: Icon(IconFont.icon_qizi_icon, color: Colors.white, size: 15,),

                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
              ),
              Container(
                alignment: Alignment.center,
                width: 45,
                child: Text(item.username.length > 4 ? '${item.username.substring(0, 3)}...' :  item.username,
                      style: TextStyle(fontSize: 11,color: Colors.black54),overflow: TextOverflow.ellipsis,)
              )
            ],
          ),
        );
      }
      else{
        return Padding(
          padding: EdgeInsets.only(right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NoCacheClipRRectHeadImage(
                cir: 46,
                width: 45,
                uid: item.uid,
                imageUrl: '${item.profilepicture}',
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
              ),
              Container(
                width: 45,
                alignment: Alignment.center,
                  child: Text(item.username.length > 4 ? '${item.username.substring(0, 3)}...' :  item.username,
                    style: TextStyle(fontSize: 11,color: Colors.black54), overflow: TextOverflow.ellipsis,),

              )
            ],
          ),
        );
      }
    }).toList();

    if(_activity!.members!.length > count ){
      widgets.add(Padding(
        padding: EdgeInsets.only(left: 0),
        child: InkWell(
          child: Container(
            alignment: Alignment.center,
            width: 45,
            height: 45,
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              border: new Border.all(width: 1, color: Colors.black12),
            ),
            child: Text("更多...",style: TextStyle(color: Colors.black38, fontSize: 12),),
          ),
          onTap: (){
            Navigator.pushNamed(context, '/ActivityMember', arguments: {"activity": _activity});
          },
        ),
      ));
    }

    return widgets;
  }
  //获取评论内容
  Widget buildComment() {
    List<Widget> tem = [];
    if(_isShowComment && _commentid != 0 && !_isShowAll){
      _listComments = _listComments.where((element) => element.commentid == _commentid).toList();
    }
    _listComments.map((v) {
      tem.add(
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(v.user!.username, style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13),),
                                        Text(v.createtime!.substring(5, 10), style: TextStyle(
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
                                      Navigator.pushNamed(context, '/OtherProfile', arguments: {"uid": uid});
                                    }
                                    else if(uid != null && uid == Global.profile.user!.uid) {
                                      Navigator.pushNamed(context, '/MyProfile');
                                    }
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
                                  icon: Icon((Global.profile.user == null || v.likeuid != Global.profile.user!.uid) ? IconFont.icon_aixin :
                                    IconFont.icon_zan1,color: (Global.profile.user == null || v.likeuid != Global.profile.user!.uid) ?
                                    Colors.black38: Global.profile.backColor,),
                                  onPressed: (){
                                    if(_isCommentLike) {
                                      _isCommentLike = false;
                                      if (v.likeuid == 0) {
                                        updateCommentLike(v.commentid, v.user!.uid);
                                      }
                                      else{
                                        updateDelCommentLike(v.commentid, v.user!.uid);
                                      }
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
                        (v.replys != null && v.replys!.length > 0) ? buildChildComment(v.replys!):SizedBox(height: 0,),
                      ],
                    ),
                    onTap: (){
                      _hidemessage = '回复@${v.user!.username}';
                      messageWidget(v.commentid!, v.user!.uid, touser: v.user);
                    },
                    onLongPress: (){
                      if(Global.profile.user != null && v.user!.uid == Global.profile.user!.uid){
                        showDel(v.commentid!);
                      }
                      else{
                        showCommentReport(v.commentid!, v.user!.uid, v.content!);
                      }
                    },
                  ),
                ],
              )
          )
      );
    }).toList();
    return Column(
        children: tem
    );
  }
  //获取子评论
  Widget buildChildComment(List<CommentReply> replys){
    replys.sort((a, b) => (a.replycreatetime!).compareTo(b.replycreatetime!));
    List<Widget> tem = [];
    replys.map((v) {
      tem.add(
          InkWell(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(5),
                  child: Row(
                    children: <Widget>[
                      NoCacheCircleHeadImage(imageUrl: v.replyuser!.profilepicture ?? "", width: 30, uid: v.replyuser!.uid,),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(v.replyuser!.username, style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13),),
                            Text(v.replycreatetime!.substring(5, 10), style: TextStyle(
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
                    child: RichText(
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      text: v.touser!=null? TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              text: '回复 ',
                              style: TextStyle(color: Colors.black, fontSize: 14)
                          ),
                          TextSpan(text: '${v.touser!.username}', style: TextStyle(color: Colors.blue, fontSize: 14)),
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
            onLongPress: (){
              if(Global.profile.user != null && v.replyuser!.uid == Global.profile.user!.uid){
                showReplyDel(v.replyid!);
              }
              else{
                showReplyReport(v.replyid!, v.replyuser!.uid, v.replycontent!);
              }
            },
            onTap: (){
              _hidemessage = '回复@${v.replyuser!.username}';
              messageWidget(v.commentid!, v.replyuser!.uid, touser: v.replyuser!);
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
  //获取相关推荐
  Widget buildMoreActivity(List<Activity> activitys){
    List<Widget> moreActivity = [];
    moreActivity = activitys.map(
          (e) {
        return buildActivityItem(e);
      },
    ).toList();
    int count = moreActivity.length % 2 == 0 ?  (moreActivity.length/2 ).toInt(): (moreActivity.length/2+1).toInt();
    _moreHeight = ((_pageWidth  ) / 2 ) * count;
    return Container(
      height: _moreHeight + 19,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 1,
        mainAxisSpacing: 5,
        children: moreActivity,
      ),
    );
  }
  //活动内容
  Widget buildActivityItem(Activity activity){
    Widget widgetMoney = SizedBox.shrink();
    widgetMoney = Row(
      children: [
        Text("￥", style: TextStyle(color: Colors.red, fontSize: 10),),
        Text(activity.mincost.toString() + "—" + activity.maxcost.toString(), style: TextStyle(color: Colors.red, fontSize: 12,fontWeight: FontWeight.bold),)
      ],
    );

    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": activity.actid}).then((val){
        });
      },
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                width: _pageWidth,
                child:  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                    child: activity.coverimg != "" ? CachedNetworkImage(
                      imageUrl: '${activity.coverimg}?x-oss-process=image/resize,m_fixed,w_600/sharpen,50/quality,q_80',//缩放压缩
                      fit: BoxFit.cover,
                    ):Image.asset("images/icon_nullimg.png", width: _pageWidth, fit: BoxFit.cover,)
                ),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                ),
              ),
            ) ,
            Container(
              height: 26,
              padding: EdgeInsets.only(top: 5, left: 10),
              child: Text(
                activity.content ,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              height: 16,
              padding: EdgeInsets.only(left: 9, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widgetMoney,
                  Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CommonUtil.getTextDistance(activity.lat, activity.lng, Global.profile.lat, Global.profile.lng),
                      )
                  ),
                ],
              ),
            ),
            Container(
              height: 26,
              padding: EdgeInsets.only(left: 9, bottom: 5, right: 5, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  NoCacheClipRRectOhterHeadImage(
                    width: 17,
                    cir: 50,
                    imageUrl: activity.user!.profilepicture ?? "",
                    uid: activity.user!.uid,
                    // maxRadius: 40.0,
                  ),
                  Expanded(child:Container(
                    margin: EdgeInsets.only(left: 5),
                    child:  Text(
                      activity.user!.username,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //goodprice
  Widget buildGoodPrice(){
    Widget widgetMoney = SizedBox.shrink();
    widgetMoney = Row(
      children: [
        Container(
          padding: EdgeInsets.all(2),
          child: Text(
              _activity!.goodPiceModel!.brand, style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.deepOrange, Colors.redAccent, Colors.red]
            ),
          ),
        ),
        SizedBox(width: 6,),
        Text("￥", style: TextStyle(color: Colors.red, fontSize: 10),),
        Text(_activity!.goodPiceModel!.mincost.toString(), style: TextStyle(color: Colors.red, fontSize: 14,fontWeight: FontWeight.bold),),
        _activity!.goodPiceModel!.maxcost > 0 ? Text('-', style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),):SizedBox.shrink(),
        _activity!.goodPiceModel!.maxcost > 0 ? Text(_activity!.goodPiceModel!.maxcost.toString(), style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),):SizedBox.shrink(),
      ],
    );


    return  InkWell(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRectOhterHeadImageContainer(imageUrl: _activity!.goodPiceModel!.pic,  width: 50, height: 50, cir: 9,),
            SizedBox(width: 10,),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_activity!.goodPiceModel!.title, style: TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis),),
                SizedBox(height: 5,),
                widgetMoney
              ],
            ))
          ],
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade200
        ),
      ),
      onTap: (){
        if(_activity!.goodpriceid != null && _activity!.goodpriceid!.isNotEmpty) {
          _gotoGoodPrice();
        }
      },
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

  //留言输入框
  void messageWidget(int commentid, int touid, {User? touser}){
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
                    child: TextField(maxLength: 255, maxLines: null, autofocus: true,
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
                    onPressed: () {
                      if (_message.isNotEmpty) {
                        Navigator.pop(context);
                        sendToMessage(commentid, touid, _message, captchaVerification: "" , touser: touser, );
                      }
                      else {
                        ShowMessage.showToast('你还没有输入留言!');
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
  //弹出菜单
  Future<void> _openSimpleDialog() async{
    var result=await showDialog(context: context,builder: (BuildContext context){
      return SimpleDialog(
        //标题
        title: Text('活动管理'),
        //子元素
        children: <Widget>[
          _activity!.status == 0 ? SimpleDialogOption(
            child: Text('刷新', style: TextStyle(color: Colors.black87),),
            onPressed: (){
              updateActivityTime();
              Navigator.pop(context);
            },
          ) : SizedBox.shrink(),
          _activity!.status == 0  ? SimpleDialogOption(
            child: Text('编辑', style: TextStyle(color: Colors.black87),),
            onPressed: (){
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return UpdateActivityDialog(textcontent: _activity!.content, activity: _activity!,);
                  }
              ).then((value){
                setState(() {

                });
              });
            },
          ) : SizedBox.shrink(),
          _activity!.status == 0 ? SimpleDialogOption(
            child: Text('结束', style: TextStyle(color: Colors.black87),),
            onPressed: (){
              Navigator.pop(context);
              _asked().then((value){
                setState(() {

                });
              });

            },
          ) : SizedBox.shrink(),
          SimpleDialogOption(
            child: Text('群聊', style: TextStyle(color: Colors.black87),),
            onPressed: (){
              Navigator.pop(context);
              joinGroupMessage();
            },
          ),

          SimpleDialogOption(
            child: Text('取消', style: TextStyle(color: Colors.black87)),
            onPressed: (){
              Navigator.pop(context,0);
            },
          ),
        ],
      );
    });
  }
  //查看goodprice
  Future<void> _gotoGoodPrice() async {
    Navigator.pushNamed(
        context, '/GoodPriceInfo', arguments: {
      "goodprice": _activity!.goodPiceModel!
    });
  }
  //是否确认结束
  Future<void> _asked() async {
    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('结束活动后将不在显示，确定要结束吗?', style: new TextStyle(fontSize: 17.0)),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () async {
                  bool ret = await _activityService.updateActivityStatusEnd(_activity!.actid, Global.profile.user!.uid, Global.profile.user!.token!,   errorCallBack);
                  if(ret){
                    _activity!.status = 1;
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
  //计算高度
  double getImageWH(Activity activity){
    double width = double.parse(activity.coverimgwh.split(',')[0]);
    double height = double.parse(activity.coverimgwh.split(',')[1]);
    double ratio = width/height;//宽高比
    double retheight = (_pageWidth.floor().toDouble()) / ratio;

    return retheight; //图片缩放高度
  }
  //滑动拼图
  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v){
            sendToMessage(blockcommentid, blocktouid, _message, captchaVerification: v);
          },
          onFail: (){

          },
        );
      },
    );
  }

  void showCommentReport(int commentid, int touid, String content) {
    if (Global.profile.user == null) {
      Navigator.pushNamed(context, '/Login');
      return;
    }
    showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) =>
            Container(
              height: 99,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      color: Colors.white,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                                child: Text(
                                  '举 报', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  Navigator.pop(context);
                                  //0活动 1商品 2用户 3 单人聊天 4 活动群聊天 5社团群聊天 6活动留言 7活动回复 8好价评价 9好价回复
                                  Navigator.pushNamed(context, '/ReportAllMessage', arguments: {"sourcetype": 6, "actid": commentid.toString(), "touid": touid, "content": content});
                                }),
                          ),
                        ],
                      )
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

  void showReplyReport(int replyid, int touid, String content) {
    if (Global.profile.user == null) {
      Navigator.pushNamed(context, '/Login');
      return;
    }
    showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) =>
            Container(
              height: 99,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      color: Colors.white,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                                child: Text(
                                  '举 报', style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  Navigator.pop(context);
                                  //0活动 1商品 2用户 3 单人聊天 4 活动群聊天 5社团群聊天 6活动留言 7活动回复 8好价评价 9好价回复
                                  Navigator.pushNamed(context, '/ReportAllMessage', arguments: {"sourcetype": 7, "actid": replyid.toString(), "touid": touid, "content": content});
                                }),
                          ),
                        ],
                      )
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

  void showDel(int commentid){
    showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) =>
            Container(
              height: 99,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      color: Colors.white,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                                child: Text(
                                  '删 除',  style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  updateDelMessage(commentid);
                                  Navigator.pop(context);
                                }),
                          ),
                        ],
                      )
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

  void showReplyDel(int replyid){
    showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) =>
            Container(
              height: 99,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      color: Colors.white,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                                child: Text(
                                  '删 除',  style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  updatedelMessageReply(replyid);
                                  Navigator.pop(context);
                                }),
                          ),
                        ],
                      )
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

}

//更新活动
class UpdateActivityDialog extends Dialog{
  String textcontent = "";//活动内容
  Activity activity;

  UpdateActivityDialog({
    Key? key, required this.textcontent, required this.activity
  }) : super(key: key){}

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.all(12.0),
        child: new Material(
            type: MaterialType.transparency,
            child: Center(
                child: Container(
                  width: double.infinity,
                  height: 260,
                  decoration: ShapeDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ))),
                  margin: const EdgeInsets.only(left: 10,right: 10),
                  child: Padding(
                    padding: EdgeInsets.only(top: 10,left: 10, right: 10),
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Text('编辑活动', style: TextStyle(color: Colors.black, fontSize: 16),),
                        ),
                        SizedBox(height: 10,),
                        TextField(
                          maxLength: 500,//最大长度，设置此项会让TextField右下角有一个输入数量的统计字符串
                          maxLines: 6,//最大行数
                          autocorrect: true,//是否自动更正
                          textAlign: TextAlign.left,//文本对齐方式
                          style: TextStyle(color: Colors.black87, fontSize: 14, ),//输入文本的样式
                          onChanged: (text) {//内容改变的回调
                            textcontent = text;
                          },
                          controller: TextEditingController.fromValue(TextEditingValue(
                            // 设置内容
                            text: textcontent,
                            // 保持光标在最后
                            selection: TextSelection.fromPosition(TextPosition(
                              affinity: TextAffinity.downstream,
                              offset: textcontent.length)))),
                          decoration: InputDecoration(
                            counterText:"",
                            hintText: "有趣的活动介绍，能让你组织的活动获得更多关注。",
                            hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 0,  bottom: 0, right: 10),
                          )
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                child: Text('确认', style: TextStyle(color: Global.profile.fontColor, fontSize: 14),),
                                color: Colors.blue,
                                onPressed: () async {
                                  ActivityService _temActivity = ActivityService();
                                  bool ret = await _temActivity.updateActivity(activity.actid, Global.profile.user!.uid,
                                      Global.profile.user!.token!,  textcontent, (code, error){
                                        ShowMessage.showToast(error);
                                      });
                                  if(ret) {
                                    activity.content = textcontent;
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: 10,),
                              RaisedButton(
                                child: Text('取消', style: TextStyle(color: Colors.black54, fontSize: 14),),
                                color: Colors.white,
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
            )
        )
    );
  }
}

