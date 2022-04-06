import 'package:flutter/material.dart';

import '../../widget/icontext.dart';
import '../../widget/circle_headimage.dart';
import '../../util/imhelper_util.dart';
import '../../common/iconfont.dart';
import '../../model/grouppurchase/goodpice_model.dart';
import '../../global.dart';

class MyCollectionGoodPrice extends StatefulWidget{

  @override
  _MyCollectionGoodPriceState createState() => _MyCollectionGoodPriceState();
}

class _MyCollectionGoodPriceState extends State<MyCollectionGoodPrice> {
  List<GoodPiceModel> _goodPriceModels = [];
  ImHelper _imHelper = new ImHelper();
  bool _isPageLoad = false;

  getMyCollection() async {

    _goodPriceModels = await _imHelper.selGoodPriceCollectionByUid(Global.profile.user!.uid);
    _isPageLoad = true;
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getMyCollection();
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
        title:  Text('收藏的商家活动',textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: _isPageLoad ?  ((_goodPriceModels == null || _goodPriceModels.length == 0) ? Center(
        child: Text('还没有收藏的商家活动', style: TextStyle(color: Colors.black54, fontSize: 14, ),),
      ) : ListView(
        children: buildProductContent(_goodPriceModels),
      )) : Center(
        child: CircularProgressIndicator(
          valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
        ),
      )
    );
  }

  Widget buildPageView(List<GoodPiceModel> goodPrices){
    return RefreshIndicator(
      color: Global.profile.backColor,
      onRefresh: ()async {
        getMyCollection();
      },
      child:  Column(
        children: [
          Expanded(
              child: Container(
                child: ListView(
                  children: buildProductContent(_goodPriceModels),
                ),
              )
          )
        ],
      ),
    );
  }

  List<Widget> buildProductContent(List<GoodPiceModel> goodPiceModels){


    List<Widget> widgets = [];

    widgets.add(SizedBox(height: 7,));
    for(int i=0; i < goodPiceModels.length; i++){
      GoodPiceModel goodPiceModel = goodPiceModels[i];
      Widget price = SizedBox.shrink();
      price = Text('${goodPiceModel.mincost}元' , style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, );



      double temheight = 10;
      Widget tag = SizedBox.shrink();
      List<Widget> wtag = [];
      wtag.add(SizedBox.shrink());

      if(goodPiceModel.tag != null && goodPiceModel.tag.isNotEmpty){
        List<String> stag = goodPiceModel.tag.split(",");
        stag.forEach((e) {
          wtag.add(
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                child: Text(e, style: TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold),),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(5)
                  ),
                ),
              )
          );

          wtag.add(
              SizedBox(width: 5)
          );
        });

        tag = Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: wtag,
        );
      }

      widgets.add(
          InkWell(
            child: Container(
              margin: EdgeInsets.only(left: 7, right: 7, bottom: 7),
              child: Padding(
                padding: EdgeInsets.only(left: 9, right: 9, bottom: 9, top: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRectOhterHeadImageContainerByWidthNoEvent(imageUrl: goodPiceModel.pic, pagewidth: 110, pageheight: 110,),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(goodPiceModel.title, maxLines: 2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                            height: 40,
                          ),

                          SizedBox(height: 6,),
                          tag,
                          SizedBox(height: 3,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              price,
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconText(
                                    goodPiceModel.commentnum.toString(),
                                    padding: EdgeInsets.only(right: 2),
                                    style: TextStyle(color: Colors.black54, fontSize: 10),
                                    icon: Icon(IconFont.icon_liuyan, color: Colors.black45, size: 12,),
                                    onTap: (){
                                    },
                                  ),
                                  SizedBox(width: 10,),
                                  IconText(
                                    goodPiceModel.satisfactionrate == 0 ? '0' : '${(goodPiceModel.satisfactionrate * 100).toInt()}%',
                                    padding: EdgeInsets.only(right: 2),
                                    style: TextStyle(color: Colors.black54, fontSize: 10),
                                    icon: Text('赞', style: TextStyle(fontSize: 8),),
                                    onTap: (){},
                                  ),
                                  SizedBox(width: 10,)
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)
                ),
              ),
            ),
            onTap: (){
              Navigator.pushNamed(context, '/GoodPriceInfo', arguments: {"goodprice": goodPiceModel});
            },
          )
      );
    }
    return widgets;
  }
}


