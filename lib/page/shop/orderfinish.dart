import '../../../common/iconfont.dart';
import '../../../model/grouppurchase/goodpice_model.dart';
import '../../../widget/circle_headimage.dart';
import '../../../widget/my_divider.dart';
import 'package:flutter/material.dart';


class OrderFinish extends StatefulWidget {
  Object? arguments;
  late GoodPiceModel goodPiceModel;
  int productnum = 0;
  double gpprice = 0;
  String ordertime = "";

  OrderFinish({this.arguments}){
    goodPiceModel = (arguments as Map)["goodprice"];
    productnum = (arguments as Map)["productnum"];
    gpprice = (arguments as Map)["gpprice"];
    ordertime = (arguments as Map)["ordertime"];
  }

  @override
  _OrderFinishState createState() => _OrderFinishState();
}

class _OrderFinishState extends State<OrderFinish> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("支付完成"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87,),
          onPressed: (){
            // Navigator.pushReplacementNamed(context, '/ActivityInfo', arguments: {"actid": widget.activity.actid});
            Navigator.pop(context, 1);
          },
        ),
        actions: [
          InkWell(
            child: Container(
              padding: EdgeInsets.only(right: 10),
              alignment: Alignment.center,
              child: Text("完成", style: TextStyle(color: Colors.cyan, fontSize: 16),),
            ),
            onTap: (){
              Navigator.pop(context, 1);
              //Navigator.pushNamedAndRemoveUntil(context, '/ActivityInfo',ModalRoute.withName('/main'),arguments: {"actid": widget.activity.actid});
              // .pushReplacementNamed(context, '/ActivityInfo', arguments: {"actid": widget.activity.actid});
            },
          )
        ],
      ),
      body: buildContent(),
    );
  }

  //创建订单二维码
  Widget buildContent(){
    return Column(
      children: [
        MyDivider(),
        Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(IconFont.icon_goumaichenggong, color: Colors.cyan, size: 23,),
              SizedBox(width: 10,),
              Text('购买成功！', style: TextStyle(color: Colors.black87, fontSize: 16),)
            ],
          ),
        ),
        SizedBox(height: 10,),
        buildGPActivity()
      ],
    );
  }

  Widget buildGPActivity(){
    return InkWell(
      onTap: (){
        Navigator.pushReplacementNamed(context, '/GoodPriceInfo', arguments: {"goodprice": widget.goodPiceModel});
      },
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child:  Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRectOhterHeadImageContainerByWidthNoEvent(
              imageUrl: widget.goodPiceModel.pic, pagewidth: 150, pageheight: 150,),
            SizedBox(width: 10,),
            Expanded(
              child: Container(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(widget.goodPiceModel.title, style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('下单时间: ${widget.goodPiceModel.createtime}',style: TextStyle(color: Colors.black45, fontSize: 12, )),
                          ],
                        )
                      ],
                    )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("x" + widget.productnum.toString(), style: TextStyle(color: Colors.black45),),
                        Row(
                          children: [
                            Text("￥", style: TextStyle( fontSize: 12),),
                            Text(widget.gpprice.toString(), style: TextStyle(fontSize: 14),)
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


