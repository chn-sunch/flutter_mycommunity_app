import 'package:flutter/material.dart';

import '../../model/user.dart';
import '../../model/activity.dart';
import '../../util/imhelper_util.dart';
import '../../common/iconfont.dart';
import '../../widget/icontext.dart';
import '../../widget/shareview.dart';
import '../../service/activity.dart';
import '../../global.dart';
import 'widget/photoviewgallery.dart';

class MyActivity extends StatefulWidget{
  final User user;
  bool isScroll;
  bool isAppbar;//是否有appbar的页面，默认是在个人主页中使用的无appbar
  Function? srollChange;
  MyActivity({required this.user, this.isScroll = false, this.srollChange, this.isAppbar=false}){

  }

  @override
  _MyActivityState createState() => _MyActivityState();
}

class _MyActivityState extends State<MyActivity>  with  AutomaticKeepAliveClientMixin  {
  List<Activity> activitys = [];
  ActivityService _activityService = new ActivityService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getActivityList();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  bool get wantKeepAlive => true;

  void _getActivityList() async {
    activitys = await _activityService.getActivityListByUser(0, widget.user.uid);;

    if(mounted)
      setState(() {

      });
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: buildContent(),
    );
  }

  Widget buildContent(){
    return Padding(padding: EdgeInsets.only(top: 3), child: activitys.length == 0 ?
    Center(child: Text('还没有组织过活动', style:  TextStyle(color: Colors.black54, fontSize: 14, )),) : Container(
        color: Colors.white,
        child: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Container(
              child: ListView.builder(
                addAutomaticKeepAlives: true,
                itemBuilder: (BuildContext context, int index) {
                  return ActivityWidget(activity: activitys[index]);
                },
                itemCount: activitys.length,
              ),
            )
        )),);
  }
}


class ActivityWidget extends StatefulWidget {
  final Activity activity;

  ActivityWidget({required this.activity});

  @override
  _ActivityWidgetState createState() => _ActivityWidgetState(activity);
}

class _ActivityWidgetState extends State<ActivityWidget> {
  Activity _activity;
  bool retLike = false;
  ImHelper _imHelper = new ImHelper();
  final ActivityService _activityService = new ActivityService();
  _ActivityWidgetState(this._activity);
  bool isEnter = true;

  @override
  initState(){
    if(Global.profile.user != null){
      _imHelper.selActivityState(this._activity.actid, Global.profile.user!.uid, (List<String> actid){
        if(actid.length > 0){
          setState(() {
            retLike = true;
          });
        }
        else{
          retLike = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> lists = [];

    if(_activity.actimagespath != null && _activity.actimagespath!.isNotEmpty){
      List<String> paths = _activity.actimagespath!.split(',');
      for(int i=0;i<paths.length;i++){
        lists.add({"tag": UniqueKey().toString(),"img": paths[i].toString()});
      }
    }
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_activity.createtime!, style: TextStyle(color: Colors.black45, fontSize: 13),),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 5),),
          InkWell(
            child: Container(
              width: double.infinity,
              child: Text(_activity.content, style: TextStyle(color: Colors.black87, fontSize: 13),),
            ),
            onTap: (){
              Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": _activity.actid});
            },
          ),
          Padding(padding: EdgeInsets.only(top: 5),),
          lists.length == 0 ? SizedBox.shrink() : MyPhotoViewGallery(list: lists),
          Padding(padding: EdgeInsets.only(top: 10),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShareView(icon: Icon(IconFont.icon_iconfontfenxiang, color: Colors.black45, size: 16,), image: _activity.coverimg, contentid: _activity.actid,
                content: _activity.content, sharedtype: "0", actid: _activity.actid, createuid: _activity.user!.uid,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconText(
                    _activity.likenum.toString() == "0" ? '点赞':_activity.likenum.toString(),
                    padding: EdgeInsets.only(right: 2),
                    style: TextStyle(color: Colors.black45, fontSize: 13),
                    icon: retLike ? Icon(IconFont.icon_zan1, color: Global.profile.backColor,size: 16,): Icon(IconFont.icon_aixin, color: Colors.black45,size: 16,),
                    onTap: () async {
                      if(isEnter) {
                        isEnter = false;
                        bool ret = false;
                        if (retLike) {
                          ret = await _activityService.delLike(
                              _activity.actid,
                              Global.profile.user!.uid,
                              Global.profile.user!.token!, () {});
                          _activity.likenum -= 1;
                          retLike = false;
                        }
                        else {
                          ret = await _activityService.updateLike(
                              _activity.actid,
                              Global.profile.user!.uid,
                              Global.profile.user!.token!, () {});
                          _activity.likenum += 1;
                          retLike = true;
                        }
                        if (ret) {
                          isEnter = true;
                          setState(() {});
                        }
                      }
                    },
                  ),
                  SizedBox(width: 20,),
                  IconText(
                    _activity.commentnum.toString() == "0" ? '评论' : _activity.commentnum.toString(),
                    padding: EdgeInsets.only(right: 2),
                    style: TextStyle(color: Colors.black45, fontSize: 13),
                    icon: Icon(IconFont.icon_navbar_xiaoxi, color: Colors.black45, size: 16,),
                    onTap: (){
                      Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": _activity.actid});
                    },
                  ),
                ],
              )

            ],
          ),
        ],
      ),
    );
  }
}


