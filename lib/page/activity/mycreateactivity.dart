import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/activity.dart';
import '../../service/activity.dart';
import '../../global.dart';
import '../../widget/circle_headimage.dart';

class MyCreateActivity extends StatefulWidget {
  @override
  _MyCreateActivityState createState() => _MyCreateActivityState();
}

class _MyCreateActivityState extends State<MyCreateActivity> with AutomaticKeepAliveClientMixin{
  ActivityService _activityService = ActivityService();
  List<Activity> _activityMyList = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  bool _ismore = true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMyActivity();
  }

  _getMyActivity() async {
    _activityMyList = await _activityService.getAllActivityListByUserCount5(0, Global.profile.user!.uid,
        Global.profile.user!.token!);

    if(_activityMyList.length < 25){
      _ismore = false;
    }

    _refreshController.refreshCompleted();

    if (mounted){
      setState(() {

      });
    }
  }

  _onLoading() async{
    if(!_ismore) return;

    final moredata = await _activityService.getAllActivityListByUserCount5(_activityMyList.length, Global.profile.user!.uid,
        Global.profile.user!.token!);



    if(moredata.length > 0)
      _activityMyList = _activityMyList + moredata;

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
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('我发布的活动', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 1),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: _activityMyList.length >= 25,
          onRefresh: _getMyActivity,
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
              return Container(
                height: 55.0,
                child: Center(child:body),
              );
            },
          ),
          controller: _refreshController,
          onLoading: _onLoading,
          child: _refreshController.headerStatus == RefreshStatus.completed && _activityMyList.length == 0 ? Center(
            child: Text('你还没发布过活动',
              style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
          ) : buildActivityList(),
        ),
      ),
    ) ;
  }

  Widget buildActivityList(){
    Widget ret = SizedBox.shrink();
    List<Widget> lists = [];

    if(_activityMyList != null && _activityMyList.length > 0){
      _activityMyList.forEach((e) {
        lists.add(Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            children: [
              InkWell(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            e.coverimg != null && e.coverimg != "" ? ClipRRectOhterHeadImageContainer(imageUrl: e.coverimg!,  width: 109, height: 109, cir: 9,) : SizedBox.shrink(),
                            e.coverimg != null && e.coverimg != "" ? SizedBox(width: 10,) : SizedBox.shrink(),
                            Expanded(
                                child: Container(
                                  height: e.coverimg != null && e.coverimg != "" ? 119 : 80,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(child: Text(e.content, overflow: TextOverflow.ellipsis,maxLines: e.coverimg != null && e.coverimg != "" ? 3:2, style: TextStyle(color: Colors.black87, fontSize: 14),)),
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("￥", style: TextStyle( fontSize: 12, color: Colors.red),),
                                                    Text(e.mincost.toString(), style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),),
                                                    // e.maxcost > 0 ? Text('-', style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),):SizedBox.shrink(),
                                                    // e.maxcost > 0 ? Text(e.maxcost.toString(), style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),):SizedBox.shrink(),
                                                    Text("元", style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": e.actid});
                },
              ),
            ],
          ),
          decoration: new BoxDecoration(//背景
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            //设置四周边框
          ),
        ));
        lists.add(Container(height: 9, color: Colors.grey.shade200,));
      });


      ret = ListView(

        children: lists,
      );
    }
    else{
      ret = Center(
        child: Text('还没有创建过活动', style: TextStyle(color: Colors.black54, fontSize: 14, )),
      );
    }

    return ret;
  }
}
