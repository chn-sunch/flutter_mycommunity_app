import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widget/icontext.dart';

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

  int _countHistory = 0;
  int _countActivityEvaluate = 0;
  int _newmemberCount = 0;
  int _newFriendJoinCount = 0;
  int _newSharedCount = 0;
  int _myOrderCount = 0;
  int _collectioncount = 0;
  int _pendingOrderCount = 0;
  int _finishOrderCount = 0;

  _hisBrowse() async {
    _countHistory = await _imHelper.countBrowseHistory();
    _newSharedCount = await _imHelper.getUserSharedCount();
    _myOrderCount = await _imHelper.getUserOrder(-1);//-1是获取所有数据

    _collectioncount = (await _imHelper.selGoodPriceCollectionByUid(Global.profile.user!.uid)).length +
        ( await _imHelper.selActivityCollectionByUid(Global.profile.user!.uid)).length;


    setState(() {

    });
  }

  _getOrderCount() async {
    _countActivityEvaluate = await _imHelper.getUserUnEvaluateOrder();

    _pendingOrderCount = await _imHelper.getUserOrder(0);//-1是获取所有数据
    _finishOrderCount = await _imHelper.getUserOrder(1);//-1是获取所有数据
    if(mounted){
      setState(() {

      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _hisBrowse();
    _getOrderCount();
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
        body: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              buildHeadInfo(),

              Expanded(
                child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 1),
                      padding: EdgeInsets.only(top: 10, left: 10, right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text('我的活动', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16), ),
                            padding: EdgeInsets.only(top: 6),
                          ),
                          SizedBox(height: 20,),
                          Padding(padding: EdgeInsets.only(left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconText('发布的', icon: Icon(IconFont.icon_huodong3, color: Global.defredcolor, size: 29,),
                                  style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5), onTap: (){
                                    Navigator.pushNamed(context, '/MyCreateActivity');
                                  },),
                                IconText('加入的', icon: Icon(IconFont.icon_xiaoxixuanzhong, size: 29, color: Colors.green,),
                                    style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5), onTap: (){
                                    Navigator.pushNamed(context, '/MyJoinActivity');
                                  },),
                                IconText('收藏的', icon: Icon(IconFont.icon_zan1, size: 29, color: Colors.deepOrange,),
                                    style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5), onTap: (){
                                    Navigator.pushNamed(context, '/MyCollectionActivity');

                                  },),
                                IconText('分享的', icon:  _newSharedCount > 0 ? Badge(
                                    alignment: Alignment.centerLeft,
                                    toAnimate: false,
                                    badgeContent: Text(_newSharedCount > 99 ? '...' : _newSharedCount.toString(), style: TextStyle(fontSize: 10, color: Colors.white)),
                                    child: Icon(IconFont.icon_shetuanxiu, size: 29, color: Colors.cyan,)):
                                Icon(IconFont.icon_shetuanxiu, size: 29, color: Colors.cyan,),
                                  style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5),
                                  onTap: (){
                                    Navigator.pushNamed(context, '/SharedList');
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            child: Text('我的订单', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16), ),
                            padding: EdgeInsets.only(top: 6),
                          ),
                          SizedBox(height: 20,),
                          Padding(padding: EdgeInsets.only(left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconText('待付款', icon: _pendingOrderCount > 0 ? Badge(
                                    alignment: Alignment.centerLeft,
                                    toAnimate: false,
                                    badgeContent: Text(_pendingOrderCount > 99 ? '...' : _pendingOrderCount.toString(),
                                        style: TextStyle(fontSize: 10, color: Colors.white)),
                                    child: Icon(IconFont.icon_querenfukuan, size: 29, color: Colors.cyan,)):
                                Icon(IconFont.icon_querenfukuan, size: 29, color: Colors.cyan,),
                                  style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5),onTap: (){
                                    Navigator.pushNamed(context, '/MyOrderPending').then((value){
                                      setState(() {
                                        _getOrderCount();
                                      });
                                    });
                                  },),
                                //icon_daifukuan2
                                IconText('待收货', icon: _finishOrderCount > 0 ? Badge(
                                    alignment: Alignment.centerLeft,
                                    toAnimate: false,
                                    badgeContent: Text(_finishOrderCount > 99 ? '...' : _finishOrderCount.toString(),
                                        style: TextStyle(fontSize: 10, color: Colors.white)),
                                    child: Icon(IconFont.icon_daifukuan2, size: 29, color: Colors.deepOrange,)):
                                Icon(IconFont.icon_daifukuan2, size: 29, color: Colors.deepOrange,),
                                    style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5), onTap: (){
                                    Navigator.pushNamed(context, '/MyOrderFinish').then((value){
                                      setState(() {
                                        _getOrderCount();
                                      });
                                    });
                                  },),

                                IconText('待评价', icon: _countActivityEvaluate > 0 ? Badge(
                                    alignment: Alignment.centerLeft,
                                    toAnimate: false,
                                    badgeContent: Text(_countActivityEvaluate > 99 ? '...' : _countActivityEvaluate.toString(),
                                        style: TextStyle(fontSize: 10, color: Colors.white)),
                                    child: Icon(IconFont.icon_dingdan, size: 29, color: Colors.teal,)):
                                Icon(IconFont.icon_dingdan, size: 29, color: Colors.teal,),
                                    style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5),
                                  onTap: (){
                                    Navigator.pushNamed(context, '/ActivityEvaluate').then((value){
                                      setState(() {
                                        _getOrderCount();
                                      });
                                    });
                                  },
                                ),
                                IconText('已退款', icon: Icon(IconFont.icon_huodong2, size: 29, color: Colors.orange,),
                                  style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5), onTap: (){
                                    Navigator.pushNamed(context, '/MyOrderRefund');

                                  },),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white
                      ),
                    ),
                    SizedBox(height: 10,),

                    Container(padding: EdgeInsets.only(left: 20, right: 20, top: 20,bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconText('问题建议', icon: Icon(IconFont.icon_jianyi, size: 29,),
                            style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5), onTap: (){
                              Navigator.pushNamed(context, '/ProAndSuggestion');
                            },),
                          IconText('账户安全', icon: Icon(IconFont.icon_zhanghuanquan1, size: 29,),
                              style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5), onTap: (){
                              Navigator.pushNamed(context, '/MyUserId');
                            },),

                          IconText('帮助中心', icon: Icon(IconFont.icon_bangzhu_kefu, size: 29,),
                            style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5), onTap: (){
                              Navigator.pushNamed(context, '/SysHelper');
                            },),
                          IconText('关于玩吧', icon: Icon(IconFont.icon_guanyuwomen2, size: 29,),
                            style: TextStyle(fontSize: 12, color: Colors.black), direction: Axis.vertical, padding: EdgeInsets.only(bottom: 5), onTap: (){
                              Navigator.pushNamed(context, '/About');
                            },),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
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
      height: 149,
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10 , top: 16),
      child: Column(
        children: [
          Row(
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
                      Text('会员号: ${Global.profile.user!.uid}', style: TextStyle(color: Colors.black38, fontSize: 12),)
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
          SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.only(right: 10,left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconText('收藏商家', icon: Text('${_collectioncount}', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),),
                  style: TextStyle(fontSize: 14, color: Colors.black), direction: Axis.vertical, onTap: (){
                    Navigator.pushNamed(context, '/MyCollectionGoodPrice');
                  },),
                IconText('历史浏览', icon: Text('${_countHistory}', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),),
                  style: TextStyle(fontSize: 14, color: Colors.black), direction: Axis.vertical, onTap: (){
                    Navigator.pushNamed(context, '/MyBrowHistory');
                  },),
                IconText('关注', icon: Text('${CommonUtil.getNum(Global.profile.user!.following!)}',
                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold), ),
                  style: TextStyle(fontSize: 14, color: Colors.black), direction: Axis.vertical, onTap: (){
                    Navigator.pushNamed(context, '/MyFollowUser').then((value){
                      setState(() {

                      });
                    });
                  },),
                IconText('粉丝', icon: Text('${CommonUtil.getNum(Global.profile.user!.followers!)}', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),),
                  style: TextStyle(fontSize: 14, color: Colors.black), direction: Axis.vertical, onTap: (){
                    Navigator.pushNamed(context, '/MyFansUser', arguments: {"uid": Global.profile.user!.uid}).then((value){
                      setState(() {

                      });
                    });
                  },),
              ],
            ),
          ),
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
