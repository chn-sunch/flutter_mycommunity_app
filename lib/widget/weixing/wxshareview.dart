import 'package:flutter/material.dart';
import 'wx_sessionshare_webpage.dart';
import '../../global.dart';
import '../my_divider.dart';


class WXShareView extends StatefulWidget {
  Widget? icon;
  String content;//描述内容
  String contentid = "";//根据类型匹配的id
  String image = "";//图片
  String sharedtype = "";//分享类型 0 活动 1商品 2拼玩
  String actid = "";

  WXShareView({this.icon, this.sharedtype = "", this.content = "", this.contentid = "", this.image = "", this.actid = ""});

  @override
  _WXShareViewState createState() => _WXShareViewState();
}

class _WXShareViewState extends State<WXShareView> {
  @override
  Widget build(BuildContext context) {
    String img = "";
    if(widget.image != null && widget.image != ""){

      Uri u = Uri.parse(widget.image);
      img = u.path.substring(1, u.path.length);
    }

    return InkWell(
      child: widget.icon,
      onTap: () {
        if(Global.profile.user == null){
          Navigator.pushNamed(context, '/Login');
          return;
        }

        showModalBottomSheet<Map<String, dynamic>>(
            context: context,
            builder: (BuildContext context) =>
                Container(
                  height: 159,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 10, top: 10),
                        child: Text('分享到', style: TextStyle(color:  Colors.black87, fontSize: 15),),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            WXSessionShareWebPage(arguments: {"title": widget.content, "shareType": 0, "web": Global.apphost},),
                            WXSessionShareWebPage(arguments: {"title": widget.content, "shareType": 1, "web": Global.apphost},),
                          ],
                        ),
                      ),
                      MyDivider(),
                      Container(
                        height: 10,
                        color: Colors.grey.shade100,
                      ),
                      Expanded(
                        child: buildBtn(),
                      )
                    ],
                  ),
                )
        ).then((value)  {

        });
      },
    );
  }

  Widget buildBtn(){
    return Container(
        color: Colors.white,
        width: double.infinity,
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(
              child: FlatButton(
                  child: Text('取消', style: TextStyle(color:  Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),),
                  onPressed: (){
                    Navigator.pop(context);
                  }),
            ),
          ],
        )
    );
  }
}
