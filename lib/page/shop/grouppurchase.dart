import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../service/gpservice.dart';
import '../../common/iconfont.dart';
import '../../util/imhelper_util.dart';
import '../../model/grouppurchase/goodpice_model.dart';
import '../../widget/shareview.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/icontext.dart';
import '../../global.dart';


class GroupPurchase extends StatefulWidget {
  @override
  _GroupPurchaseState createState() => _GroupPurchaseState();
}

class _GroupPurchaseState extends State<GroupPurchase> {
  int type = -1;
  bool _ismore = true;
  final GPService _gpService = new GPService();
  final ImHelper _imHelper = new ImHelper();
  List<GoodPiceModel> goodPiceModels = [];
  List<int> goodpricenotinteresteduids = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  @override
  void initState() {
    // 生命周期函数
    super.initState();
  }

  void _getGoodPriceList() async {
    goodPiceModels = await _gpService.getRecommendGoodPriceList(-1, 0);
    if(Global.profile.user != null) {
      goodpricenotinteresteduids = await _imHelper.getGoodPriceNotInteresteduids(Global.profile.user!.uid);
    }
    if(goodPiceModels.length < 25){
      _ismore = false;
    }

    _refreshController.refreshCompleted();
    if(mounted)
      setState(() {

      });
  }

  void _onLoading() async{
    if(!_ismore) return;

    final moredata = await  _gpService.getRecommendGoodPriceList(
        -1, goodPiceModels.length);

    if(moredata.length > 0)
      goodPiceModels = goodPiceModels + moredata;

    if(moredata.length >= 25)
      _refreshController.loadComplete();
    else{
      _ismore = false;
      _refreshController.loadNoData();
    }

    if(mounted)
      setState(() {

      });
  }

  @override
  Widget build(BuildContext context) {
    Widget searchWidget = Container(
      width: double.infinity,
      decoration: new BoxDecoration(
          color: Colors.white
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: InkWell(
                    child: Container(
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        height: 39,
                        decoration: new BoxDecoration(
                          color: Colors.black12.withAlpha(10),
                          borderRadius: new BorderRadius.all(new Radius.circular(9.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.search, color: Colors.black38, size: 19,),
                            Text('搜索商家活动', style: TextStyle(color: Colors.black38, fontSize: 14),)
                          ],
                        )
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, '/SearchProduct');
                    },
                  )
              ),
              SizedBox(width: 10,),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        Global.profile.locationGoodPriceName.length > 3 ? Global.profile.locationGoodPriceName.substring(0, 3) : Global.profile.locationGoodPriceName,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                    ),
                    Icon(Icons.keyboard_arrow_down,),
                  ],),
                onTap: (){
                  Navigator.pushNamed(context, '/ListViewProvince', arguments:null).then((dynamic value){
                    if(value != null) {
                      if(Global.profile.locationGoodPriceCode != value["code"].toString()){
                        Global.profile.locationGoodPriceCode = value["code"].toString();
                        Global.profile.locationGoodPriceName = value["name"].toString();
                        Global.saveProfile();
                        _getGoodPriceList();
                      }
                    }
                  });
                },
              )

            ],
          ),
        ],
      ),
    );
    double statusBarHeight = MediaQuery.of(context).padding.top;
    //print(statusBarHeight);
    return  new Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(statusBarHeight + 100),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 10, right: 10),
          margin: EdgeInsets.only(top: statusBarHeight+10),
          height: 50,
          child: searchWidget,
          ),
        ),
      body: Padding(
        padding: EdgeInsets.only(top: 1),
        child:SmartRefresher(
          enablePullDown: true,
          enablePullUp: goodPiceModels.length >= 25,
          onRefresh: _getGoodPriceList,
          header: MaterialClassicHeader(distance: 100, ),
          footer: CustomFooter(
            builder: (BuildContext context,LoadStatus? mode){
              Widget body ;
              if(mode==LoadStatus.idle){
                body =  Text("加载更多", style: TextStyle(color: Colors.black45, fontSize: 13));
              }
              else if(mode==LoadStatus.loading){
                body =  Center(
                  child: CircularProgressIndicator(
                    valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                  ),
                );
              }
              else if(mode == LoadStatus.failed){
                body = Text("加载失败!点击重试!", style: TextStyle(color: Colors.black45, fontSize: 13));
              }
              else if(mode == LoadStatus.canLoading){
                body = Text("放开我,加载更多!", style: TextStyle(color: Colors.black45, fontSize: 13));
              }
              else{
                body = Text("—————— 我也是有底线的 ——————", style: TextStyle(color: Colors.black45, fontSize: 13));
              }
              print(mode);
              return Container(
                height: 55.0,
                child: Center(child:body),
              );
            },
          ),
          controller: _refreshController,
          onLoading: _onLoading,
          child: _refreshController.headerStatus == RefreshStatus.completed && goodPiceModels.length == 0 ? Center(
            child: Text('emmm...还没有商家提供服务',
              style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
          ) : ListView(
            addAutomaticKeepAlives: true,
            children: buildProductContent(goodPiceModels),
          ),
        ),
      ),
    );
  }

  List<Widget> buildProductContent(List<GoodPiceModel> goodPiceModels){
    List<Widget> widgets = [];
    widgets.add(SizedBox(height: 7,));
    for(int i=0; i < goodPiceModels.length; i++){
      GoodPiceModel goodPiceModel = goodPiceModels[i];
      Widget price = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${goodPiceModel.mincost}—${goodPiceModel.maxcost}元' , style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, )
        ],
      );

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
          ShareView(
            activityHomeLongPress: (bool isNotInterests) async {
              if(isNotInterests) {
                List<int> goodpricenotinteresteduids = await _imHelper.getGoodPriceNotInteresteduids(Global.profile.user!.uid);
                List<GoodPiceModel> emptyList = [];
                goodPiceModels.forEach((e) {
                  emptyList.add(e);
                });

                emptyList.forEach((e) {
                  if(goodpricenotinteresteduids != null && goodpricenotinteresteduids.contains(e.uid)){
                    goodPiceModels.remove(e);
                  }
                });

                setState(() {
                });
              }
            },
            activityHomeOnTap: (){
              Navigator.pushNamed(context, '/GoodPriceInfo', arguments: {"goodprice": goodPiceModel});
            },
            sharedtype: "1",
            actid: goodPiceModel.goodpriceid,
            createuid: goodPiceModel.uid,
            contentid: goodPiceModel.goodpriceid,
            content: goodPiceModel.title,
            image: goodPiceModel.pic,
            icon: Container(
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
                              Container(
                                padding: EdgeInsets.only(top: 1, bottom: 2, left: 5, right: 5),
                                alignment: Alignment.center,
                                child: Text('${goodPiceModel.brand}', style: TextStyle(color: Colors.white, fontSize: 10),),
                                decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.circular((5.0)), // 圆角度
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Global.profile.backColor!,
                                      Colors.deepOrange
                                    ]
                                  )
                                ),
                              ),
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
          )
      );
    }
    return widgets;
  }

}


