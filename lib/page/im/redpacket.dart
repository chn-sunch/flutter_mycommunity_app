import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tobias/tobias.dart' as tobias;

import '../../util/common_util.dart';
import '../../util/showmessage_util.dart';
import '../../service/imservice.dart';
import '../../global.dart';


class RedPacket extends StatefulWidget {
  Object? arguments;
  String timeline_id = "";
  int timeline_type = 0;

  RedPacket({this.arguments}){
    if(arguments != null){
      timeline_id = (arguments as Map)["timeline_id"];
      timeline_type = (arguments as Map)["timeline_type"];
    }
  }

  @override
  _RedPacketState createState() => _RedPacketState();
}

class _RedPacketState extends State<RedPacket> {
  ImService _imService = ImService();
  TextEditingController _textRedNumController = new TextEditingController();
  TextEditingController _textRedAmountController = new TextEditingController();
  TextEditingController _textRedContentController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('发红包', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          buildRedNum(),
          buildRedAmount(),
          buildRedContent(),
          SizedBox(height: 30,),
          buildRedPacket()
        ],
      ),
    );
  }

  Widget buildRedNum(){
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('红包个数'),
          Expanded(child: TextField(
              controller: _textRedNumController,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter(RegExp("[0-9]"), allow: true),
              LengthLimitingTextInputFormatter(9),],
              maxLines: 1,//最大行数
              autocorrect: true,//是否自动更正
              autofocus: false,//是否自动对焦
              textAlign: TextAlign.end,//文本对齐方式
              style: TextStyle(color: Colors.black87, fontSize: 14, ),//输入文本的样式
              onChanged: (text) {//内容改变的回调
              },

              decoration: InputDecoration(
                counterText:"",
                hintText: "填写个数",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10,  bottom: 0, right: 10),

              )
          )),
          Text('个'),
        ],
      ),
    );
  }

  Widget buildRedAmount(){
    return Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('总金额'),
            Expanded(child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                  LengthLimitingTextInputFormatter(9),
                  MoneyTextInputFormatter()],
                controller: _textRedAmountController,
                maxLines: 1,//最大行数
                autocorrect: true,//是否自动更正
                autofocus: false,//是否自动对焦
                textAlign: TextAlign.end,//文本对齐方式
                style: TextStyle(color: Colors.black87, fontSize: 14, ),//输入文本的样式
                onChanged: (text) {//内容改变的回调

                },
                decoration: InputDecoration(
                  counterText:"",
                  hintText: "0.00",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10,  bottom: 0, right: 10),
                )
            ),),
            Text('元'),
          ],
        ));
  }

  Widget buildRedContent(){
    return Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.only( right: 10, top: 5, bottom: 0),
        color: Colors.white,
        child: TextField(
            controller: _textRedContentController,
            maxLength: 30,
            maxLines: 3,//最大行数
            autocorrect: true,//是否自动更正
            autofocus: false,//是否自动对焦
            textAlign: TextAlign.start,//文本对齐方式
            style: TextStyle(color: Colors.black87, fontSize: 14, ),//输入文本的样式
            onChanged: (text) {//内容改变的回调
            },
            decoration: InputDecoration(
              counterText:"",
              hintText: "恭喜发财，大吉大利！",
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 10,  bottom: 0, right: 10),

            )
        ),);
  }


  Widget buildRedPacket(){
    return Container(
      alignment: Alignment.center,
      child: Container(
        width: 180,
        child: FlatButton(
          shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Text("发红包", style: TextStyle(color: Colors.white),),
          color: Colors.redAccent,
          onPressed: () async {
            if(double.parse(_textRedAmountController.text) > 400){
              ShowMessage.showToast("支付宝单次发送红包金额不能超过400元");
              return;
            }
            if(_textRedAmountController.text.isEmpty || _textRedNumController.text.isEmpty){
              ShowMessage.showToast("请输入红包个数和金额");
              return;
            }
            bool isInstalled = await tobias.isAliPayInstalled();
            if(!isInstalled){
              ShowMessage.showToast("需要有支付宝客户端才能支付");
              return;
            }

            if( _textRedContentController.text == ""){
              _textRedContentController.text = "恭喜发财，大吉大利";
            }
            String orderinfo = await _imService.createRedPacketOrder(Global.profile.user!.uid, Global.profile.user!.token!,
                widget.timeline_id, double.parse(_textRedAmountController.text), 0, int.parse(_textRedNumController.text), _textRedContentController.text, widget.timeline_type, (code, msg){
                  ShowMessage.showToast(msg);
                });
            //调用支付宝接口
            if(orderinfo != null && orderinfo.isNotEmpty) {
              Map? ret;
              ret = await tobias.aliPay(orderinfo);
              if(ret != null && ret["resultStatus"] == "9000"){
                String data = json.encode(jsonDecode(ret["result"])["alipay_fund_trans_app_pay_response"]);
                String redpacketid = await _imService.payredpacketsuccess(Global.profile.user!.uid, Global.profile.user!.token!,
                    data, jsonDecode(ret["result"])["sign"].toString(), (code, msg){
                  ShowMessage.showToast(msg);
                });
                if(redpacketid != null && redpacketid != ""){
                  //拼手气红包
                  Navigator.pop(context, "|sendredpacket:" + _textRedContentController.text + "#" + redpacketid + "#0|");
                }
                //print(result);
              }
              else{
                ShowMessage.showToast("发红包失败");
              }
              //print(ret);
            }
          },
        ),
      ),
    );
  }
}


