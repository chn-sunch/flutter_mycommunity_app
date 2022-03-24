import 'package:badges/badges.dart';
import 'package:flutter/material.dart';



import '../../global.dart';

import 'widget/create.dart';
import 'widget/join.dart';

class MyActivityAll extends StatefulWidget {
  @override
  _MyActivityAllState createState() => _MyActivityAllState();
}

class _MyActivityAllState extends State<MyActivityAll> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double pageheight = 0.0;
  double pagewidth = 0.0;
  int countActivityEvaluate = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    // _myActivityAllBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    pageheight = MediaQuery.of(context).size.height - 150;
    pagewidth = MediaQuery.of(context).size.width - 40;


    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20, ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text('我的活动', style: TextStyle(color:  Colors.black87, fontSize: 16),),
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
              Text('创建的', style: TextStyle(fontSize: 14.0),),
              countActivityEvaluate > 0 ? Badge(
                  alignment: Alignment.centerLeft,
                  toAnimate: false,
                  badgeContent: Text(countActivityEvaluate > 99 ? '...' : countActivityEvaluate.toString(), style: TextStyle(fontSize: 10, color: Colors.white)),
                  child: Text('已完成', style: TextStyle(fontSize: 14.0))):
              Text('加入的', style: TextStyle(fontSize: 14.0)),
            ]
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: [
            ProgressActivity(),
            FinishActivity()
          ]
      ),
    );
  }

}
