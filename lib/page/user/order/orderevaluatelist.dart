
import 'package:flutter/material.dart';

import '../../../global.dart';
import '../../../model/order.dart';
import '../../../service/activity.dart';
import '../../../service/gpservice.dart';
import '../../../model/grouppurchase/goodpice_model.dart';
import '../../../widget/circle_headimage.dart';
import '../../../util/showmessage_util.dart';



class ActivityEvaluateList extends StatefulWidget {
  @override
  _ActivityEvaluateListState createState() => _ActivityEvaluateListState();
}

class _ActivityEvaluateListState extends State<ActivityEvaluateList> {

  List<Order> _orderlist = [];
  ActivityService _activityService = ActivityService();
  GPService gpservice = new GPService();

  getOrderUnEvaluate() async {
    _orderlist = await _activityService.getUnEvaluateOrderList(Global.profile.user!.uid, Global.profile.user!.token!, (String statecode, String error){
      ShowMessage.showToast(error);
    });
    if (mounted) {
      setState(() {

      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrderUnEvaluate();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back_ios, size: 18,),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title:  Text('待评价',textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 16)),
          centerTitle: true,

        ),
        body: buildActivity(),
      ),
    );
  }

  Widget buildActivity(){
    List<Widget> widgets = [];
    widgets.add(SizedBox(height: 10,));
    if(_orderlist != null && _orderlist.length > 0) {
      _orderlist.forEach((e) {
        widgets.add(Container(
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
                    FlatButton(
                      child: Text('评价', style: TextStyle(color: Colors.white, fontSize: 12),),
                      color: Global.profile.backColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9))
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, '/Evaluate', arguments: {"order": e}).then((value){
                          setState(()  {
                            getOrderUnEvaluate();
                          });
                        });
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
        widgets.add(Container(height: 6, color: Colors.grey.shade200,));
      });

      widgets.add(SizedBox(height: 10,));

    }
    return _orderlist != null && _orderlist.length > 0 ? ListView(
      children: widgets,
    ): Center(child: Text('暂时没有待评价订单', style: TextStyle(color: Colors.black54, fontSize: 14, ),),);
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

}
