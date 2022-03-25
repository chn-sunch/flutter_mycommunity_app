import 'package:flutter/material.dart';

import '../../common/iconfont.dart';
import '../../page/activity/collection.dart';
import '../../page/shop/collection.dart';
import '../../global.dart';


class MyCollection extends StatefulWidget {
  @override
  _MyCollectionState createState() => _MyCollectionState();
}

class _MyCollectionState extends State<MyCollection> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  int currentIndex = 0;

  final pages = [MyCollectionActivity(), MyCollectionGoodPrice(), ];

  final List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      backgroundColor: Colors.white,
      icon: Icon(IconFont.icon_dongtai1, size: 29,),
      activeIcon: Icon(IconFont.icon_dongtai2, size: 29
        , color: Global.profile.backColor,),
      label: "一起出发",
    ),
    BottomNavigationBarItem(
      backgroundColor: Colors.white,
      icon: Icon(IconFont.icon_icon_shangcheng_xian, size: 29),
      activeIcon: Icon(IconFont.icon_icon_shangcheng_mian, color: Global.profile.backColor, size: 29),
      label: "商家活动",
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this,length: 2);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('我的收藏', style: TextStyle(color: Colors.black87, fontSize: 16),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        unselectedLabelStyle: TextStyle(fontSize: 12, color: Colors.black54),
        selectedLabelStyle: TextStyle(fontSize: 12, color: Colors.black54),
        selectedItemColor: Global.profile.backColor,
        items: bottomNavItems,
        currentIndex: currentIndex,
        onTap: (index){
          if(index != currentIndex) {
            currentIndex = index;
            setState(() {

            });
          }
        },
      ),
      body:  pages[currentIndex],
    );
  }
}
