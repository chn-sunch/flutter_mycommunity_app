import 'package:flutter/material.dart';

import '../../../model/order.dart';
import '../../../service/userservice.dart';
import '../../../service/gpservice.dart';
import '../../../widget/circle_headimage.dart';
import '../../../model/grouppurchase/goodpice_model.dart';
import '../../../util/showmessage_util.dart';
import '../../../util/imhelper_util.dart';
import '../../../global.dart';

class MyOrderRefund extends StatefulWidget {
  @override
  _MyOrderRefundState createState() => _MyOrderRefundState();
}

class _MyOrderRefundState extends State<MyOrderRefund> {
  UserService _userService = UserService();
  List<Order> _orderList = [];
  int _pagestatus = 0;//简单处理载入状态
  GPService _gpservice = new GPService();

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMyOrder();
  }

  _getMyOrder() async {
    _orderList = await _userService.getMyRefundOrder(Global.profile.user!.token!, Global.profile.user!.uid, (String statecode, String error){
      ShowMessage.showToast(error);
    });
    _pagestatus = 1;
    if (mounted){
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, size: 18,),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text('已退款的订单',textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(5.0),
        child: _pagestatus == 0 ? Center(child: CircularProgressIndicator(
          valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
        )) : _buildOrderList(),
      ),
    );
  }

  Widget _buildOrderList(){
    Widget ret = SizedBox.shrink();
    List<Widget> lists = [];

    if(_orderList != null && _orderList.length > 0){
      _orderList.forEach((e) {
        lists.add(
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            child: InkWell(
              child: Container(
                height: 109,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          e.goodpricepic != "" ? ClipRRectOhterHeadImageContainer(imageUrl: e.goodpricepic,  width: 109, height: 109, cir: 5,) : SizedBox.shrink(),
                          SizedBox(width: 10,),
                          Expanded(
                              child: Container(
                                height: 109,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: Text(e.goodpricetitle, overflow: TextOverflow.ellipsis,maxLines: 3, style: TextStyle(color: Colors.black87, fontSize: 14),)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('下单时间: ${e.createtime}',style: TextStyle(color: Colors.black45, fontSize: 12, )),
                                      ],
                                    )
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text("x", style: TextStyle( fontSize: 12, color: Colors.black45),),
                            Text(e.productnum.toString(), style: TextStyle(fontSize: 14, color: Colors.black45),)
                          ],
                        ),
                        Row(
                          children: [
                            Text("￥", style: TextStyle( fontSize: 12),),
                            Text(e.gpprice.toString(), style: TextStyle(fontSize: 14),)
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              onTap: (){
                _gotoGoodPrice(e.goodpriceid);
              },
            ),
            decoration: new BoxDecoration(//背景
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              //设置四周边框
            ),
          )
        );
        lists.add(Container(height: 6, color: Colors.grey.shade200,));
      });

      lists.add(SizedBox(height: 10,));

      ret = ListView(

        children: lists,
      );
    }
    else{
      ret = Center(
        child: Text('还没有退货的订单', style: TextStyle(color: Colors.black54, fontSize: 14, )),
      );
    }

    return ret;
  }

  Future<void> _gotoGoodPrice(String goodpriceid) async {
    GoodPiceModel? goodprice = await _gpservice.getGoodPriceInfo(goodpriceid);
    if (goodprice != null) {
      Navigator.pushNamed(
          context, '/GoodPriceInfo', arguments: {
        "goodprice": goodprice
      });
    }
  }
}
