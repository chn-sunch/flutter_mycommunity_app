import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../common/iconfont.dart';
import '../../bloc/activity/activity_data_bloc.dart';
import '../../widget/shareview.dart';
import '../../widget/circle_headimage.dart';
import '../../model/activity.dart';
import '../../util/showmessage_util.dart';
import '../../util/common_util.dart';
import '../../util/imhelper_util.dart';
import '../../global.dart';

class Recommend extends StatefulWidget {
  bool isPop;//是否从其他页面pop回来
  final Function? parentJumpShop;

  Recommend({Key? key,   this.isPop = false, this.parentJumpShop}) : super(key: key);
  @override
  _RecommendState createState() => _RecommendState();
}

class _RecommendState extends State<Recommend> with  AutomaticKeepAliveClientMixin {

  ScrollController _scrollControllerContent = new ScrollController(initialScrollOffset: 0);
  final ImHelper _imHelper = new ImHelper();
  var _loadstate = 0;
  double _activityContentHeight = 1.0;//瀑布组件高度
  double _categoryBarHeight=50.0;
  double _pageWidth = 0;
  double _leftHeight = 0;//左边列的高度
  double _rigthHeight = 0;//右边列的高度
  double _contentText = 88;//图片下面的文字描述与间距
  double _scrollThreshold = 100;
  bool _lock = false;//防止滚动条多次执行加载更多
  double _lastScroll = 0.0;
  bool _isTop = false;
  late ActivityDataBloc _activityBloc;


  String temcitycode = "";

  @override
  void initState() {
    super.initState();
    _activityBloc = BlocProvider.of<ActivityDataBloc>(context);

    temcitycode = Global.profile.locationCode;
    if(widget.isPop){
      _activityBloc.add(Refresh());
    }
    _scrollControllerContent.addListener(() {
      final maxScroll = _scrollControllerContent.position.maxScrollExtent;
      double currentScroll = _scrollControllerContent.position.pixels;
      if(currentScroll < _lastScroll){
        if (mounted) {
          setState(() {
            if (currentScroll == 0) {
              _isTop = false;
            }
            else
              _isTop = true;
          });
        }
      }
      else{
        if (mounted) {

          setState(() {
            _isTop = false;
          });
        }
      }


      _lastScroll = currentScroll;
      if (maxScroll - currentScroll <= _scrollThreshold && !_lock) {
        _activityBloc.add(Fetch());
        _lock = true;//加载完毕后再解锁
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() { // 生命周期函数
    _scrollControllerContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);//页面不会被
    //iphone11 pro max分辨率
    _pageWidth = MediaQuery.of(context).size.width / 2 -8;
    //初始化读取GLOBAL.location地址比较慢，默认是"",location获取到之后会刷新一次
    if(Global.profile.locationCode != temcitycode) {
      _activityBloc.add(Refresh());
      temcitycode = Global.profile.locationCode;
    }
    return BlocListener<ActivityDataBloc, ActivityDataState>(
        listener: (context, state) {
          if (state is UpdateHome) {
            _activityBloc.add(Refresh());
          }
        },

        child: Scaffold(
          floatingActionButton: _isTop? FloatingActionButton(
              mini: true,
              heroTag: UniqueKey(),
              backgroundColor: Colors.white,
              onPressed: (){
                _scrollControllerContent.jumpTo(0);
                setState(() {
                  _isTop = false;
                });
              },
              child: Icon(IconFont.icon_rocket, color: Colors.black45,)) : SizedBox.shrink(),
          body: BlocBuilder<ActivityDataBloc, ActivityDataState>(
              builder: (context, state){
                if(state is PostLoading )
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                    ),
                  );
                if(state is PostUninitedError) {
                  ShowMessage.showToast("请检查网络，再试一下!");
                  return reLoadData();
                }
                if(state is PostLoaded) {
                  if (state.activitys == null || state.activitys!.isEmpty) {
                    return InkWell(
                      child: Column(
                        children: [
                          Expanded(child: Align(
                            alignment: Alignment.center,
                            child: Text('emmm...这里还没有活动.',
                              style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
                          ),),
                        ],
                      ),
                      onTap: (){
                        _activityBloc.add(Refresh());
                      },
                    );
                  }

                  if(state.error != null && state.error!) {
                    this._lock = false; //加载完;毕后解锁，允许再次加载
                    ShowMessage.showToast("网络不给力，请再试一下!");
                  }

                  return buildPageView(state.activitys!, state);
                }
                if(state is PostUninitialized ){
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                    ),
                  );;
                }

                return Center(
                    child: CircularProgressIndicator(
                    valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                ));
              }),
        )
    );
  }

  ///1.刷新  2.加载更多
  Widget reLoadData(){
    return InkWell(
      child: Center(
        child: Text('轻触重试', style: TextStyle(color: Colors.black54, fontSize: 15),),
      ),
      onTap: (){
          _activityBloc.add(Refresh());
      },
    );
  }

