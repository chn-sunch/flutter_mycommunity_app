import 'package:flutter/material.dart';

import '../../../model/order.dart';
import '../../../model/im/grouprelation.dart';
import '../../../widget/circle_headimage.dart';
import '../../../widget/captcha/block_puzzle_captcha.dart';
import '../../../service/activity.dart';
import '../../../service/userservice.dart';
import '../../../model/grouppurchase/goodpice_model.dart';
import '../../../service/gpservice.dart';
import '../../../util/showmessage_util.dart';
import '../../../util/imhelper_util.dart';
import '../../../global.dart';

class MyOrderFinish extends StatefulWidget {
  Future updateCallBack;
  MyOrderFinish(this.updateCallBack);

  @override
  _MyOrderFinishState createState() => _MyOrderFinishState();
}

class _MyOrderFinishState extends State<MyOrderFinish> with AutomaticKeepAliveClientMixin{
  UserService _userService = UserService();
  ActivityService _activityService = ActivityService();
  List<Order> _orderList = [];
  int pagestatus = 0;//简单处理载入状态
  ImHelper imhelper = new ImHelper();
  GPService gpservice = new GPService();

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyOrder();
  }

  getMyOrder() async {
    _orderList = await _userService.getMyOrderFinish(Global.profile.user!.token!, Global.profile.user!.uid, (String statecode, String error){
      ShowMessage.showToast(error);
    });
    pagestatus = 1;
    if (mounted){
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      margin: EdgeInsets.all(5.0),
      child: pagestatus == 0 ? Center(child: CircularProgressIndicator(
        valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
      )) : buildOrderList(),
    );
  }


  Widget buildOrderList(){
    Widget ret = SizedBox.shrink();
    List<Widget> lists = [];

    if(_orderList != null && _orderList.length > 0){
      _orderList.forEach((e) {
        lists.add(Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            children: [
              SizedBox(height: 12,),
              InkWell(
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
              SizedBox(height: 9,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlineButton(
                      child: Text('联系客服', style: TextStyle( fontSize: 12)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9))
                      ),
                      onPressed: () async {
                        telCustomerCare("", e.touid);
                      }
                  ),
                  SizedBox(width: 10,),
                  OutlineButton(
                      child: Text('我要退货', style: TextStyle( fontSize: 12)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9))
                      ),
                      onPressed: () async {
                        await _asked(e.gpactid!, e.orderid!);
                      }
                  ),
                  SizedBox(width: 10,),
                  FlatButton(
                    child: Text('确定收货', style: TextStyle(color: Colors.white, fontSize: 12),),
                    color: Global.profile.backColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9))
                    ),
                    onPressed: () async {
                      await _askedConfirm(e.gpactid!, e.orderid!);
                    },),
                ],
              ),
              SizedBox(height: 9,),
            ],
          ),
          decoration: new BoxDecoration(//背景
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            //设置四周边框
          ),
        ));
        lists.add(Container(height: 6, color: Colors.grey.shade200,));
      });

      lists.add(SizedBox(height: 10,));

      ret = ListView(
        children: lists,
      );
    }
    else{
      ret = Center(
        child: Text('没有发现待确认的订单', style: TextStyle(color: Colors.black54, fontSize: 14, )),
      );
    }

    return ret;
  }

  Future<void> _gotoGoodPrice(String goodpriceid) async {
    GoodPiceModel? goodprice = await gpservice.getGoodPriceInfo(goodpriceid);
    if (goodprice != null) {
      Navigator.pushNamed(
          context, '/GoodPriceInfo', arguments: {
        "goodprice": goodprice
      });
    }
  }

  Future<void> _asked(String gpactid, String orderid) async {
    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('如果商家已经发货可能无法完成退款，确定要退货吗?', style: new TextStyle(fontSize: 17.0)),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  bool ret = await _activityService.refundActivityOrder(gpactid, Global.profile.user!.uid, Global.profile.user!.token!,
                      orderid, (String statusCode, String msg) {
                    ShowMessage.cancel();
                    ShowMessage.showToast(msg);
                  });
                  if(ret){
                    ShowMessage.showToast("退货成功");
                    await imhelper.updateUserOrder(1);//已确认数量-1
                    widget.updateCallBack;
                    getMyOrder();
                  }
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  Future<void> _askedConfirm(String gpactid, String orderid) async {
    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('确定已经收到商品了吗?', style: new TextStyle(fontSize: 17.0)),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确定'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  bool ret = await _activityService.activityFundTransfer(gpactid, Global.profile.user!.uid, Global.profile.user!.token!, orderid,(String statusCode, String msg) {
                    ShowMessage.cancel();
                    ShowMessage.showToast(msg);
                  });
                  if(ret){
                    ShowMessage.showToast("确定成功");
                    await imhelper.updateUserOrder(1);//已确认数量-1
                    widget.updateCallBack;
                    getMyOrder();
                  }
                },
              ),
              new FlatButton(
                child: new Text('取消'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  Future<void> telCustomerCare(String vcode, int touid) async {
    String timeline_id = "";
    //获取客服
    int uid = Global.profile.user!.uid;
    if(uid == touid){
      ShowMessage.showToast("不能联系自己");
      return;
    }

    if (uid > touid) {
      timeline_id = touid.toString() + uid.toString();
    }
    else {
      timeline_id = uid.toString() + touid.toString();
    }
    GroupRelation? groupRelation = await imhelper.getGroupRelationByGroupid(
        uid, timeline_id);
    if (groupRelation == null) {
      groupRelation = await _userService.joinSingleCustomer(
          timeline_id, uid, touid, Global.profile.user!.token!,
          vcode,  (String statusCode, String msg) {
        if(statusCode == "-1008"){
          loadingBlockPuzzle(context, touid: touid);
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
  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true,required int touid}) {
    showDialog<Null>(
      context: this.context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v){
            telCustomerCare(v, touid);
          },
          onFail: (){

          },
        );
      },
    );
  }
}
