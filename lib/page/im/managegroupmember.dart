import 'package:flutter/material.dart';

import '../../model/user.dart';
import '../../widget/circle_headimage.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../service/activity.dart';
import '../../global.dart';

class ManageActivityMember extends StatefulWidget {

  Object? arguments;
  List<User> members = [];
  String actid = "";
  ManageActivityMember({this.arguments}){
    members = (arguments as Map)["members"];
    for(int i = 0; i < members.length; i++){
      members[i].isFollow = false;
    }
    actid = (arguments as Map)["actid"];
  }


  @override
  _ManageActivityMemberState createState() => _ManageActivityMemberState();
}

class _ManageActivityMemberState extends State<ManageActivityMember> {
  ActivityService _activityService = new ActivityService();
  List<User> delMember = [];
  ImHelper _imHelper = new ImHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text('增减成员', style: TextStyle(color: Colors.black, fontSize: 16)),
          centerTitle: true,
        ),
        body: ListView(
          children: _memberList(),
        ),
        bottomNavigationBar: buildDelBtn()
    );
  }

  List<Widget> _memberList(){
    int index = 0;
    List<Widget> widgets = [];
    for(User item in widget.members){
      if(index == 0){
        // widgets.add(SizedBox.shrink());
      }
      else{
        widgets.add(
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: item.isFollow,
                      onChanged: ( value) {
                        setState(() {
                          item.isFollow = value!;
                          if(value){
                            delMember.add(item);
                          }
                          else{
                            delMember.remove(item);
                          }
                        });
                      },
                    ),
                    NoCacheClipRRectHeadImage(
                      width: 35,
                      uid: item.uid,
                      imageUrl: '${item.profilepicture}',
                    )
                  ],
                ),
                SizedBox(width: 10,),
                Expanded(child: Text(item.username, overflow: TextOverflow.ellipsis,)),
              ],
            ),
            onTap: (){
              setState(() {
                item.isFollow = !item.isFollow;
                if(item.isFollow){
                  delMember.add(item);
                }
                else{
                  delMember.remove(item);
                }
              });
            },
          )

        );
      }


      index++;
    }

    return widgets;
  }

  Widget buildDelBtn(){
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      height: 60,
      child: FlatButton(
        color: Colors.green,
        child: Text(
          '移除群成员',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: ()  {
          if(delMember != null && delMember.length > 0) {
            _asked();
          }
          else{
            ShowMessage.showToast('请选择要移除的成员!');
          }
        },
      ),
    );
  }

  Future<void> _asked() async {
    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('移除群成员后他们将无法收到消息，确定要移除吗?', style: new TextStyle(fontSize: 17.0)),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if(delMember != null && delMember.length > 0){
                    String uids = "";
                    delMember.forEach((element) {
                      uids += element.uid.toString() + ",";
                    });
                    uids = uids.substring(0, uids.length - 1);
                    bool ret = await _activityService.manageDelQuiteActivity(widget.actid, Global.profile.user!.uid, Global.profile.user!.token!, uids, (String statusCode, String msg) {
                      ShowMessage.cancel();
                      ShowMessage.showToast(msg);
                    });
                    if(ret){
                      await _imHelper.delGroupMemberRelation(delMember, widget.actid);
                      delMember.forEach((element) {
                        widget.members.remove(element);
                      });
                      setState(() {

                      });
                    }
                  }
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }
}