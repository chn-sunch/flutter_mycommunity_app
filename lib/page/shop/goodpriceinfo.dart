import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:rate_in_stars/rate_in_stars.dart';

import '../../model/grouppurchase/goodpice_model.dart';
import '../../model/user.dart';
import '../../model/comment.dart';
import '../../model/commentreply.dart';
import '../../model/activity.dart';
import '../../model/evaluateactivity.dart';
import '../../common/iconfont.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../util/common_util.dart';
import '../../service/gpservice.dart';
import '../../service/activity.dart';
import '../../widget/shareview.dart';
import '../../widget/my_divider.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/icontext.dart';
import '../../widget/photo/photo_viewwrapper.dart';
import '../../widget/captcha/block_puzzle_captcha.dart';
import '../../widget/btnpositioned.dart';
import '../../global.dart';
///渐变 APP var
class GoodPriceInfo extends StatefulWidget {
  Object? arguments;
  late GoodPiceModel goodPiceModel;

  @override
  State<StatefulWidget> createState() => GoodPriceInfoState();

  GoodPriceInfo({required this.arguments}){
    if(arguments != null)
      goodPiceModel = (arguments as Map)["goodprice"];
  }
}

class GoodPriceInfoState extends State<GoodPriceInfo> {
  late AppBarWidget appBar;
  late ScrollController scrollController;
  late PositionedBtnWidget roundLeftBtn;
  late PositionedBtnWidget rectLeftBtn;
  late PositionedBtnWidget shareBtn;
  late PositionedBtnWidget rectshareBtn;
  late PositionedBtnWidget rectTitleBtn;
  String _message = "";
  double _pageWidth = 0;
  bool  _iscollection = false,_isCollectEnter = true, isMessageEnter = true, _isCommentLike = true;
  List<Map<String, String>> imglist = [];
  List<Map<String, String>> albumpicslist = [];
  GPService _gpService = GPService();
  ActivityService _activityService = ActivityService();
  String error = "";
  String errorstatusCode = "";
  ImHelper imHelper = new ImHelper();
  String _hidemessage = "问问商家";
  List<Comment> _comments = [];
  List<EvaluateActivity> _evaluates = [];
  String _ordertype = "0";//排序类型， 0：按时间 1：按热度
  String _sortname = "按时间";
  List<Activity> _activitys = [];
  bool _isEnter = true;

  @override
  void initState() {
    super.initState();
    appBar = AppBarWidget();
    scrollController = ScrollController();
    roundLeftBtn = PositionedBtnWidget(
      size: 29,
      btnTop: 25,
      left: 20,
      opacity: 1,
      image: "images/fanghui.png",
      actionFunction: () {
        Navigator.pop(context);
      },
    );
    rectLeftBtn = PositionedBtnWidget(
      size: 29,
      btnTop: 25,
      left: 20,
      opacity: 0,
      image: "images/fanghui_black.png",
      actionFunction: () {
        Navigator.pop(context);
      },
    );
    shareBtn = PositionedBtnWidget(
      size: 29,
      btnTop: 25,
      right: 20,
      opacity: 1,
      content: ShareView(icon: IconButton(icon:Image.asset("images/fenxiang.png"), iconSize: 29, onPressed: null, ), image: widget.goodPiceModel.pic, contentid: widget.goodPiceModel.goodpriceid,
          content: widget.goodPiceModel.title, sharedtype: "1", actid:  widget.goodPiceModel.goodpriceid, createuid: widget.goodPiceModel.uid,),
      actionFunction: () {

      },
    );
    rectshareBtn = PositionedBtnWidget(
      size: 1,
      btnTop: 25,
      right: 20,
      opacity: 0,
      content: ShareView(icon: IconButton(icon:Image.asset("images/fenxiang_black.png"), iconSize: 1, onPressed: null,), image: widget.goodPiceModel.pic, contentid: widget.goodPiceModel.goodpriceid,
          content: widget.goodPiceModel.title, sharedtype: "1", actid:  widget.goodPiceModel.goodpriceid, createuid: widget.goodPiceModel.uid,),
      actionFunction: () {

      },
    );
    rectTitleBtn = PositionedBtnWidget(
      btnTop: 36,
      left: 0,
      opacity: 0,
      content: Container(
        width: 69,
        child: Text(widget.goodPiceModel.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis,),
      ),
      actionFunction: () {
        Navigator.pop(context);
      },
    );
    getCollectionAndComment();

  }


