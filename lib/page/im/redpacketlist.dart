import 'package:flutter/material.dart';
import '../../model/im/redpacket.dart';
import '../../model/im/redpacketdetail.dart';
import '../../service/imservice.dart';
import '../../util/showmessage_util.dart';
import '../../widget/my_divider.dart';
import '../../widget/circle_headimage.dart';
import '../../global.dart';

class RedPacketList extends StatefulWidget {
  Object? arguments;
  RedPacketModel? redPacketModel;
  double receiveMoney = 0;

  RedPacketList({this.arguments}){
    if(arguments != null){
      redPacketModel = (arguments as Map)["redPacketModel"];
      receiveMoney = (arguments as Map)["receiveMoney"];
    }
  }

  @override
  _RedPacketListState createState() => _RedPacketListState();
}

class _RedPacketListState extends State<RedPacketList> {
  ImService _imService = ImService();
  List<RedPacketDetail> redPackDetails = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRedPacketDetail();
  }

  getRedPacketDetail() async {
    redPackDetails = await _imService.getRedPacketDetail(Global.profile.user!.uid, Global.profile.user!.token!,
        widget.redPacketModel!.redpacketid, (code,msg){
      ShowMessage.showToast(msg);
    });
    if(redPackDetails != null && redPackDetails.length > 0){
      if(mounted) {
        setState(() {

        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20 ),
          onPressed: (){
            Navigator.pop(context,"return");
          },
        ),
        centerTitle: true,
        title: Text('', style:  TextStyle(color:  Colors.black87, fontSize: 16),),
      ),
      body: Column(
        children: [
          buildHeadInfo(),
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            color: Colors.white,
            child: Text('一个红包共${widget.redPacketModel!.amount}元', style: TextStyle(color: Colors.black54, fontSize: 13),),
          ),
          MyDivider(),
          redPackDetails != null && redPackDetails.length > 0 ? Expanded(
            child: buildRedPackList() ,
          ): SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget buildHeadInfo(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NoCacheClipRRectOhterHeadImage(imageUrl: widget.redPacketModel!.profilepicture, width: 66, uid: widget.redPacketModel!.uid,),
        SizedBox(height: 5,),
        Text('来自${widget.redPacketModel!.username}的红包', style: TextStyle(color:  Colors.black87, fontSize: 16),),
        SizedBox(height: 5,),
        Text('${widget.redPacketModel!.content}', style: TextStyle(color: Colors.black45, fontSize: 14)),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${widget.receiveMoney}', style: TextStyle(color: Colors.red, fontSize: 29),),
            Text('元', style: TextStyle(color: Colors.red, fontSize: 12),),
          ],
        ),
        SizedBox(height: 5,),
      ],
    );
  }

  Widget buildRedPackList(){
    List<Widget> details = [];
    redPackDetails.forEach((element) {
      details.add(Container(
        padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NoCacheClipRRectHeadImage(imageUrl: element.profilepicture, width: 39, uid: element.uid,),
                  SizedBox(width: 5,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(element.username, style: TextStyle(color: Colors.black54, fontSize: 12, ),),
                      SizedBox(height: 5,),
                      Text(element.createtime, style: TextStyle(color: Colors.black54, fontSize: 12, ))
                    ],
                  )
                ],
              ),
              Container(
                child: Text('${element.fund}元'),
              )
            ],
          )
      ));
    });

    return Container(
      color: Colors.white,
      child: ListView(
        children: details,
      ),
    );
  }
}
