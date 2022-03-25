import 'package:flutter/material.dart';


import '../../../common/iconfont.dart';
import 'reportlist.dart';
import 'buglist.dart';
import 'suggestlist.dart';


class ProAndSuggestion extends StatefulWidget {
  @override
  _ProAndSuggestionState createState() => _ProAndSuggestionState();
}

class _ProAndSuggestionState extends State<ProAndSuggestion> {

  int currentIndex = 0;
  final pages = [BugList(), SuggestList(), MyAllReportList(), ];

  final List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(IconFont.icon_bug, color: Colors.black54,),
      activeIcon: Icon(IconFont.icon_bug, color: Colors.blue,),
      label: "BUG反馈",
    ),
    BottomNavigationBarItem(
      icon: Icon(IconFont.icon_linggan, size: 23),
      activeIcon: Icon(IconFont.icon_linggan, color: Colors.blue, size: 23),
      label: "功能建议",
    ),
    BottomNavigationBarItem(
      activeIcon: Icon(IconFont.icon_jubao2, color: Colors.blue,size: 23,),
      icon: Icon(IconFont.icon_jubao2, size: 23,),
      label: "我的举报",
    ),
//    BottomNavigationBarItem(
//      backgroundColor: Colors.white,
//      activeIcon: Icon(IconFont.icon_bangzhuzhongxin, color: Colors.blue,size: 19),
//      icon: Icon(IconFont.icon_bangzhuzhongxin, size: 19,),
//      title: Text("帮助中心"),
//    ),
  ];

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
        title: Text('问题建议', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: bottomNavItems,
        currentIndex: currentIndex,
        selectedLabelStyle: TextStyle(color: Colors.blue, fontSize: 12),
        selectedItemColor: Colors.blue,
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