  getCollectionAndComment() async {
    if(Global.profile.user != null)
      _comments = await _gpService.getCommentList(widget.goodPiceModel.goodpriceid, Global.profile.user!.uid, errorCallBack);
    else{
      _comments = await _gpService.getCommentList(widget.goodPiceModel.goodpriceid, 0, errorCallBack);
    }
    sortComment(_comments, "1");

    _evaluates = await _gpService.getEvaluateGoodPriceList(widget.goodPiceModel.goodpriceid, 0, errorCallBack);


    if(Global.profile.user != null) {
      Map collectionstate = await _gpService.getGoodPriceCollectionState(
          widget.goodPiceModel.goodpriceid, Global.profile.user!.uid);
      _iscollection = collectionstate["iscollection"];
    }
    //获取相关活动
    _activitys = await _gpService.getActivityList(widget.goodPiceModel.goodpriceid);

    if(_iscollection || (_comments != null && _comments.length>0) || (_activitys != null && _activitys.length > 0)) {
      if (mounted) {
        setState(() {

        });
      }
    }
  }

  double maxOffset = 80.0;

  scrollViewDidScrolled(double offSet) {
    //print('scroll offset ' + offSet.toString());
    ///appbar 透明度
    double appBarOpacity = offSet / maxOffset;
    double halfPace = maxOffset / 2.0;
    ///圆形按钮透明度
    double roundOpacity = (halfPace - offSet) / halfPace;
    ///方形按钮透明度
    double rectOpacity = (offSet - halfPace) / halfPace;
    if (appBarOpacity < 0) {
      appBarOpacity = 0.0;
    } else if (appBarOpacity > 1) {
      appBarOpacity = 1.0;
    }
    if (roundOpacity < 0) {
      roundOpacity = 0.0;
    } else if (roundOpacity > 1) {
      roundOpacity = 1;
    }
    if (rectOpacity < 0) {
      rectOpacity = 0.0;
    } else if (rectOpacity > 1) {
      rectOpacity = 1.0;
    }
    //print('roundOpacity $roundOpacity rectOpacity $rectOpacity');
    ///更新透明度
    if (appBar != null && appBar.updateAppBarOpacity != null) {
      appBar.updateAppBarOpacity!(appBarOpacity);
    }
    if (roundLeftBtn != null && roundLeftBtn.updateOpacity != null) {
      roundLeftBtn.updateOpacity!(roundOpacity);
      shareBtn.updateOpacity!(roundOpacity);
    }
    if (rectLeftBtn != null && rectLeftBtn.updateOpacity != null) {
      rectLeftBtn.updateOpacity!(rectOpacity);
      rectshareBtn.updateOpacity!(rectOpacity);
      rectTitleBtn.updateOpacity!(rectOpacity);
    }

  }

