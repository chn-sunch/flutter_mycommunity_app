import 'package:flutter/material.dart';

import '../../../global.dart';
import '../../../service/activity.dart';
import '../../../util/showmessage_util.dart';
import '../../../widget/captcha/block_puzzle_captcha.dart';


class ReportImageActivity extends StatefulWidget {
  String actid  = "";
  int sourcetype = 0; //0活动 1商品 2 聊天
  Object? arguments;
  int touid = 0;

  ReportImageActivity({this.arguments}){
    if(arguments != null){
      actid = (arguments as Map)["actid"];
      sourcetype =  (arguments as Map)["sourcetype"];
      touid =  (arguments as Map)["touid"];
    }
  }


  @override
  _ReportImageActivityState createState() => _ReportImageActivityState();
}

class _ReportImageActivityState extends State<ReportImageActivity> {
  List<String> _radioList = [];
  ActivityService _activityService = new ActivityService();
  int selectindex = 0;
  String _radioCheck = '低俗图片';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _radioList.add("低俗图片");
    _radioList.add("不雅图片");
    _radioList.add("引起不适图片");
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
        title: Text('违规图片', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Text('请先选择违规类型'),
          ),
          SizedBox(height: 3,),
          buildContent()
        ],
      ),
      bottomNavigationBar: buildReportBtn(),

    );
  }

  Widget buildContent(){
    return Container(
      color: Colors.white,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: _radioList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_radioList[index], style: TextStyle(color: Colors.black87, fontSize: 14, ),),
              leading: Radio(
                focusColor: Colors.green,
                hoverColor: Colors.green,
                activeColor: Colors.green,
                value: _radioList[index],
                visualDensity: VisualDensity.compact,
                groupValue: _radioCheck,
                onChanged: (String? value) {
                  setState(() {
                    if(value != null)
                      _radioCheck = value;
                  });
                },
              ),
              onTap:(){
                setState(() {
                  _radioCheck = _radioList[index];
                  selectindex = index;
                });
              },
            );
          }),
    );
  }

  Widget buildReportBtn(){
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      height: 60,
      child: FlatButton(
        color: Colors.green,
        child: Text(
          '举报',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          if(Global.profile.user != null) {
            if(selectindex == -1){
              ShowMessage.showToast("请选择违规类型");
              return;
            }
            String reportid = await _activityService.reportActivity(
                Global.profile.user!.uid,
                widget.touid,
                Global.profile.user!.token!,
                widget.actid,
                1,//0 疑似欺诈 1低俗图片 2其他 3留言内容和聊天内容
                "",
                "",
                selectindex, widget.sourcetype, "", (code, error){
                  if(code == "-1008"){
                    loadingBlockPuzzle(context);
                  }
                  else {
                    ShowMessage.showToast(error);
                  }
                }
            );
            if(reportid != null && reportid != ""){
              Navigator.pushReplacementNamed(context, '/MyReportInfo', arguments: {"reportid": reportid, "sourcetype": widget.sourcetype});
            }
          }
          else{
            Navigator.pushNamed(context, '/Login');
          }
        },
      ),
    );
  }

  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v) async {
            String reportid = await _activityService.reportActivity(
                Global.profile.user!.uid,
                widget.touid,
                Global.profile.user!.token!,
                widget.actid,
                1,//0 疑似欺诈 1低俗图片 2其他 3留言内容和聊天内容
                "",
                "",
                selectindex, widget.sourcetype, v, (code, error){}
            );
            if(reportid != null && reportid != ""){
              Navigator.pushReplacementNamed(context, '/MyReportInfo', arguments: {"reportid": reportid, "sourcetype": widget.sourcetype});
            }
          },
          onFail: (){

          },
        );
      },
    );
  }
}
