import 'package:flutter/material.dart';

import 'my_divider.dart';
import '../service/userservice.dart';
import '../common/json/interest_json.dart';
import '../util/showmessage_util.dart';
import '../global.dart';

class InterestSel extends StatefulWidget {
  List<String> interest = [];

  InterestSel(this.interest){
  }

  @override
  _InterestSelState createState() => _InterestSelState();
}

class _InterestSelState extends State<InterestSel> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: EdgeInsets.only(left: 10),
                child: Text('选择我喜欢的', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
              ),
              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: Icon(Icons.clear)),
            ],
          ),
          MyDivider(),
          Container(
              height: 230,
              child: GridView.count(
                shrinkWrap: true,
                //水平子Widget之间间距
                crossAxisSpacing: 10.0,
                //垂直子Widget之间间距
                mainAxisSpacing: 10.0,
                //GridView内边距
                padding: EdgeInsets.all(10.0),
                //一行的Widget数量
                crossAxisCount: 4,
                //子Widget宽高比例
                childAspectRatio: 2.0,
                //子Widget列表
                children: _buildChoiceList(),
              )
          ),
          SizedBox(height: 5,),
          MyDivider(),
          Row(
            children: [
              Expanded(child: Container(
                margin: EdgeInsets.all(10),
                child: FlatButton(
                    color: Global.profile.backColor,
                    child: Text(
                      '保存',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(9))
                    ),

                    onPressed: () async{
                      UserService userService = new UserService();
                      String strInterest = "";
                      for(String v in widget.interest){
                        strInterest = strInterest + v + ",";
                      }
                      if(strInterest != "")
                        strInterest = strInterest.substring(0, strInterest.length - 1);
                      bool ret = await userService.updateInterest(Global.profile.user!.token!, Global.profile.user!.uid
                          , strInterest, (String statusCode, String msg){
                            ShowMessage.showToast(msg);
                          });
                      if(ret){
                        Global.profile.user!.interest = strInterest;
                        Navigator.pop(context, strInterest);
                      }
                    }),
                )
              )
            ],
          )
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }

  _buildChoiceList() {
    List<Widget> choices = [];
    interestData.forEach((val, name) {
      choices.add(InkWell(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            name,
            style: TextStyle(fontSize: 14, color: widget.interest.indexOf(val) >= 0 ? Global.profile.fontColor : Colors.black),
          ),
          decoration: BoxDecoration(
            color: widget.interest.indexOf(val) >= 0 ? Global.profile.backColor : Colors.grey.shade200,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onTap: (){
          if(widget.interest.indexOf(val) >= 0 ){
            widget.interest.remove(val);
          }
          else {
            widget.interest.add(val);
          }
          setState(() {

          });
        },
      ));
    });
    return choices;
  }

}

