import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:tobias/tobias.dart' as tobias;
import '../../common/iconfont.dart';
import '../../global.dart';
import '../../model/grouppurchase/goodpice_model.dart';
import '../../service/activity.dart';
import '../../util/common_util.dart';
import '../../util/showmessage_util.dart';
import '../../widget/circle_headimage.dart';

import 'widget/numberwidget.dart';

class OrderConfirm extends StatefulWidget {
  Object? arguments;

  late GoodPiceModel goodPiceModel;
  String specsid = "";
  String specsname = "";
  int productNum = 0;
  num saleprice = 0;//选中显示的价格
  String actid = "";

  OrderConfirm({required this.arguments}){
    goodPiceModel = (arguments as Map)["goodprice"];
    specsid = (arguments as Map)["specsid"];
    productNum = (arguments as Map)["productNum"];
    specsname = (arguments as Map)["specsname"];
    saleprice = (arguments as Map)["saleprice"];
    actid = (arguments as Map)["actid"] != null ?  (arguments as Map)["actid"]  : "";
  }

  @override
  _OrderConfirmState createState() => _OrderConfirmState();
}

class _OrderConfirmState extends State<OrderConfirm> {
  ActivityService _activityservice = ActivityService();
  num _saleprice = 0;
  int _productNum = 0;
  int _paymenttype = 1;//0支付宝 1微信

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _saleprice = widget.saleprice;
    _productNum = widget.productNum;
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
        title: Text('填写订单', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10,),
                    padding: EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15, top: 20, bottom: 5),
                          child: Text(widget.goodPiceModel.brand == "自营"? "官方自营" : widget.goodPiceModel.brand,
                            style: TextStyle(fontSize: 16, color: Colors.black),),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 15, right: 10, top: 10),
                              height: 100,
                              width: 100,
                              child: ClipRRectOhterHeadImageContainer(imageUrl: widget.goodPiceModel.pic,  cir: 10,),
                            ),
                            Expanded(child: Padding(
                              padding: EdgeInsets.only(left: 0, right: 10, top: 10),
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(widget.goodPiceModel.title, style: TextStyle(overflow: TextOverflow.ellipsis),),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(widget.specsname, style: TextStyle(fontSize: 12, color: Colors.black45),),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 20),
                                        alignment: Alignment.topLeft,
                                        child: Text('￥${widget.saleprice}',
                                          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: NumberControllerWidget(
                                          numText: _productNum.toString(),
                                          addValueChanged: (num){

                                          },
                                          removeValueChanged: (num){
                                          },
                                          updateValueChanged: (num){
                                            setState(() {
                                              _productNum = num;
                                              setState(() {
                                                _saleprice = _productNum * widget.saleprice;
                                              });
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),)
                          ],
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    child: Column(
                      children: [
                        ListTile(
                          title: Row(
                            children: [
                              Icon(IconFont.icon_weixin, color: Color(0xff04BE02),),
                              SizedBox(width: 10,),
                              Text('微信支付', style: TextStyle(fontSize: 14, color: Colors.black87),)
                            ],
                          ),
                          trailing: _paymenttype == 1 ? Icon(Icons.check) : SizedBox.shrink(),
                          onTap: (){
                            setState(() {
                              _paymenttype = 1;
                            });
                          },
                        ),
                        ListTile(
                          title: Row(
                            children: [
                              Icon(IconFont.icon_umidd17, color: Color(0xff00A0E9),),
                              SizedBox(width: 10,),
                              Text('支付宝', style: TextStyle(fontSize: 14, color: Colors.black87),)
                            ],
                          ),
                          trailing: _paymenttype == 0 ? Icon(Icons.check) : SizedBox.shrink(),
                          onTap: (){
                            setState(() {
                              _paymenttype = 0;
                            });
                          },
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                  )
                ],
              ),
            ),
            _buildBtn()
          ],
        ),
      ),
    );
  }


  Widget _buildBtn(){
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        color: Colors.white,
        height: 50,
        width: double.infinity,
        alignment: Alignment.centerRight,
        child: Row(
          children: [
            Expanded(child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('￥', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Global.defredcolor),),
                  Text('${_saleprice}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Global.defredcolor),),
                ],
              ),
            ),),
            SizedBox(
              width: 130,
              child: TextButton(
                  child: Text('去支付', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
                  style: ButtonStyle(
                    backgroundColor:   MaterialStateProperty.all(Global.defredcolor),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9))),
                  ) ,
                  onPressed: () async {
                    if(_paymenttype == 0){
                      //支付宝
                      _alipay();
                    }

                    if(_paymenttype == 1){
                      _wxpay();
                    }
                  }),
            ),
          ],
        )
    );
  }

  _alipay() async {
    if(!Global.isInDebugMode) {
      bool isInstalled = await tobias.isAliPayInstalled();
      if (!isInstalled) {
          ShowMessage.showToast("需要有支付宝客户端才能支付");
          return;
      }
    }

    Map<dynamic, dynamic>? orderinfo = await _activityservice.getActivityOrder(Global.profile.user!.uid,
    Global.profile.user!.token!, widget.actid, widget.goodPiceModel.goodpriceid, widget.specsid,
        _productNum, "", _paymenttype, widget.specsname, _errorCallBack);
    //调用支付宝接口
    if(orderinfo != null && orderinfo.isNotEmpty) {
      Map ret;
      ret = await tobias.aliPay(orderinfo['data']);
      if(ret != null && ret["resultStatus"] == "9000"){
        Navigator.pushReplacementNamed(context, '/OrderFinish', result: 1,
          arguments: {
          "goodprice":  widget.goodPiceModel,
          "gpprice": widget.saleprice,
          "productnum": _productNum,
          "ordertime": CommonUtil.getTime()
          });
      }
      else{
        ShowMessage.showToast("取消付款");
      }
    }
  }

  _wxpay() async {
    if(!Global.isInDebugMode) {
      if (!Global.isWeChatInstalled) {
        ShowMessage.showToast("需要有微信客户端才能支付");
        return;
      }
    }


    Map<dynamic, dynamic>? orderinfo = await _activityservice.getActivityOrder(Global.profile.user!.uid,
        Global.profile.user!.token!, widget.actid, widget.goodPiceModel.goodpriceid, widget.specsid, _productNum, "",
        _paymenttype, widget.specsname, _errorCallBack);

    if(orderinfo != null) {
      weChatResponseEventHandler.listen((res) {
        if (res is WeChatPaymentResponse) {
          if(res.isSuccessful){
            Navigator.pushReplacementNamed(context, '/OrderFinish', result: 1,
                arguments: {
                  "goodprice": widget.goodPiceModel,
                  "gpprice": widget.saleprice,
                  "productnum": _productNum,
                  "ordertime": CommonUtil.getTime()
                });
          }
        }
      });

      payWithWeChat(
        appId: orderinfo['appId'],
        partnerId: orderinfo['partnerId'],
        // "package" -> "prepay_id=wx07211624233546bb83951e17d72f140000"
        prepayId: orderinfo['prepayId'],
        packageValue: 'Sign=WXPay',
        nonceStr: orderinfo['nonceStr'],
        timeStamp: int.parse(orderinfo['timeStamp']),
        sign: orderinfo['paySign'],
      );


    }
  }

  _errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}

