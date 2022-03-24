import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/user.dart';
import '../../util/common_util.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../service/userservice.dart';
import '../../widget/circle_headimage.dart';
import '../../global.dart';

class OtherFollowUser extends StatefulWidget {
  Object? arguments;
  late int uid;
  OtherFollowUser({this.arguments}){
    uid = (arguments as Map)["uid"];
  }

  @override
  _OtherFollowUserState createState() => _OtherFollowUserState();
}

class _OtherFollowUserState extends State<OtherFollowUser> {
  double pageheight = 0.0;
  List<User> users = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  UserService _userService = new UserService();
  bool _ismore = true;
  ImHelper imHelper = new ImHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _getFollowList() async {
    users = await _userService.getFollowUsersCommunity(widget.uid, 0);
    _refreshController.refreshCompleted();
    if(mounted)
      setState(() {

      });
  }

  void _onLoading() async{
    if(!_ismore) return;
    final moredata = await _userService.getFollowUsersCommunity(Global.profile.user!.uid, users.length);

    if(moredata.length > 0)
      users = users + moredata;

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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pageheight = MediaQuery.of(context).size.height - 150;
    return Scaffold(
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('关注的人', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: users.length >= 25,
        onRefresh: _getFollowList,
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
        child: _refreshController.headerStatus == RefreshStatus.completed && users.length == 0 ? Center(
          child: Text('还没有关注其他人',
            style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
        ) : ListView(
          addAutomaticKeepAlives: true,
          children: buildMemberList(),
        ),
      ),
    );
  }

  List<Widget> buildMemberList(){
    List<Widget> widgets = [];
    widgets.add(SizedBox(height: 10,));
    users.forEach((element) {
      if(element.uid == widget.uid){
        widgets.add(SizedBox.shrink());
      }
      else {
        String tem = element.isFollow ? "已关注" : " ＋ 关注";
        widgets.add(
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, top: 0),
              child: Card(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),  //设置圆角
                elevation: 0,
                child: ListTile(
                  onTap: () {
                    if(Global.profile.user != null && Global.profile.user!.uid == element.uid){
                      Navigator.pushNamed(context, '/MyProfile');
                    }
                    else {
                      Navigator.pushNamed(context, '/OtherProfile',
                          arguments: {"uid": element.uid});
                    }
                  },
                  title: Padding(
                    padding: EdgeInsets.only(top: 5,bottom: 3),
                    child: Text(element.username, style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        element.signature == null || element.signature == "" ? 'Ta很神秘' : element.signature,
                        maxLines: 2,style:  TextStyle(color: Colors.black87, fontSize: 12),),
                      SizedBox(height: 3,),
                      Text(
                        '有${CommonUtil.getNum(int.parse(element.likenum.toString()))}个赞', style: TextStyle(color: Colors.black54, fontSize: 12, ),),
                      SizedBox(height: 5,)

                    ],
                  ),
                  leading: NoCacheCircleHeadImage(
                      imageUrl: element.profilepicture == null ? Global.profile
                          .profilePicture! : element.profilepicture!, width: 50, uid: element.uid,),
                  // trailing: Global.profile.user != null && Global.profile.user!.uid == element.uid ? SizedBox.shrink() : Container(
                  //   height: 36,
                  //   child: OutlineButton (
                  //     shape:  RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.all(Radius.circular(10))),
                  //     borderSide: BorderSide(
                  //       color: element.isFollow ?  Colors.grey.shade200 :Global.profile.backColor!,
                  //     ),
                  //     color: element.isFollow ? Colors.grey.shade200 : Global.profile.backColor,
                  //     child: Text(tem, style: TextStyle(color: element.isFollow ? Colors.black54 : Global.profile.backColor, fontSize: 14)),
                  //     onPressed: () async {
                  //       if (element.isFollow) {
                  //         bool ret = await _userService.cancelFollow(Global.profile.user!.token!, Global.profile.user!.uid, element.uid, errorCallBack);
                  //         if(ret) {
                  //           await imHelper.delFollowState(element.uid, Global.profile.user!.uid);
                  //           Global.profile.user!.following = Global.profile.user!.following! - 1;
                  //           Global.saveProfile();
                  //           element.isFollow = false;
                  //           setState(() {
                  //
                  //           });
                  //         }
                  //       }
                  //       else {
                  //         bool ret = await _userService.Follow(Global.profile.user!.token!, Global.profile.user!.uid, element.uid, errorCallBack);
                  //         if(ret) {
                  //           await imHelper.delFollowState(element.uid, Global.profile.user!.uid);
                  //           await imHelper.saveFollowState(element.uid, Global.profile.user!.uid);
                  //           Global.profile.user!.following = Global.profile.user!.following! + 1;
                  //           Global.saveProfile();
                  //           element.isFollow = true;
                  //
                  //           setState(() {
                  //
                  //           });
                  //         }
                  //       }
                  //     },
                  //   ),
                  // ),
                ),
              ),
            )
        );
      }
    });
    return widgets;
  }


  errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}
