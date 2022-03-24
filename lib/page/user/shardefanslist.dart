import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/user.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../service/userservice.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/my_divider.dart';
import '../../global.dart';


class ShardeFansList extends StatefulWidget {
  Object? arguments;
  String content = "";//描述内容
  String contentid = "";//根据类型匹配的id
  String image = "";//图片
  String localimg = "";//本地图片路径带有http
  String sharedtype = "";//分享类型 0 活动 1商品 2拼玩

  ShardeFansList({this.arguments}){
    content = (arguments as Map)["content"];
    contentid = (arguments as Map)["contentid"];
    image = (arguments as Map)["image"];
    localimg = (arguments as Map)["localimg"];
    sharedtype = (arguments as Map)["sharedtype"];
  }

  @override
  _ShardeFansListState createState() => _ShardeFansListState();
}

class _ShardeFansListState extends State<ShardeFansList> {
  List<int> selectItem = [];
  List<String> selectItemName = [];
  List<User> users = [];
  UserService userService = new UserService();
  double fontsize = 15;
  double contentfontsize = 14;
  String clubicon = "";
  String notice = "";
  String city = "";
  String province = "";
  String communityname = "";
  String joinruleValue = "1";
  bool _isButtonEnable = true;
  double pageheight = 0.0;
  bool _ismore = true;
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  ImHelper imHelper = ImHelper();

  void _getFansList() async {
    users = await userService.getFans(Global.profile.user!.uid, 0);

    _refreshController.refreshCompleted();
    if(mounted)
      setState(() {

      });
  }

  void _onLoading() async{
    if(!_ismore) return;
    final moredata = await userService.getFans(Global.profile.user!.uid, users.length);

    if(moredata.length > 0)
      users = users + moredata;

    if(moredata.length >= 25)
      _refreshController.loadComplete();
    else{
      _ismore = false;
      _refreshController.loadNoData();
    }

    if(users != null){
      users = await getFollowInfo(users);
    }

    if(mounted)
      setState(() {

      });
  }

  Future<List<User>> getFollowInfo(List<User> members) async {
    List<User> userlist = [];
    if(members != null){
      for(int i =0; i < members.length; i++){
        bool ret = await isFollow(members[i].uid, Global.profile.user!.uid);
        if(ret){
          members[i].isFollow = true;
        }

        userlist.add(members[i]);
      }

      return userlist;
    }

    return userlist;
  }

  Future<bool> isFollow(int followed, int uid) async {
    bool isfollowed = false;
    List<int> list = await imHelper.selFollowState(
        followed, uid);
    if(list != null && list.length > 0)
      isfollowed = true;

    return isfollowed;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

        title: Text('我的粉丝',  style: TextStyle(color:  Colors.black87, fontSize: 16)),
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
          child: Text('Emm...就是没有粉丝吖',
            style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
        ) : ListView(
          addAutomaticKeepAlives: true,
          children: buildMyFriend(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey.shade100,
        alignment: Alignment.centerRight,
        height: 53,
        child: Row(
          children: [
            Expanded(
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Text('分享', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
                color: Global.profile.backColor,
                onPressed: () async{
                  try{
                    if(_isButtonEnable) {

                      if(selectItem.length <= 0){
                        ShowMessage.showToast("请选择要分享的粉丝");
                        return;
                      }
                      String touids = "";
                      selectItem.forEach((element) {
                        touids += element.toString() + ",";
                      });
                      touids = touids.substring(0, touids.length-1);

                      _isButtonEnable = false;
                      bool ret = await userService.updateSharedFriend(Global.profile.user!.token!, Global.profile.user!.uid,
                          widget.contentid, widget.content, widget.image,
                          touids, int.parse(widget.sharedtype), (){
                            if(int.parse(widget.sharedtype) == 0)
                              ShowMessage.showToast("分享活动失败");
                          });

                      if(ret){
                        ShowMessage.showToast("分享成功");
                        Navigator.pop(context);
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
            ),
          ],
        ),
      )
    );
  }

  List<Widget> buildMyFriend(){
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
