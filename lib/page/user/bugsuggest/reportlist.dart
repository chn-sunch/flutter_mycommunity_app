import 'package:flutter/material.dart';

import '../../../model/report.dart';
import '../../../model/im/imreport.dart';
import '../../../service/activity.dart';
import '../../../util/showmessage_util.dart';
import '../../../global.dart';

class MyAllReportList extends StatefulWidget {
  Object? arguments;
  bool isAppbar=false;
  MyAllReportList({arguments}){
    if(arguments != null && arguments["isAppbar"] != null){
      isAppbar = true;
    }
  }


  @override
  _MyAllReportListState createState() => _MyAllReportListState();
}

class _MyAllReportListState extends State<MyAllReportList> {

  List<Report> myReports = [];
  List<ImReport> myImReports = [];
  List<TemReport> allReports = [];
  ActivityService _activityService = new ActivityService();

  int pagestatus = 0;
  getMyReportList() async {
    myReports = await _activityService.getMyReport(Global.profile.user!.uid, Global.profile.user!.token!, (code, error){
      ShowMessage.showToast(error);
    });
    if(myReports != null && myReports.length > 0){
      myReports.forEach((e) {
        allReports.add(TemReport(reportid: e.reportid!, uid: e.uid!, actid: e.actid, createtime: e.createtime, updatetime: e.updatetime,
        repleycontent: e.repleycontent, reporttype: e.reporttype, type: 0, sourcetype: e.sourcetype!));
      });
    }

    pagestatus = 1;
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyReportList();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.isAppbar ? AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text('举报记录', style: TextStyle(color: Colors.black, fontSize: 16)),
          centerTitle: true,
        ): null,
        body: pagestatus == 0 ? Center(child: CircularProgressIndicator(
          valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
        )) : (myReports != null && myReports.length > 0 ? buildContent(): Center(
            child: Text('还没有举报记录', style: TextStyle(color: Colors.black87, fontSize: 14, ),))
        ));
  }

  Widget buildContent(){
    List<Widget> lists = [];
    if(allReports != null && allReports.length > 0) {
      allReports.sort((a, b) => (b.createtime).compareTo(a.createtime));
    }

    allReports.forEach((e) {
      if(e.type == 0) {
        String titletype = "";
        if (e.reporttype == 0) {
          titletype = "疑似欺诈";
        }
        if (e.reporttype == 1) {
          titletype = "低俗不适图片";
        }
        if (e.reporttype == 2) {
          titletype = "其他举报";
        }
        if(e.reporttype == 3){
          titletype = "留言消息举报";
        }
        lists.add(ListTile(
          title: Text(
            '[${titletype}]', style: TextStyle(color: Colors.black87, fontSize: 14, ),),
          subtitle: Text(
            e.createtime, style: TextStyle(color: Colors.black54, fontSize: 12, ),),
          trailing: Container(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('已完结', style: TextStyle(color: Colors.black54, fontSize: 12, ),),
                Icon(Icons.navigate_next, color: Colors.black26, size: 19,),
              ],
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
                context, '/MyReportInfo', arguments: {"reportid": e.reportid, "sourcetype": e.sourcetype});
          },
        ));
      }
      if(e.type == 1) {
        String titletype = "";
        if(e.reporttype == 0){
          titletype = "活动群";
        }
        if(e.reporttype == 1){
          titletype = "朋友群";
        }
        if(e.reporttype == 2){
          titletype = "私聊";
        }
        if(e.reporttype == 3){
          titletype = "团购群";
        }

        lists.add(ListTile(
          title: Text('[${titletype}]', style: TextStyle(color: Colors.black87, fontSize: 14, ),),
          subtitle: Text(e.createtime, style: TextStyle(color: Colors.black54, fontSize: 12, ),),
          trailing: Container(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('已完结', style:  TextStyle(color: Colors.black54, fontSize: 12, ),),
                Icon(Icons.navigate_next, color: Colors.black26, size: 19,),
              ],
            ),
          ),
          onTap: (){
            Navigator.pushNamed(context, '/MyReportImInfo', arguments: {"reportid": e.reportid});
          },
        ));
      }
    });



    return Container(
      color: Colors.white,
      child: ListView(
        children: lists,
      ),
    );
  }
}


class TemReport{
  String reportid;
  int uid;
  String actid;
  String createtime;
  String updatetime;
  String repleycontent;
  int reporttype;//0 疑似欺诈 1低俗图片 2其他
  int type;//0 活动  1 聊天
  int sourcetype;//0活动  1goodprice

  TemReport({this.reportid = "", this.uid = 0,  this.actid = "", this.createtime = "", this.updatetime = "",
    this.repleycontent = "", this.reporttype = 0, this.type = 0, this.sourcetype = 0});

}
