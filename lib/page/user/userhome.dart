import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

import '../../util/imhelper_util.dart';
import '../../util/common_util.dart';
import '../../common/iconfont.dart';
import '../../widget/circle_headimage.dart';
import '../../global.dart';

class MyHome extends StatefulWidget {
  Object? arguments;
  bool isPop = false;

  MyHome({this.arguments}){
    if(arguments != null){
      isPop = true;
    }
  }

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  ImHelper _imHelper = ImHelper();

  int countHistory = 0;
  int countActivityEvaluate = 0;
  int newmemberCount = 0;
  int newFriendJoinCount = 0;
  int newSharedCount = 0;
  int myOrderCount = 0;
  hisBrowse() async {
    countHistory = await _imHelper.countBrowseHistory();
    countActivityEvaluate = await _imHelper.getUserUnEvaluateOrder();
    newSharedCount = await _imHelper.getUserSharedCount();
    myOrderCount = await _imHelper.getUserOrder(-1);//-1是获取所有数据
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hisBrowse();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize:Size.fromHeight(MediaQueryData.fromWindow(window).padding.top),
          child: SafeArea(
            top: true,
            child: Offstage(),
          ),
        ),

        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(39.0), // here the desired height
        //   child: AppBar(
        //     backgroundColor: Colors.white,
        //     actions: [
        //       IconButton(
        //         alignment: Alignment.topCenter,
        //         icon: Icon(IconFont.icon_fenxiang, color: Colors.black45, ),
        //         onPressed: (){
        //           Navigator.pushNamed(context, '/Seting');
        //         },
        //       ),
        //     ],
        //     elevation: 0,
        //   ),
        // ),
        body: Container(
          color: Colors.grey.shade100,
          child: Column(
            children: [
              buildHeadInfo(),
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        trailing: Icon(Icons.keyboard_arrow_right),
                        leading: Icon(IconFont.icon_shetuanxiu, size: 23, color: Colors.cyan,),
                        title: newSharedCount > 0 ? Badge(
                            alignment: Alignment.centerLeft,
                            toAnimate: false,
                            badgeContent: Text(newSharedCount > 99 ? '...' : newSharedCount.toString(), style: TextStyle(fontSize: 10, color: Colors.white)),
                            child: Text('分享', style: TextStyle(color: Colors.black87, fontSize: 14))):
                        Text('分享', style: TextStyle(color: Colors.black87, fontSize: 14)),
                        onTap: (){
                          Navigator.pushNamed(context, '/SharedList');
                        },
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        trailing: Icon(Icons.keyboard_arrow_right),
                        leading: Icon(IconFont.icon_collection_b, size: 23, color: Colors.yellow.shade700,),
                        title: Text('收藏', style: TextStyle(color: Colors.black87, fontSize: 14)),
                        onTap: (){
                          Navigator.pushNamed(context, '/MyCollection');
                        },
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        trailing: Icon(Icons.keyboard_arrow_right),
                        leading: Icon(IconFont.icon_icon_shangcheng_mian, size: 23, color: Colors.red,),
                        title: countActivityEvaluate > 0 ? Badge(
                            alignment: Alignment.centerLeft,
                            toAnimate: false,
                            badgeContent: Text(countActivityEvaluate > 99 ? '...' : countActivityEvaluate.toString(),
                                style: TextStyle(fontSize: 10, color: Colors.white)),
                            child: Text('待评价', style: TextStyle(color: Colors.black87, fontSize: 14))):
                        Text('待评价', style: TextStyle(color: Colors.black87, fontSize: 14)),
                        onTap: (){
                          Navigator.pushNamed(context, '/ActivityEvaluate');
                        },
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        trailing: Icon(Icons.keyboard_arrow_right),
                        leading: Icon(IconFont.icon_dingdan, size: 23, color: Colors.orange,),
                        title: myOrderCount > 0 ? Badge(
                            alignment: Alignment.centerLeft,
                            toAnimate: false,
                            badgeContent: Text(myOrderCount > 99 ? '...' : myOrderCount.toString(), style: TextStyle(fontSize: 10, color: Colors.white)),
                            child:Text('我的订单', style: TextStyle(color: Colors.black87, fontSize: 14))) :
                        Text('我的订单', style: TextStyle(color: Colors.black87, fontSize: 14)),
                        onTap: (){
                          Navigator.pushNamed(context, '/MyOrder');
                        },
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        trailing: Icon(Icons.keyboard_arrow_right),
                        leading: Icon(IconFont.icon_dongtai2, size: 23, color: Colors.lightGreen,),
                        title: Text('我的活动', style: TextStyle(color: Colors.black87, fontSize: 14)),
                        onTap: (){
                          Navigator.pushNamed(context, '/MyActivityAll');
                        },
                      ),
                    ),
                    SizedBox(height: 10,),

                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          Navigator.pushNamed(context, '/ProAndSuggestion');
                        },
                        trailing: Icon(Icons.keyboard_arrow_right),
                        leading: Icon(Icons.mail, size: 23, color: Color(0xFFFA8072),),
                        title: Text('问题建议', style: TextStyle(color: Colors.black87, fontSize: 14)),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          Navigator.pushNamed(context, '/MyUserId');
                        },
                        trailing: Icon(Icons.keyboard_arrow_right),
                        leading: Icon(IconFont.icon_24gf_shieldCheck, size: 23, color: Colors.lightBlue,),
                        title: Text('账户安全', style: TextStyle(color: Colors.black87, fontSize: 14)),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          Navigator.pushNamed(context, '/SysHelper');
                        },
                        trailing: Icon(Icons.keyboard_arrow_right),
                        leading: Icon(Icons.help, size: 23, color: Colors.blueGrey,),
                        title: Text('帮助中心', style: TextStyle(color: Colors.black87, fontSize: 14)),
                      ),
                    ),

                  ],
                ),
              )
            ],
          )
        )
    );
  }

  Widget buildHeadInfo(){
    return Container(
      height: 89,
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                child: Global.profile.user != null ? NoCacheClipRRectOhterHeadImage(imageUrl: Global.profile.user!.profilepicture??"",
                  uid: Global.profile.user!.uid,width: 60, cir: 50,) : AssetImage(Global.headimg) as Widget,
                onTap: (){
                  Navigator.pushNamed(context, '/PhotoViewImageHead', arguments: {"iscache": false, "image":
                  Global.profile.user!.profilepicture});
                },
              ),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Text(Global.profile.user!.username, style: TextStyle(color:  Colors.black87, fontSize: 15),),
                    onTap: (){
                      Navigator.pushNamed(context, '/MyProfile').then((value){
                        setState(() {

                        });
                      });
                    },
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: [
                      InkWell(
                        onTap: (){
                          if(Global.profile.user!.followers! > 0) {
                            Navigator.pushNamed(context, '/MyFansUser', arguments: {"uid": Global.profile.user!.uid}).then((value){
                              setState(() {

                              });
                            });
                          }
                        },
                        child:  Text('粉丝 ${CommonUtil.getNum(Global.profile.user!.followers!)} | ',
                          style: TextStyle(color: Colors.black45, fontSize: 13),),
                      ),
                      InkWell(
                        onTap: (){
                          if(Global.profile.user!.following! > 0) {
                            Navigator.pushNamed(context, '/MyFollowUser').then((value){
                              setState(() {

                              });
                            });
                          }
                        },
                        child:  Text('关注 ${CommonUtil.getNum(Global.profile.user!.following!)} | ',
                          style: TextStyle(color: Colors.black45, fontSize: 13),),
                      ),
                      InkWell(
                        child:  Text('历史浏览 ${countHistory}', style: TextStyle(color: Colors.black45, fontSize: 13),),
                        onTap: (){
                          Navigator.pushNamed(context, '/MyBrowHistory');
                        },
                      )
                    ],
                  )
                ],
              )
            ],
          ),
          Align(
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Row(
                children: [
                  Text('个人主页 ', style: TextStyle(color:  Colors.black87, fontSize: 15)),
                  Icon(Icons.keyboard_arrow_right, color: Colors.black45,),
                  ],
                ),
              ),
              onTap: (){
                Navigator.pushNamed(context, '/MyProfile');
              },
            ),
            alignment: Alignment.centerRight,
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
    );
  }

  Widget buildSysManage(){
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/GoodPriceCheck');
        },
        trailing: Icon(Icons.keyboard_arrow_right),
        leading: Icon(
          Icons.build, size: 23, color: Colors.blue,),
        title: Text('运维通道',
            style: TextStyle(color: Colors.black87, fontSize: 14)),
      ),
    );
  }
}
