import 'package:flutter/material.dart';
import 'package:flutter_app/util/networkmanager_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

import '../../bloc/user/authentication_bloc.dart';
import '../../service/userservice.dart';
import '../../service/commonjson.dart';
import '../../util/showmessage_util.dart';
import '../../global.dart';

class MyExit extends StatefulWidget {

  MyExit();

  @override
  _MyExitState createState() => _MyExitState();
}

class _MyExitState extends State<MyExit> {
  bool isbutton = true;
  String htmlData = "";
  CommonJSONService _commonJSONService = new  CommonJSONService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _commonJSONService.getHtmlContent((Map<String, dynamic> data){
      if(data!= null && data["data"] != null) {
        setState(() {
          htmlData = data["data"]["value"];
        });
      }
    }, "exitdescription");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text("账号注销", style: TextStyle(fontSize: 16, color: Colors.black),),
        centerTitle: true,
      ),

      body: htmlData == null ? indicator() : MediaQuery.removePadding(
          context: this.context,
          removeTop: true,
          child: ListView(
            children: [
              Html(
                data: htmlData,
                //Optional parameters:
                style: {
                  "html": Style(
                    backgroundColor: Colors.white,
//              color: Colors.white,
                  ),
//            "h1": Style(
//              textAlign: TextAlign.center,
//            ),
                  "table": Style(
                    backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                  ),
                  "tr": Style(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  "th": Style(
                    padding: EdgeInsets.all(6),
                    backgroundColor: Colors.grey,
                  ),
                  "td": Style(
                    padding: EdgeInsets.all(6),
                  ),
                  "var": Style(fontFamily: 'serif'),
                },
                onImageError: (exception, stackTrace) {
                  print(exception);
                },
              ),
              Padding(padding: EdgeInsets.all(10), child: FlatButton(
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Text("确认注销", style: TextStyle(color: Colors.white),),
                color: Colors.red,
                onPressed: () {
                  if(isbutton) {
                    isbutton = false;
                    _askedConfirm();
                  }
                },
              ),)
              
            ],
          )),
    );
  }

  Widget indicator(){
    return Center(
      child: CircularProgressIndicator(
        valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
      ),
    );
  }

  Future<void> _askedConfirm() async {
    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('确定要注销账户吗？', style: new TextStyle(fontSize: 17.0)),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  isbutton = true;
                  ShowMessage.showCenterToast("检测中");
                  UserService userService = new UserService();
                  bool ret = await userService.userexit(Global.profile.user!.uid, Global.profile.user!.token!, (code,msg){
                     ShowMessage.cancel();
                     ShowMessage.showToast(msg);
                  });

                  if(ret != null && ret) {
                    await userService.deltoken(Global.profile.user!.token!, Global.profile.user!.uid, (String statusCode, String msg) {});
                    Global.profile.user = null;
                    Global.profile.defProfilePicture = AssetImage(Global.headimg);
                    Global.saveProfile();
                    NetworkManager.onDone(isouted: true);
                    BlocProvider.of<AuthenticationBloc>(context).add(
                        LoggedOut());
                    Navigator.pushNamedAndRemoveUntil(context, '/main',  (route) => route == null, arguments: {"ispop" : true});
                  }
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: (){
                  isbutton = true;
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

}
