import 'package:flutter/material.dart';

import '../../model/user.dart';
import '../../widget/circle_headimage.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../service/imservice.dart';
import '../../global.dart';

class MemberList extends StatefulWidget {
  Object? arguments;
  String cid = "";
  int status = 0;
  int reporttype = 0;


  MemberList({this.arguments}){
   this.cid = (arguments as Map)["cid"];
   this.status = (arguments as Map)["status"];
   this.reporttype = (arguments as Map)["reporttype"];
  }

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  ImService _imService = ImService();
  double pageheight = 0.0;
  ImHelper _imHelper = new ImHelper();
  List<User> members = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCommunityMember();
  }

  getCommunityMember() async {
    members = await _imService.getCommunityMemberList(widget.cid, 0);
    if(members != null && members.length > 0){
      if(mounted)
      setState(() {

      });
    }
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('群成员', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) async {
              if(result == "不看群消息"){
                if(widget.status == null || widget.status == 1 ) {
                  Navigator.pop(context, 2);
                }
                else{
                  Navigator.pop(context, 1);
                }
              }

              if(result == "删除并退出"){
                bool ret = await _imService.delQuitCommunity(widget.cid, Global.profile.user!.uid, Global.profile.user!.token!,
                        (String statusCode, String msg) {
                  ShowMessage.cancel();
                  ShowMessage.showToast(msg);
                });

                if(ret){
                  await _imHelper.delGroupRelation(widget.cid, Global.profile.user!.uid);
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              }

              if(result == "添加新成员"){
                if(members != null && members.length > 0) {
                  String oldmembers = "";
                  members.forEach((element) {
                    oldmembers += element.uid.toString() + ",";
                  });
                  oldmembers.substring(0, oldmembers.length - 1);

                  Navigator.pushNamed(context, '/JoinCommunity',
                      arguments: {"timeline_id": widget.cid,
                        "reporttype": widget.reporttype, "oldmembers": oldmembers}).then((value){
                          getCommunityMember();
                  });
                }
                else{
                  ShowMessage.showToast("原成员获取失败，请返回重试。");
                }
              }
            },
            icon: Icon(Icons.more_horiz, color: Colors.black,size: 18,),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: "不看群消息",
                child: widget.status == null || widget.status == 1 ? Text("屏蔽群消息", style: TextStyle(color: Colors.black87, fontSize: 14),) :
                Text("取消屏蔽群消息", style: TextStyle(color: Colors.black87, fontSize: 14),),
              ),
              PopupMenuItem<String>(
                value: "删除并退出",
                child: Text('删除并退出', style: TextStyle(color: Colors.black87, fontSize: 14),),
              ),
              PopupMenuItem<String>(
                value: "添加新成员",
                child: Text('添加新成员', style: TextStyle(color: Colors.black87, fontSize: 14),),
              ),
            ],
          ),
        ],
      ),
      body: buildNewMemberList(),
    );
  }

  //删除并退出
  Widget buildDelAndQuit(){
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () async {
          bool ret = await _imService.delQuitCommunity(widget.cid, Global.profile.user!.uid, Global.profile.user!.token!,
                  (String statusCode, String msg) {
            ShowMessage.cancel();
            ShowMessage.showToast(msg);
          });
          if(ret){
            await _imHelper.delGroupRelation(widget.cid, Global.profile.user!.uid);
            Navigator.pop(context);
            Navigator.pop(context);
          }
          //类型等于1是修改昵称,0修改个人简介
        },
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("删除并退出", style: TextStyle(color: Global.profile.backColor, fontSize: 14),),
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

          //类型等于1是修改昵称,0修改个人简介
        },
        title: InkWell(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                widget.status == null || widget.status == 1 ? Text("屏蔽群消息", style: TextStyle(color: Colors.black87, fontSize: 14),) :
                Text("取消屏蔽群消息", style: TextStyle(color: Colors.black87, fontSize: 14),),
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

  Widget buildNewMemberList(){
    return members != null ? ListView(
      children:  buildMemberList(members)
    ): SizedBox();
  }

  List<Widget> buildMemberList(List<User> members){
    List<Widget> widgets = [];
    widgets.add(SizedBox(height: 10,));
    members.forEach((element) {
        widgets.add(
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, top: 0),
              child: Card(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),  //设置圆角
                elevation: 0,
                child: ListTile(
                  onTap: () {
                    if(Global.profile.user == null) {
                      Navigator.pushNamed(context, '/OtherProfile',
                          arguments: {"uid": element.uid});
                    }
                    else if(element.uid != Global.profile.user!.uid){
                      Navigator.pushNamed(context, '/OtherProfile',
                          arguments: {"uid": element.uid});
                    }
                    else{
                      Navigator.pushNamed(context, '/MyProfile');
                    };

                  },
                  title: Padding(
                    padding: EdgeInsets.only(top: 5,bottom: 3),
                    child: Text(element.username, style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        element.signature == null ? 'Ta很神秘' : element.signature,
                        maxLines: 2,style: TextStyle(color: Colors.black54, fontSize: 12, ),),
                      SizedBox(height: 3,),
                    ],
                  ),
                  leading: NoCacheCircleHeadImage(
                      imageUrl: element.profilepicture == null ? Global.profile.profilePicture! :
                      element.profilepicture!, width: 50, uid: element.uid,),
                  trailing: element.uid == Global.profile.user!.uid ? SizedBox() : Container(
                    height: 36,
                    child: FlatButton (
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      color: Global.profile.backColor,
                      child: Text('删除', style: TextStyle(color: Colors.white, fontSize: 14)),
                      onPressed: () async {
                        await _asked(element);
                      },
                    ),
                  ),
                ),
              ),
            )
        );
//      }
    });
    return widgets;
  }

  void errorCallBack(String statusCode, String msg){
    ShowMessage.showToast(msg);
  }

  Future<void> _asked(User member) async {
    String msg = "确认要删除吗?";

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
                  bool ret = await _imService.delCommunityMember(Global.profile.user!.token!, Global.profile.user!.uid,
                      widget.cid, member.uid, errorCallBack);
                  if(ret){
                    members.remove(member);
                    setState(() {

                    });
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

}
