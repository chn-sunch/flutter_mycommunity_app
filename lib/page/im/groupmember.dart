import 'package:flutter/material.dart';

import '../../model/activity.dart';
import '../../model/user.dart';
import '../../widget/circle_headimage.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../service/activity.dart';
import '../../global.dart';

class GroupMember extends StatefulWidget {
  Object? arguments;
  String timeline_id = "";
  int status = 1;//群聊状态 1正常 2拉黑屏蔽
  int reporttype = 0;

  GroupMember({this.arguments}){
    timeline_id = (arguments as Map)["timeline_id"];
    status = (arguments as Map)["status"];
    reporttype = (arguments as Map)["reporttype"];
  }

  @override
  _State createState() => _State();
}

class _State extends State<GroupMember> {
  ActivityService _activityService = new ActivityService();
  ImHelper _imHelper = new ImHelper();
  Activity? activity;
  String msg = "确定要退出聊天群吗?";

  List<User> _users = [];

  getAllUsers() async {
    activity = await _activityService.getActivityMember(widget.timeline_id,errorCallBack);
    if(activity != null ){
      setState(() {
        _users = activity!.members!;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text('群成员', style: TextStyle(color: Colors.black, fontSize: 16)),
          centerTitle: true,
        ),
        body:  _users.length == 0 ? Center(
            child: CircularProgressIndicator(
              valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
            )) : ListView(
            children: [
              Container(
                color: Colors.white,
                child: Wrap(
                  children: buildMemberList(),
                ),
              ),
              SizedBox(height: 10,),
              buildDelAndQuit(),
              activity!.user!.uid == Global.profile.user!.uid ? SizedBox(height: 5,): SizedBox.shrink(),
              activity!.user!.uid == Global.profile.user!.uid ? buildDelMember() : SizedBox.shrink(),
              SizedBox(height: 5,),
              buildBlackList(),
            ],
          )
    );
  }

  List<Widget> buildMemberList(){
    List<Widget> members = [];
    _users.map((item) {
        members.add(
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  NoCacheClipRRectHeadImage(
                    width: 45,
                    uid: item.uid,
                    imageUrl: '${item.profilepicture}',
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                  ),
                  Text(item.username.length > 4
                      ? '${item.username.substring(0, 3)}...'
                      : item.username,
                    style: TextStyle(color: Colors.black45, fontSize: 11, ),)
                ],
              ),
            )
        ) ;
      }
    ).toList();

    return members;
  }

  //删除并退出
  Widget buildDelAndQuit(){
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () async {
          await _asked();
        },
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("退出活动", style: TextStyle(color: Colors.redAccent, fontSize: 14),),
            ],
          ),
        ),
        //trailing: Icon(Icons.keyboard_arrow_right),
      ),
    );
  }

  //拉黑不在接收消息
  Widget buildBlackList(){
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () async {

        },
        title: InkWell(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                widget.status == null || widget.status == 1 ? Text("屏蔽消息", style: TextStyle(color: Colors.black87, fontSize: 14),) :
                Text("取消屏蔽消息", style: TextStyle(color: Colors.black87, fontSize: 14),),
              ],
            ),
          ),
          onTap: (){
            if(widget.status == null || widget.status == 1 ) {
              Navigator.pop(context, 2);
            }
            else{
              Navigator.pop(context, 1);
            }
          },
        ),
        //trailing: Icon(Icons.keyboard_arrow_right),
      ),
    );
  }

  Widget buildDelMember(){
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () async {

        },
        title: InkWell(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("增减成员", style: TextStyle(color: Colors.black87, fontSize: 14),),
              ],
            ),
          ),
          onTap: (){
            if(widget.status == null || widget.status == 1 ) {
              Navigator.pushNamed(context, '/ManageActivityMember', arguments: {"members": activity!.members, "actid": activity!.actid});
            }
          },
        ),
        //trailing: Icon(Icons.keyboard_arrow_right),
      ),
    );
  }


  Future<void> _asked() async {
    msg = "确定要退出聊天群吗?";

    showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(msg , style: new TextStyle(fontSize: 17.0)),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () async {
                  bool ret = await _activityService.delQuiteActivity(widget.timeline_id, Global.profile.user!.uid, Global.profile.user!.token!,(String statusCode, String msg) {
                    ShowMessage.cancel();
                    ShowMessage.showToast(msg);
                  });
                  if(ret){
                    int ret = await _imHelper.delGroupRelation(widget.timeline_id, Global.profile.user!.uid);
                    if(Global.isInDebugMode)
                      print(ret);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                  else{
                    Navigator.pop(context);
                  }
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }


  errorCallBack(String statusCode, String msg) {
    this.msg = msg;
    //ShowMessage.showToast(msg);
  }
}
