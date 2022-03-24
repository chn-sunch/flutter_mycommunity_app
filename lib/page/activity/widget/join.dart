import 'package:flutter/material.dart';

import '../../../model/activity.dart';
import '../../../service/activity.dart';
import '../../../global.dart';
import '../../../widget/circle_headimage.dart';

class FinishActivity extends StatefulWidget {
  @override
  _FinishActivityState createState() => _FinishActivityState();
}

class _FinishActivityState extends State<FinishActivity> with AutomaticKeepAliveClientMixin{
  ActivityService _activityService = ActivityService();

  List<Activity> _activityJoinList = [];
  int pagestatus = 0;//简单处理载入状态

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyActivity();
  }

  getMyActivity() async {
    _activityJoinList = await _activityService.getALLJoinActivityListByUserCount5(0, Global.profile.user!.uid, Global.profile.user!.token!);

    pagestatus = 1;
    if (mounted){
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: EdgeInsets.all(5.0),
      child: pagestatus == 0 ? Center(child: CircularProgressIndicator(
        valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
      )) : buildActivityList(),
    );
  }

  Widget buildActivityList() {
    Widget ret = SizedBox.shrink();
    List<Widget> lists = [];
    lists.add(SizedBox.shrink());
    if(_activityJoinList != null && _activityJoinList.length > 0){
      for(int i = 0; i < _activityJoinList.length; i++){
        Activity e = _activityJoinList[i];

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
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text("￥", style: TextStyle( fontSize: 12, color: Colors.red),),
                                                Text(e.mincost.toString(), style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),),
                                                // e.maxcost > 0 ? Text('-', style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),):SizedBox.shrink(),
                                                // e.maxcost > 0 ? Text(e.maxcost.toString(), style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),):SizedBox.shrink(),
                                                Text("元", style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),),
                                              ],
                                            ),

                                          ],
                                        ),
                                      ),
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
      }
      ret = ListView(
        children: lists,
      );
    }
    else{
      ret = Center(
        child: Text('还没有加入过其他活动', style:  TextStyle(color: Colors.black54, fontSize: 14, )),
      );
    }

    return ret;
  }
}
