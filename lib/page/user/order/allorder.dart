import 'package:badges/badges.dart';
import 'package:flutter/material.dart';


import 'confirm.dart';
import 'finish.dart';
import 'pending.dart';
import 'refund.dart';
import '../../../util/imhelper_util.dart';
import '../../../global.dart';

class MyOrder extends StatefulWidget {
  @override
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder>  with SingleTickerProviderStateMixin{
  late TabController _tabController;
  int pendingOrderCount = 0;//待付款
  int finishOrderCount = 0;//已付款
  ImHelper _imHelper = ImHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    getOrderCount();
  }

  getOrderCount() async {
    pendingOrderCount = await _imHelper.getUserOrder(0);//-1是获取所有数据
    finishOrderCount = await _imHelper.getUserOrder(1);//-1是获取所有数据
    if(mounted){
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '我的订单', style: TextStyle(color: Colors.black87, fontSize: 16),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
            onTap: (int index) {
              print('Selected......$index');
            },
            controller: _tabController,
            //
            unselectedLabelColor: Colors.grey,
            //设置未选中时的字体颜色，tabs里面的字体样式优先级最高
            unselectedLabelStyle: TextStyle(fontSize: 20),
            //设置未选中时的字体样式，tabs里面的字体样式优先级最高
            labelColor: Colors.black,
            //设置选中时的字体颜色，tabs里面的字体样式优先级最高
            labelStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            //设置选中时的字体样式，tabs里面的字体样式优先级最高
            indicatorColor: Global.profile.backColor,
            //选中下划线的颜色
            indicatorSize: TabBarIndicatorSize.label,
            //选中下划线的长度，label时跟文字内容长度一样，tab时跟一个Tab的长度一样
            labelPadding: EdgeInsets.only(bottom: 10),
            indicatorWeight: 5,
            tabs: [
              pendingOrderCount > 0 ? Badge(
                  alignment: Alignment.centerLeft,
                  toAnimate: false,
                  badgeContent: Text(pendingOrderCount > 99 ? '...' : pendingOrderCount.toString(), style: TextStyle(fontSize: 10, color: Colors.white)),
                  child:
                  Text('待付款', style: TextStyle(fontSize: 14.0),)
              ) : Text('待付款', style: TextStyle(fontSize: 14.0),),
              finishOrderCount > 0 ? Badge(
                  alignment: Alignment.centerLeft,
                  toAnimate: false,
                  badgeContent: Text(finishOrderCount > 99 ? '...' : finishOrderCount.toString(), style: TextStyle(fontSize: 10, color: Colors.white)),
                  child:
                  Text('待确认', style: TextStyle(fontSize: 14.0),)
              ) : Text('待确认', style: TextStyle(fontSize: 14.0),),


              Text('已完成', style: TextStyle(
                  fontSize: 14.0
              ),),

              Text('已退款', style: TextStyle(
                  fontSize: 14.0
              ),),
            ]
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: [
            MyOrderPending(getOrderCount()),
            MyOrderFinish(getOrderCount()),
            MyOrderConfirm(),
            MyOrderRefund()
          ]
      ),
    );
  }
}
