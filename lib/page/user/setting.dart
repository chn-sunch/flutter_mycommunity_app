import 'package:flutter/material.dart';
import 'package:flutter_app/util/networkmanager_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';


import '../../service/commonjson.dart';
import '../../service/userservice.dart';
import '../../bloc/user/authentication_bloc.dart';
import '../../util/imhelper_util.dart';
import '../../util/showmessage_util.dart';
import '../../model/im/grouprelation.dart';
import '../../common/iconfont.dart';
import '../../widget/my_divider.dart';
import '../../widget/captcha/block_puzzle_captcha.dart';
import '../../widget/weixing/wxshareview.dart';
import '../../global.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String version = "";
  CommonJSONService _commonJSONService = new CommonJSONService();
  UserService _userService = new UserService();

  ImHelper imhelper = new ImHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAppInfo();
  }

  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    setState(() {

    });
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
        title: Text('账号相关', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5),
        color: Colors.white,
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, '/MyExit');
          },
          title: Text("注销出来玩吧服务", style: TextStyle(fontSize: 14, color: Colors.black),),
        ),
      ),
    );
  }

  void showTel() {
    if (Global.profile.user == null) {
      Navigator.pushNamed(context, '/Login');
      return;
    }

    showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) =>
            Container(
              height: 150,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(IconFont.icon_navbar_xiaoxi_xuanzhong,
                      color: Colors.green,),
                    title: Text('人工客服', style: TextStyle(color:  Colors.black87, fontSize: 15),),
                    onTap: () {
                      telCustomerCare("");
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.mail, color: Colors.blue,),
                    title: Text(
                      '邮件与电话', style: TextStyle(color:  Colors.black87, fontSize: 15),),
                    onTap: () {
                      Navigator.pushNamed(context, '/HtmlContent',
                          arguments: {"parameterkey": "mail", "title": "联系我们"});
                    },
                  ),
                  MyDivider(),
                  Container(
                    height: 6,
                    color: Colors.grey.shade100,
                  ),
                  Expanded(
                    child: buildBtn(),
                  )
                ],
              ),
            )
    ).then((value) {

    });
  }

  Widget buildBtn() {
    return Container(
        color: Colors.white,
        width: double.infinity,
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(
              child: FlatButton(
                  child: Text(
                    '取 消', style: TextStyle(color:  Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          ],
        )
    );
  }

  Future<void> telCustomerCare(String vcode) async {
    String timeline_id = "";
    //获取客服
    int customuid = 0;
    int uid = Global.profile.user!.uid;
    customuid = await _commonJSONService.getSysCustomer(0, Global.profile.user!.uid, Global.profile.user!.token!);
    if(customuid <= 0){
      ShowMessage.showToast("联系客服失败");
      return;
    }

    if (uid > customuid) {
      timeline_id = customuid.toString() + uid.toString();
    }
    else {
      timeline_id = uid.toString() + customuid.toString();
    }
    GroupRelation? groupRelation = await imhelper.getGroupRelationByGroupid(uid, timeline_id);
    if (groupRelation == null) {
      groupRelation = await _userService.joinSingleCustomer(
          timeline_id, uid, customuid, Global.profile.user!.token!,
          vcode,  (String statusCode, String msg) {
          if(statusCode == "-1008"){
            loadingBlockPuzzle(context);
            return;
          }
          else{
            ShowMessage.showToast(msg);
          }
      }, isCustomer: 1);
    }
    if (groupRelation != null) {
      List<GroupRelation> groupRelations = [];
      groupRelations.add(groupRelation);
      int ret = await imhelper.saveGroupRelation(groupRelations);
      if (Global.isInDebugMode) {
        print("保存本地是否成功：-----------------------------------");
        print(groupRelations[0].group_name1);
        //print(ret);
      }
      if (ret > 0) {
        Navigator.pushNamed(this.context, '/MyMessage', arguments: {"GroupRelation": groupRelation});
      }
    }
  }

  //滑动拼图
  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true}) {
    showDialog<Null>(
      context: this.context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v){
            telCustomerCare(v);
          },
          onFail: (){

          },
        );
      },
    );
  }


}