  @override
  Widget build(BuildContext context) {
    _pageWidth = MediaQuery.of(context).size.width;
    print(_pageWidth);
    rectTitleBtn.left = (_pageWidth)/2  - 35;

    return widget.goodPiceModel != null ? Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 10),
        color: Colors.white,
        height: 53,
        child: Row(
          children: [
            SizedBox(width: 10,),
            InkWell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('赞',
                      style: TextStyle(fontSize: 17)),
                  Text(widget.goodPiceModel.satisfactionrate == 0 ? '0' : '${(widget.goodPiceModel.satisfactionrate * 100).toInt()}%',
                      style: TextStyle(fontSize: 16, )),
                ],
              ),
              onTap: () async {
                if(Global.profile.user != null) {
                  bool isLike = await imHelper.selGoodPriceState(widget.goodPiceModel.goodpriceid, Global.profile.user!.uid, 1);
                  bool isUnLike = await imHelper.selGoodPriceState(widget.goodPiceModel.goodpriceid, Global.profile.user!.uid, 0);


                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context){
                        return new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              child: Container(
                                margin: EdgeInsets.only(top: 20, bottom: 20),
                                alignment: Alignment.center,
                                child: Text("赞 ${widget.goodPiceModel.likenum}",style: TextStyle(color: isLike ? Colors.red : Colors.black87),),
                              ),
                              onTap: () async {
                                if(isLike) {
                                  bool ret =await _gpService.delGoodPriceLike(
                                      widget.goodPiceModel.goodpriceid,
                                      Global.profile.user!.uid,
                                      Global.profile.user!.token!, errorCallBack);
                                  if(ret)
                                    widget.goodPiceModel.likenum =  widget.goodPiceModel.likenum-1;
                                }
                                else{
                                  //先取消不赞，在点赞
                                  if(isUnLike){
                                    bool ret = await _gpService.updateCancelUnLike(
                                        widget.goodPiceModel.goodpriceid,
                                        Global.profile.user!.uid,
                                        Global.profile.user!.token!, errorCallBack);
                                    if(ret)
                                      widget.goodPiceModel.unlikenum =  widget.goodPiceModel.unlikenum-1;
                                  }
                                  bool ret =await _gpService.updateGoodPriceLike(
                                      widget.goodPiceModel.goodpriceid,
                                      Global.profile.user!.uid,
                                      Global.profile.user!.token!, errorCallBack);
                                  if(ret)
                                    widget.goodPiceModel.likenum =  widget.goodPiceModel.likenum+1;
                                }
                                if(widget.goodPiceModel.likenum + widget.goodPiceModel.unlikenum > 0){
                                  widget.goodPiceModel.satisfactionrate = widget.goodPiceModel.likenum/(widget.goodPiceModel.likenum + widget.goodPiceModel.unlikenum);
                                }
                                else{
                                  widget.goodPiceModel.satisfactionrate = 0;
                                }
                                Navigator.pop(context);
                                setState(() {

                                });
                              },
                            ),
                            MyDivider(),
                            InkWell(
                              onTap: () async {
                                if(isUnLike){
                                  bool ret = await _gpService.updateCancelUnLike(
                                      widget.goodPiceModel.goodpriceid,
                                      Global.profile.user!.uid,
                                      Global.profile.user!.token!, errorCallBack);
                                  if(ret)
                                    widget.goodPiceModel.unlikenum =  widget.goodPiceModel.unlikenum-1;
                                }
                                else {
                                  if(isLike){
                                    bool ret =await _gpService.delGoodPriceLike(
                                        widget.goodPiceModel.goodpriceid,
                                        Global.profile.user!.uid,
                                        Global.profile.user!.token!, errorCallBack);
                                    if(ret)
                                      widget.goodPiceModel.likenum =  widget.goodPiceModel.likenum-1;
                                  }
                                  bool ret = await _gpService.updateUnLike(
                                      widget.goodPiceModel.goodpriceid,
                                      Global.profile.user!.uid,
                                      Global.profile.user!.token!, errorCallBack);
                                  if(ret)
                                    widget.goodPiceModel.unlikenum =  widget.goodPiceModel.unlikenum+1;
                                }

                                if(widget.goodPiceModel.likenum + widget.goodPiceModel.unlikenum > 0){
                                  widget.goodPiceModel.satisfactionrate = widget.goodPiceModel.likenum/(widget.goodPiceModel.likenum
                                      + widget.goodPiceModel.unlikenum);
                                }
                                else{
                                  widget.goodPiceModel.satisfactionrate = 0;
                                }
                                Navigator.pop(context);
                                setState(() {

                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 20, bottom: 20),
                                alignment: Alignment.center,
                                child: Text("不赞 ${widget.goodPiceModel.unlikenum}",style: TextStyle(color: isUnLike ? Colors.red : Colors.black87)),
                              ),
                            ),
                          ],
                        );
                      }
                  );
                }
                else{
                  Navigator.pushNamed(context, '/Login');
                }
              },
            ),
            SizedBox(width: 30,),
            InkWell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(
                      _iscollection ? IconFont.icon_collection_b : IconFont
                          .icon_shoucang, color:
                  _iscollection ? Colors.blueAccent : Colors.black87,size: 17),
                  SizedBox(height: 5,),
                  Text('${widget.goodPiceModel.collectionnum}', style: TextStyle(fontSize: 16),),
                ],
              ),
              onTap: () async {
                if(Global.profile.user == null){
                  Navigator.pushNamed(context, '/Login');
                  return;
                }
                if(_isCollectEnter) {
                  _isCollectEnter = false;
                  if (!_iscollection){
                    await _gpService.updateGoodPriceCollection(widget.goodPiceModel, Global.profile.user!.uid, Global.profile.user!.token!, errorCallBack);
                    _isCollectEnter = true;
                    _iscollection = true;
                    setState(()  {
                      widget.goodPiceModel.collectionnum = widget.goodPiceModel.collectionnum+1;
                    });
                  }
                  else {
                    await _gpService.delGoodPriceCollection(widget.goodPiceModel.goodpriceid, Global.profile.user!.uid, Global.profile.user!.token!, errorCallBack);
                    _isCollectEnter = true;
                    _iscollection = false;
                    if (mounted) {
                      setState(() {
                        widget.goodPiceModel.collectionnum = widget.goodPiceModel.collectionnum-1;
                      });
                    }
                  }
                }
              },
            ),
            SizedBox(width: 30,),
            InkWell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(
                      IconFont.icon_liuyan, color: Colors.black87, size: 19
                  ),
                  SizedBox(height: 2,),
                  Text(
                      "问问商家", style: TextStyle(fontSize: 14)),
                ],
              ),
              onTap: () {
                if (Global.profile.user != null) {
                  if(Global.profile.user != null) {
                    _hidemessage = "问问商家";
                    sendMessage(0, widget.goodPiceModel.uid);
                  }
                  else{
                    Navigator.pushNamed(context, '/Login');
                  }
                }
                else {
                  Navigator.pushNamed(context, '/Login').then((val) {
                    if (Global.profile.user != null) {
                      //_activityInfoBloc.add(GetInfo(_actid, Global.profile.user));
                    }
                  });
                }
              }
            ),
            SizedBox(width: 30,),
            Expanded(
              child: InkWell(
                child: Container(
                  margin: EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('一起出发', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Global.profile.backColor,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                onTap: (){
                  if(Global.profile.user != null) {
                    Navigator.pushNamed(context, '/IssuedActivity', arguments: {
                      "maxcost": widget.goodPiceModel.maxcost,
                      "provinceCode": widget.goodPiceModel.province,
                      "city": widget.goodPiceModel.city,
                      "address": widget.goodPiceModel.address,
                      "addresstitle": widget.goodPiceModel.addresstitle,
                      "lat": widget.goodPiceModel.lat,
                      "lng": widget.goodPiceModel.lng,
                      "mincost": widget.goodPiceModel.mincost,
                      "content": widget.goodPiceModel.title,
                      "pic": widget.goodPiceModel.pic,
                      "goodpriceid": widget.goodPiceModel.goodpriceid
                    });
                  }
                  else{
                    Navigator.pushNamed(context, '/Login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Stack(
          children: <Widget>[
            ///监听滚动
            NotificationListener(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification &&
                    notification.depth == 0) {
                  ///滑动通知
                  scrollViewDidScrolled(notification.metrics.pixels);
                }
                ///通知不再上传
                return true;
              },
              child: MediaQuery.removePadding(
                  removeTop: true,
                  context:  context,
                  child:ListView(
                    controller: scrollController,
                    children: [
                      buildContentHeadImg(),
                      buildContentHeadinfo(),
                      SizedBox(height: 10,),
                      buildCurrentOrder(),
                      SizedBox(height: 10,),
                      buildProductEvaluate(),
                      SizedBox(height: 10,),
                      buildProductQuestion(),
                      SizedBox(height: 10,),
                    ],
                  )
              ),
            ),
            appBar,
            rectLeftBtn,
            roundLeftBtn,
            shareBtn,
            rectshareBtn,
            rectTitleBtn,
          ],
        ),
    ): Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
        ),
      )
    );
  }

  Widget buildContentHeadImg(){
    albumpicslist = [];
    List imagepaths = widget.goodPiceModel.albumpics.split(',');
    double temwidth = 0;
    if(imagepaths.length > 10)
      temwidth += 10;

    if(imagepaths.length > 0){
      for(int i=0;i<imagepaths.length;i++){
        albumpicslist.add({"tag": UniqueKey().toString(),"img": imagepaths[i].toString()});
      }
    }

    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
      height: _pageWidth,
      child: Swiper(
        itemBuilder: (BuildContext context, int index){
          return ClipRRectOhterHeadImageContainer(imageUrl: imagepaths[index],  height: _pageWidth,
            width: _pageWidth, borderwidth: 0, cir: 0,);

        },
        onTap: (index){
          showPhoto(context, albumpicslist[index], index, albumpicslist);
        },
        pagination: SwiperCustomPagination (
          builder: (BuildContext context,  SwiperPluginConfig config){
            return imagepaths.length > 1 ? Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 30,
                width: 45+temwidth,
                margin: EdgeInsets.only(right: 10, bottom: 10),
                alignment: Alignment.center,
                child: Text('${config.activeIndex + 1}/${imagepaths.length}', style: TextStyle(color: Colors.white),),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF7F7F7F)
                ),
              ),
            ):SizedBox.shrink();
          }
        ),
        loop: false,
        itemCount: albumpicslist.length,
      ),
    );
  }

  Widget buildContentHeadinfo(){
    Widget price = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 21,
          width: 31,
          padding: EdgeInsets.only(top: 2, bottom: 2, left: 2, right: 2),
          alignment: Alignment.center,
          child: Text('${widget.goodPiceModel.brand}', style: TextStyle(color: Colors.white, fontSize: 10),),
          decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular((5.0)), // 圆角度
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Global.profile.backColor!,
                    Colors.deepOrange
                  ]
              )
          ),
        ),
        SizedBox(width: 10,),
        Text('￥ ',style: TextStyle(color: Colors.red, fontSize: 12),),
        Text('${widget.goodPiceModel.mincost}—${widget.goodPiceModel.maxcost}元' ,
          style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, ),
      ],
    );
    Widget tag = SizedBox.shrink();
    List<Widget> wtag = [];
    wtag.add(SizedBox.shrink());

    if(widget.goodPiceModel.tag != null && widget.goodPiceModel.tag.isNotEmpty){
      List<String> stag = widget.goodPiceModel.tag.split(",");
      stag.forEach((e) {
        wtag.add(
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
              child: Text(e, style: TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold),),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.all(Radius.circular(5)
                ),
              ),
            )
        );

        wtag.add(
            SizedBox(width: 5)
        );
      });

      tag = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: wtag,
      );
    }


    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          price,
          SizedBox(height: 10,),
          Text(widget.goodPiceModel.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          SizedBox(height: 10,),
          tag,
          SizedBox(height: 15,),
          Text(widget.goodPiceModel.content, style: TextStyle(color: Colors.black87, fontSize: 14),),
          SizedBox(height: 10,),

        ]
      )
    );
  }

  Widget buildCurrentOrder(){
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text('相关活动', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),),
          ),
          (_activitys != null && _activitys.length > 0) ? buildActivityList() : Container(
            alignment: Alignment.center,
            height: 50,
            child: Text('还没有相关活动', style: TextStyle(color: Colors.black54, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget buildActivityList(){
    List<Widget> tem = [];
    _activitys.forEach((v) {
      tem.add(
          InkWell(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  NoCacheCircleHeadImage(imageUrl: v.user!.profilepicture!, width: 50, uid: v.user!.uid),
                  SizedBox(width: 10,),
                  Expanded(child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(v.content, maxLines: 2, overflow: TextOverflow.ellipsis,)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('有${v.currentpeoplenum.toString()}人参加', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      )
                    ],
                  )),
                  FlatButton(
                    child: Text('去参加', style: TextStyle(color: Colors.white, fontSize: 12),),
                    color: Global.profile.backColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    onPressed: (){
                      Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": v.actid});

                    },),
                ],
              ),
            ),
            onTap: (){
              Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": v.actid});
            },
          )
      );
    });
    return Column(
      children: tem,
    );
  }
  //活动位置
  Widget buildLocation(){
    return InkWell(
      onTap: (){
        LatLng latLng = LatLng(widget.goodPiceModel.lat, widget.goodPiceModel.lng);
        Navigator.pushNamed(context, '/MapLocationShowNav', arguments: {"LatLng" : latLng, "title": widget.goodPiceModel.addresstitle,
          "address": widget.goodPiceModel.address});
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
                    widget.goodPiceModel.addresstitle != null && widget.goodPiceModel.addresstitle.isNotEmpty ? Text("${widget.goodPiceModel.addresstitle}",
                      style: TextStyle(color: Colors.black87, fontSize: 13), overflow: TextOverflow.ellipsis,) : Text("", style:  TextStyle(color: Colors.black87, fontSize: 13)),
                    Row(
                      children: [
                        widget.goodPiceModel.address != null && widget.goodPiceModel.address.isNotEmpty ? Expanded(child: Text("(${widget.goodPiceModel.address})",
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

  Widget buildProductEvaluate(){
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('评价 ${widget.goodPiceModel.evaluatenum == 0 ? '': widget.goodPiceModel.evaluatenum}',
                      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              )
          ),
          buildEvaluateList(),
        ],
      ),
    );

  }

  Widget buildProductQuestion(){
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('问答 ${widget.goodPiceModel.commentnum == 0 ? '': widget.goodPiceModel.commentnum}',
                    style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                InkWell(
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
                    if (_comments != null && _comments.length > 0) {
                      if (_sortname == "按时间") {
                        _sortname =
                        '按热度'; //当前排序方式
                        _ordertype = "1";
                        sortComment(_comments, _ordertype);
                      }
                      else {
                        _sortname = '按时间';
                        _ordertype = "0";
                        sortComment(_comments, _ordertype);
                      }
                      if(mounted) {
                        setState(() {

                        });
                      }
                    }
                  },
                )
              ],
            )
          ),
          buildComment(),
        ],
      ),
    );

  }

  //获取评论内容
  Widget buildComment() {
    List<Widget> tem = [];
    if (_comments != null && _comments.length > 0) {
      _comments.map((v) {
        tem.add(
            Container(
                margin: EdgeInsets.only(bottom: 10, left: 9),
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
                                    onPressed: (){
                                      if(_isCommentLike) {
                                        _isCommentLike = false;
                                        if (v.likeuid == 0)
                                          commentLike(v.commentid!, Global.profile.user!.uid,  Global.profile.user!.token!, v.user!.uid, widget.goodPiceModel.goodpriceid);
                                        else
                                          delCommentLike(v.commentid!, Global.profile.user!.uid,  Global.profile.user!.token!, v.user!.uid);
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
    }
    else {
      tem.add(Container(height: 50, width: double.infinity,
        child: Center(child: Text('还没有问题', style: TextStyle(color: Colors.black54, fontSize: 14, ),),),));
    }
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
              sendMessage(v.commentid!, v.replyuser!.uid, touser: v.replyuser!);
            },
            onLongPress: (){
              if(v.replyuser!.uid == Global.profile.user!.uid){
                showReplyDel(v.replyid!);
              }
              else{
                showReplyReport(v.replyid!, v.replyuser!.uid, v.replycontent!);
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

  //获取商品评价
  Widget buildEvaluateList(){
    List<Widget> evaluateContent = [];
    int index = 1;
    _evaluates.map((e){
      evaluateContent.add(
        Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NoCacheCircleHeadImage(imageUrl: e.user!.profilepicture!, width: 39, uid: e.user!.uid,),
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start,
                            mainAxisAlignment: MainAxisAlignment
                                .start,
                            children: <Widget>[
                              Text(e.user!.username,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12),),
                              SizedBox(height: 3,),
                              RatingStars(
                                editable: true,
                                rating: double.parse(e.liketype!.toString()),
                                color: Colors.redAccent,
                                iconSize: 19,
                              ),

                            ],
                          ),
                        ),
                        onTap: () {
                          int uid = e.user!.uid;
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
                  Text(e.createtime!.substring(0, 10),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13),),
                ],
              ),
              InkWell(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
                      child: Text(e.content!, style: TextStyle(
                          color: Colors.black, fontSize: 14),),
                    ),
                    e.imagepaths != null && e.imagepaths! != "" ? Container(
                      padding: EdgeInsets.only(bottom: 5),
                      height: 120,
                      child: GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 30.0,
                        padding: EdgeInsets.all(10.0),
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        children: getImageList(e.imagepaths!),
                      ),
                    ) : SizedBox.shrink(),
                  ],
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/EvaluateInfo', arguments: {"evaluateActivity": e}).then((val){
                    setState(() {

                    });
                  });                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: IconText(
                      e.likenum == 0 ? '点赞':e.likenum.toString(),
                      padding: EdgeInsets.only(right: 2),
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                      icon: e.likeuid != 0 ? Icon(IconFont.icon_zan1, color: Colors.redAccent,size: 18,):
                      Icon(IconFont.icon_aixin, color: Colors.black45,size: 18,),
                      onTap: (){
                      },
                    ),
                    onTap: () async {
                      if(Global.profile.user == null){
                        Navigator.pushNamed(context, '/Login');
                        return;
                      }
                      if(_isEnter) {
                        _isEnter = false;
                        if (e.likeuid == 0){
                          await evaluateLike(e.evaluateid!, e.user!.uid);
                          _isEnter = true;
                        }
                        else{
                          await delevaluateLike(e.evaluateid!, e.user!.uid);
                          _isEnter = true;
                        }
                      }
                    },
                  ),
                  SizedBox(width: 20,),
                  InkWell(
                    child: IconText(
                      e.replynum.toString() == "0" ? '回复' : e.replynum.toString(),
                      padding: EdgeInsets.only(right: 2),
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                      icon: Icon(IconFont.icon_navbar_xiaoxi, color: Colors.black45, size: 18,),
                      onTap: (){
                      },
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, '/EvaluateInfo', arguments: {"evaluateActivity": e}).then((val){
                        setState(() {

                        });
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      );
      index++;
    }).toList();
    return evaluateContent.length == 0 ? Center(child: Text('Emm...就是没有评价...', style: TextStyle(color: Colors.black54, fontSize: 14, ),),) :
    Column(
      children: evaluateContent,
    );
  }


  void showPhoto(BuildContext context, Map<String, String> img, int index, List<Map<String, String>> imglist) {
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
                      style: TextStyle(color: Colors.white),),
                    color: Colors.redAccent,
                    onPressed: () async {
                      if (_message.isNotEmpty) {
                        Navigator.pop(context);

                        if(commentid == 0){
                          commentid = await _gpService.updateMessage(widget.goodPiceModel.goodpriceid, Global.profile.user!.uid,
                              Global.profile.user!.token!, touid, _message, "", errorCallBack);
                          if(commentid > 0){
                            _comments.insert(0, Comment(commentid, widget.goodPiceModel.goodpriceid, Global.profile.user, _message, 0,
                                CommonUtil.getTime(), 0));
                            sortComment(_comments, _ordertype);
                            setState(() {

                            });
                          }
                          else{
                            errorHandle(commentid == null ? 0 : commentid, touid, null);
                          }
                        }
                        else{
                          int temreplyid = await _gpService.updateCommentReply(commentid, widget.goodPiceModel.goodpriceid,  Global.profile.user!.uid,
                              Global.profile.user!.token!, touid, _message, "", errorCallBack);

                          if(temreplyid > 0){
                            _comments.forEach((e){
                              if(e.commentid == commentid){
                                if(e.replys == null ){
                                  e.replys = [];
                                }
                                e.replys!.add(CommentReply(temreplyid, commentid, Global.profile.user,
                                    touser, _message, DateTime.now().toString(), false, widget.goodPiceModel.goodpriceid, false, "", "", 0, ""));
                              }
                            });
                            sortComment(_comments, _ordertype);

                            setState(() {

                            });
                          }
                          else{
                            errorHandle(commentid == null ? 0 : commentid, touid, touser);
                          }
                        }
                      }
                      else {
                        ShowMessage.showToast('输入问题!');
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

  Future<void> evaluateLike(int evaluateid, int touid) async {
    bool ret = await _activityService.updateEvaluateLike(evaluateid, Global.profile.user!.uid,
        Global.profile.user!.token!, touid, "", errorCallBack);

    if(ret){
      _evaluates.forEach((e){
        if(e.evaluateid == evaluateid){
          e.likeuid = Global.profile.user!.uid;
          e.likenum = e.likenum! + 1;
        }
      });
      setState(() {

      });
    }
  }

  Future<void> delevaluateLike(int evaluateid, int touid) async {
    bool ret = await _activityService.delEvaluateLike(evaluateid, Global.profile.user!.uid,
        Global.profile.user!.token!, touid, errorCallBack);

    if(ret){
      _evaluates.forEach((e){
        if(e.evaluateid == evaluateid){
          e.likeuid = 0;
          e.likenum = e.likenum! - 1;
        }
      });

      setState(() {

      });
    }
    else{
      ShowMessage.showToast(error);
    }
  }

  Future<void> delMessage(String token, int uid, int commentid, String goodpriceid) async {
    bool ret = await _gpService.delMessage(token, uid, commentid,  goodpriceid, errorCallBack);
    if(ret){
      _comments = await _gpService.getCommentList(goodpriceid, uid, errorCallBack);
      setState(() {

      });
    }
    else{
    }
  }

  delReplyMessage(String token, int uid, int replyid, String goodpriceid) async {
    bool ret = await _gpService.delMessageReply(token, uid, replyid,  goodpriceid, errorCallBack);
    if(ret){
      _comments = await _gpService.getCommentList(goodpriceid, uid, errorCallBack);
      setState(() {

      });
    }
    else{
    }
  }

  List<Comment> sortComment(List<Comment> comments, String ordertype){
    if(ordertype == "0")
      comments.sort((a, b) => (b.createtime!).compareTo(a.createtime!));
    else{
      comments.sort((a, b) => (b.likenum!).compareTo(a.likenum!));
    }
    return comments;
  }

  List<Widget> getImageList(String imagepaths){
    List<String> paths = imagepaths.split(',');
    List<Widget> images = [];
    paths.map((e){
      images.add(ClipRRectOhterHeadImageContainerByBigImg(imageUrl: e.toString(), pagewidth: 200,));
    }).toList();

    return images;
  }

  errorCallBack(String statusCode, String msg) {
    error = msg;
    errorstatusCode = statusCode;
  }

  errorHandle(int commentid, int touid, User? touser){
    if(errorstatusCode != "200"){
      if(errorstatusCode == "-1008"){
        loadingBlockPuzzle(context, commentid: commentid, touid: touid, touser: touser!);
      }
      else {
        ShowMessage.showToast(error);
      }
    }
  }

  Future<void> commentLike(int commentid, int uid, String token, int touid, String goodpriceid) async {
    bool ret = await _gpService.updateCommentLike(commentid, uid, token, touid, goodpriceid, errorCallBack);
    if(ret){
      //List<Comment> listComments = await _activityService.getCommentList(event.actid, event.user.uid, errorCallBack);
      _comments.forEach((e){
        if(e.commentid == commentid){
          e.likeuid = uid;
          e.likenum = e.likenum! + 1;
        }
      });
    }
    setState(() {
      _isCommentLike = true;
    });
  }

  delCommentLike(int commentid, int uid, String token, int touid) async {
    bool ret = await _gpService.delCommentLike(commentid, uid, token, touid, errorCallBack);
    if(ret){
      //List<Comment> listComments = await _activityService.getCommentList(event.actid, event.user.uid, errorCallBack);
      _comments.forEach((e){
        if(e.commentid == commentid){
          e.likeuid = 0;
          e.likenum = e.likenum! - 1;
        }
      });

      setState(() {
        _isCommentLike = true;
      });
    }
  }

  //滑动拼图
  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true,int commentid=0, int touid=0, User? touser}) {
    showDialog<Null>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return BlockPuzzleCaptchaPage(
            onSuccess: (v) async {
              if(commentid == 0){
                commentid = await _gpService.updateMessage(widget.goodPiceModel.goodpriceid, Global.profile.user!.uid,
                    Global.profile.user!.token!, touid, _message, v, errorCallBack);
                if(commentid > 0){
                  _comments.insert(0, Comment(commentid, widget.goodPiceModel.goodpriceid, Global.profile.user, _message, 0,
                      CommonUtil.getTime(), 0));
                  sortComment(_comments, _ordertype);
                  setState(() {

                  });
                }
              }
              else{
                int temreplyid = await _gpService.updateCommentReply(commentid, widget.goodPiceModel.goodpriceid,  Global.profile.user!.uid,
                    Global.profile.user!.token!, touid, _message, v, errorCallBack);

                if(temreplyid > 0){
                  _comments.forEach((e){
                    if(e.commentid == commentid){
                      if(e.replys == null){
                        e.replys = [];
                      }
                      e.replys!.add(CommentReply(temreplyid, commentid, Global.profile.user,
                          touser, _message, DateTime.now().toString(), false, widget.goodPiceModel.goodpriceid, false, "", "", 0, ""));
                    }
                  });
                  sortComment(_comments, _ordertype);
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
                                  Navigator.pushNamed(context, '/ReportAllMessage', arguments: {"sourcetype": 8, "actid": commentid.toString(), "touid": touid, "content": content});
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
                                  Navigator.pushNamed(context, '/ReportAllMessage', arguments: {"sourcetype": 9, "actid": replyid.toString(), "touid": touid, "content": content});
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
                                onPressed: () async {
                                  await delMessage(Global.profile.user!.token!, Global.profile.user!.uid, commentid, widget.goodPiceModel.goodpriceid);
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
                                  delReplyMessage(Global.profile.user!.token!, Global.profile.user!.uid, replyid, widget.goodPiceModel.goodpriceid);
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

