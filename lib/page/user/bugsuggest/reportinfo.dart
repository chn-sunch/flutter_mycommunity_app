import 'package:flutter/material.dart';

import '../../../global.dart';
import '../../../util/showmessage_util.dart';
import '../../../common/iconfont.dart';
import '../../../model/report.dart';
import '../../../service/activity.dart';
import '../../../widget/circle_headimage.dart';
import '../../../widget/my_divider.dart';

class MyReportInfo extends StatefulWidget {
  Object? arguments;
  String reportid = "";
  int sourcetype = 0;

  MyReportInfo({this.arguments}) {
    reportid = (arguments as Map)["reportid"];
    sourcetype = (arguments as Map)["sourcetype"];
  }
    @override
  _MyReportState createState() => _MyReportState();
}

class _MyReportState extends State<MyReportInfo> {
  ActivityService _activityService = new ActivityService();
  Report? myReport;
  getReportInfo() async {
    myReport = await _activityService.getMyReportInfo(Global.profile.user!.uid, Global.profile.user!.token!, widget.reportid, widget.sourcetype, (code, error){
      ShowMessage.showToast(error);
    });

    if(myReport != null){
      setState(() {

      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReportInfo();

  }

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
        title: Text('举报内容', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: myReport != null ? ListView(
        children: [
          buildHeadContent(),
          SizedBox(height: 5,),
          buildCenterContent()
        ],
      ) : Center(
        child: Text('', style: TextStyle(color: Colors.black87, fontSize: 14, ),),
      ),
    );
  }

  Widget buildHeadContent(){
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(IconFont.icon_zan2, color: Colors.green, size: 19,),
              SizedBox(width: 10,),
              Text('感谢你的反馈', style: TextStyle(color: Colors.green, fontSize: 16),),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
          color: Colors.white,
          alignment: Alignment.center,
          child: myReport!.repleycontent != null && myReport!.repleycontent != "" ? Text(myReport!.repleycontent, style:  TextStyle(color: Colors.black54, fontSize: 14, ))
              : Text('感谢您的反馈,我们会尽快核实处理，感谢您为净化出来玩吧社区环境作出的贡献。', style: TextStyle(color: Colors.black54, fontSize: 13),),
        )
      ],
    );
  }

  Widget buildCenterContent(){
    String  type = "";
    if(myReport!.reporttype == 0){
      type = "疑似欺诈";
    }
    else if(myReport!.reporttype == 1) {
      type = "低俗引起不适的图片";
    }
    else if(myReport!.reporttype == 2) {
      type = "其他类型";
    }
    else if(myReport!.reporttype == 3){
      type = "留言消息违规";
    }

    Widget contentImg = SizedBox.shrink();
    Widget content = SizedBox.shrink();
    if(myReport!.sourcetype == 0){
      contentImg = myReport!.activity!.coverimg != null && myReport!.activity!.coverimg != "" ? ClipRRectOhterHeadImage(imageUrl: myReport!.activity!.coverimg!, width: 100,) : SizedBox.shrink();
      content = Expanded(child: Text(myReport!.activity!.content, style: TextStyle(color: Colors.black54, fontSize: 12, ), overflow: TextOverflow.ellipsis, maxLines: 3,));
    }
    if(myReport!.sourcetype == 1){
      contentImg = myReport!.goodPiceModel!.pic != null && myReport!.goodPiceModel!.pic != "" ? ClipRRectOhterHeadImage(imageUrl: myReport!.goodPiceModel!.pic, width: 100,) : SizedBox.shrink();
      content = Expanded(child: Text(myReport!.goodPiceModel!.title, style: TextStyle(color: Colors.black54, fontSize: 12, ), overflow: TextOverflow.ellipsis, maxLines: 3,));
    }
    //0活动 1商品 2 单人聊天 3 活动群聊天 4社团群聊天 5活动留言 6活动回复 7好价评价 8好价回复
    if(myReport!.sourcetype == 2 || myReport!.sourcetype == 3 || myReport!.sourcetype == 4 || myReport!.sourcetype == 5 || myReport!.sourcetype == 6 || myReport!.sourcetype == 7 || myReport!.sourcetype == 8){
      contentImg = SizedBox.shrink();
      contentImg = myReport!.user!.profilepicture != null && myReport!.user!.profilepicture! != "" ? ClipRRectOhterHeadImage(imageUrl: myReport!.user!.profilepicture!, width: 100,) : SizedBox.shrink();
      content = Expanded(child: Text(myReport!.user!.username, style: TextStyle(color: Colors.black54, fontSize: 12, ), overflow: TextOverflow.ellipsis, maxLines: 3,));
    }

    return Container(
      padding: EdgeInsets.only(left: 20, top: 10, bottom: 20, right: 10),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('举报详情', style: TextStyle(color: Colors.black54, fontSize: 12, ),),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              contentImg,
              SizedBox(width: 10,),
              content            ],
          ),
          SizedBox(height: 10,),
          MyDivider(),
          SizedBox(height: 10,),
          Row(
            children: [
              Text('举报时间:', style: TextStyle(color: Colors.black54, fontSize: 12, ),),
              SizedBox(width: 10,),
              Text(myReport!.createtime, style: TextStyle(color: Colors.black54, fontSize: 12, )),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Text('违规类型:', style: TextStyle(color: Colors.black54, fontSize: 12, ),),
              SizedBox(width: 10,),
              Text(type, style: TextStyle(color: Colors.black54, fontSize: 12, )),
            ],
          ),
        ],
      ),
    );
  }
}
