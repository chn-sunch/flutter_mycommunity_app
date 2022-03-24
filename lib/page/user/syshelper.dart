import 'package:flutter/material.dart';

import '../../widget/my_divider.dart';
import '../../service/commonjson.dart';
import '../../global.dart';


class SysHelper extends StatefulWidget {
  SysHelper();

  @override
  _SysHelperState createState() => _SysHelperState();
}

class _SysHelperState extends State<SysHelper> {
  List<String> _radioList = [];
  CommonJSONService _commonJSONController = new CommonJSONService();
  int selectindex = -1;
  bool isPageLoad = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContentType();
  }

  getContentType() async {
    await _commonJSONController.getSysHelpConfig((Map<String, dynamic> data) {
      if (data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          _radioList.add("${data["data"][i]["name"].toString()}:${data["data"][i]["value"].toString()}");
        }
      }
    });

    setState(() {
      isPageLoad = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('帮助中心', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: isPageLoad ? buildContent() : Center(
        child: CircularProgressIndicator(
          valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
        ),
      ),
    );
  }

  Widget buildContent(){
    return MediaQuery.removeViewPadding(
        removeTop: true,
        context: this.context,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _radioList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_radioList[index].split(":")[0], style: TextStyle(color: Colors.black87, fontSize: 14, ),),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap:(){
                setState(() {
                  Navigator.pushNamed(context, '/HtmlContent', arguments: {"parameterkey": _radioList[index].split(":")[1], "title": _radioList[index].split(":")[0]});
                });
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              MyDivider(),
        ));
  }


}
