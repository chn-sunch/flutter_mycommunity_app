import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


import '../../model/activity.dart';
import '../../util/imhelper_util.dart';
import '../../global.dart';

class MyBrowHistory extends StatefulWidget {
  @override
  _MyBrowHistoryState createState() => _MyBrowHistoryState();
}

class _MyBrowHistoryState extends State<MyBrowHistory> {
  double _activityContentHeight = 1.0;//瀑布组件高度
  double _leftHeight = 0;//左边列的高度
  double _rigthHeight = 0;//右边列的高度
  double _contentText = 83;//图片下面的文字描述与间距
  double _pageWidth = 0;
  var _loadstate = 0;
  List<Activity> activitys = [];
  ImHelper imHelper = new ImHelper();

  RefreshController _refreshController = RefreshController(initialRefresh: true);
  bool _ismore = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pageWidth = MediaQuery.of(context).size.width / 2 -8;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('历史浏览', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 1),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: activitys.length >= 25,
          onRefresh: _getActivityList,
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
          child: _refreshController.headerStatus == RefreshStatus.completed && activitys.length == 0 ? Center(
            child: Text('还没有历史活动浏览记录',
              style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
          ) : ListView(
            addAutomaticKeepAlives: true,
            children: buildContent(),
          ),
        ),
      ),
    ) ;
  }

  void _getActivityList() async {
    activitys = await imHelper.getBrowseHistory(0, 25);

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

    final moredata =await imHelper.getBrowseHistory(activitys.length, activitys.length + 25);


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

  //内容
  List<Widget> buildContent() {
    List<Widget> contents = [];


    if (activitys != null && activitys.length != 0 ) {
      contents.add(indexPageView()) ;
    }

    return contents;
  }
  Widget indexPageView(){
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
    if(activitys.length == 0) {
      //return Center(child: Image.asset('images/26074001_bzCh.gif'),);
      return Center(child: Text('还没有活动', style: TextStyle(color: Colors.black54, fontSize: 15),));
    }
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
        if(index == activitys.length) {
        }
        return index > activitys.length ? buildLoading() :
        (index == activitys.length ? SizedBox.shrink() :buildActivityItem(activitys[index], _loadstate) );
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
  Widget buildActivityItem(Activity activity, int state){
    double temheight = getImageWH(activity);
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": activity.actid}).then((val){
        });
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            temheight != 0 ? Container(
              width: _pageWidth,
              height: temheight,
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
            ) : SizedBox.shrink(),
            Container(
              height: 37,
              padding: EdgeInsets.only(top: 5, left: 10),
              child: Text(
                activity.content ,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              height: 26,
              padding: EdgeInsets.only(left: 9, bottom: 5, right: 5, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(activity.user!.profilepicture!),
                    radius: 9,
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

}
