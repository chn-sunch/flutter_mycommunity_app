

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/user.dart';
import '../../service/userservice.dart';
import '../../service/imservice.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/my_divider.dart';
import '../../util/showmessage_util.dart';
import '../../global.dart';


class JoinCommunity extends StatefulWidget {
  Object? arguments;
  String timeline_id = "";
  String oldmembers = "";
  JoinCommunity({this.arguments}){
    timeline_id = (arguments as Map)["timeline_id"];
    oldmembers = (arguments as Map)["oldmembers"];
  }

  @override
  _JoinCommunityState createState() => _JoinCommunityState();
}

class _JoinCommunityState extends State<JoinCommunity> {
  ImService _imService = new ImService();
  UserService _userService = new UserService();

  List<User> users =[];
  List<int> selectItem = [];
  List<String> selectItemName = [];

  double fontsize = 15;
  double contentfontsize = 14;
  String clubicon = "";
  String notice = "";
  String city = "";
  String province = "";
  String communityname = "";
  String joinruleValue = "1";
  bool _isButtonEnable = true;
  bool _ismore = true;
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  void _getFansList() async {
    users = await _userService.getFans(Global.profile.user!.uid, 0);
    await getFansRemoveOld();
    _refreshController.refreshCompleted();

    if(mounted)
      setState(() {

      });

  }

  void _onLoading() async{
    if(!_ismore) return;
    final moredata = await _userService.getFans(Global.profile.user!.uid, users.length);

    if(moredata.length > 0)
      users = users + moredata;

    await getFansRemoveOld();

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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  getFansRemoveOld() async {

    for(int i=users.length-1; i >= 0; i--){
      if(widget.oldmembers.indexOf(users[i].uid.toString()) >= 0){
        users.remove(users[i]);
      }
    }


    if (mounted) {
      setState(() {

      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),

          title: Text('邀请加入',  style: TextStyle(color:  Colors.black87, fontSize: 16)),
          centerTitle: true,
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: users.length >= 25,
          onRefresh: _getFansList,
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
            child: Text('没有其他新粉丝了',
              style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
          ) : ListView(
            addAutomaticKeepAlives: true,
            children: buildMyFans(),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          alignment: Alignment.centerRight,
          height: 53,
          child: FlatButton(
            shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Text('确定', style: TextStyle(color: Colors.white),),
            color: Global.profile.backColor,
            onPressed: () async{
              try{
                if(_isButtonEnable) {

                  _isButtonEnable = false;
                  List<int> tem = [];
                  selectItem.forEach((e) {
                    tem.add(e);
                  });

                  bool ret = await _imService.joinCommunity(
                      Global.profile.user!.token!,
                      Global.profile.user!.uid,
                      tem,
                      widget.oldmembers,
                      widget.timeline_id,
                      selectItemName,
                      errorCallBack
                  );
                  if (ret != null && ret) {
                    Navigator.pop(context);
                    return;
                  }
                  else{
                    ShowMessage.showToast("邀请失败");
                  }
                  _isButtonEnable = true;
                }
              }
              catch(e)
              {
                _isButtonEnable = true;
                ShowMessage.showToast("网络不给力，请再试一下!");}
                setState(() {
                });
            },
          ),
        )
    );
  }

  List<Widget> buildMyFans(){
    List<Widget> contents = [];
    if(users != null){
      for(User user in users){
        contents.add(
            Column(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      RoundCheckBox(
                        value: selectItem.indexOf(user.uid) >= 0,
                      ),
                      SizedBox(width: 10,),
                      NoCacheClipRRectOhterHeadImage(imageUrl: user.profilepicture!, width: 30, uid: user.uid, cir: 50,),
                      SizedBox(width: 10,),
                      Text(user.username, style: TextStyle(color: Colors.black87, fontSize: 14),),
                    ],
                  ),
                  onTap: (){
                    if(!(selectItem.indexOf(user.uid) >= 0)){
                      selectItem.add(user.uid);
                      selectItemName.add(user.username);
                    }
                    else{
                      selectItem.remove(user.uid);
                      selectItemName.remove(user.username);
                    }
                    setState(() {

                    });
                  },
                ),
                MyDivider()
              ],
            )
        );

      }
    }
    return contents;
  }

  void errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}


class RoundCheckBox extends StatefulWidget {
  RoundCheckBox({Key? key, required this.value})
      : super(key: key);

  final bool value;
  @override
  State<StatefulWidget> createState() {
    return RoundCheckBoxWidgetBuilder();
  }
}

class RoundCheckBoxWidgetBuilder extends State<RoundCheckBox> {
  Widget build(BuildContext context) {
    return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: widget.value ? Colors.green : Color(0xff999999)),
            color: widget.value ? Colors.green : Color(0xffffffff),
            borderRadius: BorderRadius.circular(24)),
        child: Center(
          child: Icon(
            Icons.check,
            color: Color(0xffffffff),
            size: 20,
          ),
        ));
  }
}