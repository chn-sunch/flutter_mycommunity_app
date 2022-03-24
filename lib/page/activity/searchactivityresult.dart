import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../global.dart';
import '../../model/activity.dart';
import '../../util/common_util.dart';
import '../../util/imhelper_util.dart';
import '../../util/showmessage_util.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/shareview.dart';
import '../../service/activity.dart';

class SearchActivityResultPage extends StatefulWidget {
  Object? arguments;
  String content = "";
  SearchActivityResultPage({this.arguments}){
    if(arguments != null) {
      content = (arguments as Map)["content"];
    }
  }

  @override
  _SearchActivityResultPageState createState() => _SearchActivityResultPageState();
}

class _SearchActivityResultPageState extends State<SearchActivityResultPage> {
  final ActivityService _activityService = new ActivityService();
  late TextEditingController _textEditingController;
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  final ImHelper _imHelper = new ImHelper();
  SearchBarStyle searchBarStyle = const SearchBarStyle();
  Icon icon = const Icon(Icons.search, size: 20, color: Colors.black87);
  String ordertype = "time";
  String citycode = Global.profile.locationCode;
  bool isAllCity = false;
  bool _ismore = true;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  double _activityContentHeight = 1.0;//瀑布组件高度
  double _leftHeight = 0;//左边列的高度
  double _rigthHeight = 0;//右边列的高度
  double _contentText = 99;//图片下面的文字描述与间距
  double _pageWidth = 0;
  List<Activity> activitys = [];

  Widget widgetMessage = Center(child: Text('没搜索到你想要的活动', style: TextStyle(color: Colors.black54, fontSize: 15),));

  @override
  void initState() {
    // TODO: implement initState
    _onRefresh();
    super.initState();
    _textEditingController = TextEditingController.fromValue(TextEditingValue(
        text: widget.content,
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: widget.content.length)))
    );
    if(citycode == null || citycode.isEmpty)
      citycode = "allCode";
    _imHelper.saveSearchHistory(0, widget.content);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textEditingController.dispose();
  }

  void _onRefresh() async{

    activitys = await  _activityService.searchActivity(
        ordertype, citycode, 0, isAllCity, widget.content, errorCallBack);

    if(activitys.length < 25){
      _ismore = false;
    }

    _refreshController.refreshCompleted();
    if(mounted)
    setState(() {

    });
  }

  void _onLoading() async{
    if(!_ismore) return;

    final moredata = await  _activityService.searchActivity(
        ordertype, citycode, activitys.length, isAllCity, widget.content, errorCallBack);

    if(moredata.length > 0)
      activitys = activitys + moredata;

    if(moredata.length >= 25)
      _refreshController.loadComplete();
    else{
      _ismore = false;
      _refreshController.loadNoData();
    }

    if(mounted)
      setState(() {

      });
  }

  @override
  Widget build(BuildContext context) {
    _pageWidth = MediaQuery.of(context).size.width / 2 -8;

    return Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          titleSpacing: 0,
          leading: SizedBox.shrink(),
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          title:Padding(
              padding: EdgeInsets.only(right: 10, top: 10),
              child: Container(
                height: 46,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.arrow_back_ios, size: 18, color: Colors.black87,), onPressed: (){
                        Navigator.pop(context);
                      },),
                      Expanded(
                          child:  InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: searchBarStyle.borderRadius,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child:  TextField(
                                  controller: _textEditingController,
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  style: TextStyle(color: Colors.black87, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: widget.content,
                                    hintStyle: TextStyle(color: Colors.black87, fontSize: 14),
                                    border: InputBorder.none,
                                    icon: icon,
                                  ),
                                ),
                              ),
                            ),
                            onTap: (){
                            },
                          )
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(left: 20, right: 10),
                          alignment: Alignment.centerLeft,
                          color: Colors.transparent,
                          child: Text("取消", style: TextStyle(color: Colors.black87, fontSize: 14),),
                        ),
                        onTap: (){
                          Navigator.pop(context);
                        },
                      )
                    ]
                ),
              )
          ),
        ),
        body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: activitys.length >= 25,
            onRefresh: _onRefresh,
            header: MaterialClassicHeader(distance: 100, ),
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
            child: activitys.length == 0 && _refreshController.headerStatus == RefreshStatus.completed ? widgetMessage : ListView(
                addAutomaticKeepAlives: true,
                children: buildContent()
            )
        ));
  }

  //内容
  List<Widget> buildContent() {
    List<Widget> contents = [];


    if (activitys != null && activitys.length != 0 ) {
      contents.add(indexPageView(activitys)) ;
    }
    return contents;
  }

  Widget indexPageView(List<Activity> activitys){
    _getContentHeight(activitys);
    return Container(
      height: _activityContentHeight,
      child: activityContent(activitys),
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
    _activityContentHeight = (_leftHeight >= _rigthHeight ? _leftHeight : _rigthHeight) +  0;//最后取左右两边的最大值作为瀑布组件的高,再加上分类的高
  }
  //计算图片高度和宽度
  double getImageWH(Activity activity){
    double retheight = 200;
    if(activity.coverimgwh.split(',').length > 1){
      double width = double.parse(activity.coverimgwh.split(',')[0]);
      double height = double.parse(activity.coverimgwh.split(',')[1]);
      double ratio = width/height;//宽高比
      retheight = (_pageWidth) / ratio;
      if(retheight > 200)
        retheight=200;
    }
    else
      retheight = 0;
    return retheight; //图片缩放高度
  }

  Widget activityContent(List<Activity> activitys){

    return  StaggeredGridView.countBuilder(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 0),
      addAutomaticKeepAlives:true,
      primary: false,
      shrinkWrap: false,
      crossAxisCount: 2,
      mainAxisSpacing: 0.0,
      crossAxisSpacing: 0.0,
      itemCount: activitys.length,
      itemBuilder: (BuildContext context, int index){
        return index > activitys.length ? buildLoading() :
        (index == activitys.length ? SizedBox.shrink() :buildActivityItem(activitys[index], activitys) );
      },
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
  }
  //加载中图标
  Widget buildLoading(){
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
          ),
        ),
      ),);
  }
  //瀑布流内容
  Widget buildActivityItem(Activity activity, List<Activity> temActivitys){

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
              child:  activity.coverimg == "" ? SizedBox.shrink() : ClipRRect(
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
                    color: Colors.black,
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
            ) ,
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

  errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}

class SearchBarStyle {
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const SearchBarStyle(
      {this.backgroundColor = const Color.fromRGBO(142, 142, 147, .15),
        this.padding = const EdgeInsets.all(5.0),
        this.borderRadius: const BorderRadius.all(Radius.circular(5.0))});
}