  Widget buildPageView(List<Activity> activitys, PostLoaded state){
    _getContentHeight(activitys);

    Widget maxWidget = SizedBox.shrink();
    if(state is PostLoaded){
      if(state.hasReachedMax!){
        //如果已经最大增加一个刷新按钮
        maxWidget = InkWell(
          child: Container(
            margin: EdgeInsets.only(bottom: 60),
            padding: EdgeInsets.only(top: 30),
            alignment: Alignment.bottomCenter,
            child: Text('—————— 我也是有底线的 ——————', style: TextStyle(color: Colors.black45, fontSize: 13), ),
          ),
          onTap: (){
            _isTop = false;
            _scrollControllerContent.jumpTo(0);
            if(activitys!= null && activitys.length < 4) {
              _activityBloc.add(Refresh());
            }

          },
        );
      }
    }
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: Global.profile.backColor,
      onRefresh: ()async {
        _activityBloc.add(Refresh());
      },
      child:  Column(
        children: [
          Expanded(
              child: CustomScrollView(
                  controller: _scrollControllerContent,
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Container(
                              height: _activityContentHeight,
                              child: buildActivityContent(activitys, state),
                            )
                          ],
                        )
                    ),
                    SliverToBoxAdapter(
                      child: maxWidget,
                    )

                  ]
              )
          ),
        ],
      ),
    );
  }

  //Activitycontent
  Widget buildActivityContent(List<Activity> activitys, PostLoaded state){
    if(activitys.length == 0)
      return Center(child: Image.asset('images/26074001_bzCh.gif'),);

    return  StaggeredGridView.countBuilder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 3),
        addAutomaticKeepAlives:true,
        primary: false,
        shrinkWrap: false,
        crossAxisCount: 2,
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        itemCount: state.hasReachedMax! ? state.activitys!.length : state.activitys!.length + 1,
        itemBuilder: (BuildContext context, int index){
          if(index == activitys.length) {
            this._lock = false;//加载完毕后解锁，允许再次加载
          }
          return index > activitys.length ? buildLoading() : (index == activitys.length ? SizedBox.shrink() :buildActivityItem(activitys[index], _loadstate, activitys) );
        },
        staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
  }
  //瀑布流内容
  Widget buildActivityItem(Activity activity, int state, List<Activity> temActivitys){
    Widget widgetMoney = Row(
      children: [
        Text("￥", style: TextStyle(color: Colors.red, fontSize: 10),),
        Text(activity.mincost.toString(), style: TextStyle(color: Colors.red, fontSize: 12,fontWeight: FontWeight.bold),)
      ],
    );

    return ShareView(
      activityHomeLongPress: (bool isNotInterests) async {
        if(isNotInterests) {
          List<int> notinteresteduids = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
          List<Activity> emptyList = [];
          temActivitys.forEach((e) {
            emptyList.add(e);
          });

          emptyList.forEach((e) {
            if(notinteresteduids != null && notinteresteduids.contains(e.user!.uid)){
              temActivitys.remove(e);
            }
          });

          setState(() {
          });
        }
      },
      activityHomeOnTap: (){
        Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": activity.actid}).then((val){});
      },
      sharedtype: "0",
      actid: activity.actid,
      createuid: activity.user!.uid,
      contentid: activity.actid,
      content: activity.content,
      image: activity.coverimg,
      icon: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: _pageWidth,
              height: getImageWH(activity),
              child:  ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                  child: CachedNetworkImage(
                    imageUrl: '${activity.coverimg}?x-oss-process=image/resize,m_fixed,w_600/sharpen,50/quality,q_80',//缩放压缩
                    fit: BoxFit.cover,
                  )
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              ),
            ),
            Container(
              height: 42,

              padding: EdgeInsets.only(top: 5, left: 10, right: 5, bottom: 5),
              child: Text(
                activity.content,
                style: TextStyle(
                    fontSize: 12,
                    color: activity.user!.usertype == 99 ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
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
                    imageUrl: activity.user!.profilepicture!,
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
                  buildPeopleNum(activity),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  //获取参与人数
  Widget buildPeopleNum(Activity activity){
    return Row(
      children: <Widget>[
        Text(
          "${activity.joinnum! + 1}人想参加",
          style: TextStyle(
              fontSize: 12,
              color: Colors.black54
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
  //加载中图标
  Widget buildLoading(){
    return CircularProgressIndicator(
      valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
    );
  }

  //瀑布流内容高度
  void _getContentHeight(List<Activity> data){
    List<Activity> activitys = data;
    _rigthHeight = 0;
    _leftHeight = 0;
    for(int i=0; i<activitys.length; i++ ){
      if(_rigthHeight < _leftHeight){
        _rigthHeight += getImageWH(activitys[i]) + _contentText;
      }
      else{
        _leftHeight += getImageWH(activitys[i]) + _contentText;
      }
    }
    _activityContentHeight = (_leftHeight >= _rigthHeight ? _leftHeight : _rigthHeight) +  _categoryBarHeight;//最后取左右两边的最大值作为瀑布组件的高,再加上分类的高
  }
  //计算图片高度和宽度
  double getImageWH(Activity activity){
    double width = double.parse(activity.coverimgwh.split(',')[0]);
    double height = double.parse(activity.coverimgwh.split(',')[1]);
    double ratio = width/height;//宽高比
    double retheight = (_pageWidth) / ratio;
    if(retheight > 200)
      retheight=200;
    return retheight; //图片缩放高度
  }
}




