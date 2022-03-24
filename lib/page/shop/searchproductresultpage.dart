import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../service/gpservice.dart';
import '../../util/imhelper_util.dart';
import '../../util/showmessage_util.dart';
import '../../common/iconfont.dart';
import '../../widget/icontext.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/shareview.dart';
import '../../model/grouppurchase/goodpice_model.dart';
import '../../global.dart';

class SearchProductResultPage extends StatefulWidget {
  Object? arguments;
  String content = "";
  SearchProductResultPage({this.arguments}){
    content = (arguments as Map)["content"];
  }

  @override
  _SearchProductResultPageState createState() => _SearchProductResultPageState();
}

class _SearchProductResultPageState extends State<SearchProductResultPage> {
  SearchBarStyle searchBarStyle = const SearchBarStyle();
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  Icon icon = const Icon(Icons.search, size: 20, color: Colors.grey);
  List<String> keys = [];
  int sortIndex = 0;//如果等于1 则进行点赞排序
  String ordertype = "score";
  String citycode = Global.profile.locationGoodPriceCode;
  bool isAllCity = false;
  double cityDropHeight = 0.0;
  ScrollController _scrollControllerContent = new ScrollController(initialScrollOffset: 0);
  late TextEditingController _textEditingController ;
  int selected = -1;
  bool isgotogoodprice = false;
  final ImHelper imHelper = new ImHelper();
  List<GoodPiceModel> goodPiceModels = [];
  GPService gpService = GPService();
  List<int> goodpricenotinteresteduids = [];
  bool _ismore = true;
  Widget widgetMessage = Center(child: Text('没搜索到你想找的活动', style: TextStyle(color: Colors.black54, fontSize: 15),));

  void _onRefresh() async{
    goodPiceModels = await gpService.searchProduct(
        ordertype, citycode,  0, isAllCity, widget.content, errorCallBack);
    if(Global.profile.user != null) {
      goodpricenotinteresteduids = await imHelper.getGoodPriceNotInteresteduids(Global.profile.user!.uid);
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

    final moredata = await  gpService.searchProduct(
        ordertype, citycode, goodPiceModels.length, isAllCity, widget.content, errorCallBack);

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

  errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _textEditingController = TextEditingController.fromValue(TextEditingValue(
        text: widget.content,
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: widget.content.length)))
    );
    if(citycode == null || citycode.isEmpty)
      citycode = "allCode";

    ImHelper _imHelper = ImHelper();
    _imHelper.saveSearchHistory(0, widget.content);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollControllerContent.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        titleSpacing: 0,
        leading: SizedBox.shrink(),
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        title:Padding(
            padding: EdgeInsets.only(right: 10, top: 10),
            child: Container(
              height: 46,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(icon: Icon(Icons.arrow_back_ios, size: 18, color: Colors.black87,), onPressed: (){
                      Navigator.pop(context);
                    },),
                    Expanded(
                        child:  InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: searchBarStyle.borderRadius,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child:  TextField(
                                controller: _textEditingController,
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                style: TextStyle(color: Colors.black87, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: widget.content,
                                  hintStyle: TextStyle(color: Colors.black87, fontSize: 14),
                                  border: InputBorder.none,
                                  icon: icon,
                                ),
                              ),
                            ),
                          ),
                          onTap: (){
                          },
                        )
                    ),
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 10),
                        alignment: Alignment.centerLeft,
                        color: Colors.transparent,
                        child: Text("取消", style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ),
                      onTap: (){
                        Navigator.pop(context);
                      },
                    )
                  ]
              ),
            )
        ),
      ),
      body:  SmartRefresher(
          enablePullDown: true,
          enablePullUp: goodPiceModels.length >= 25,
          onRefresh: _onRefresh,
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
          child: goodPiceModels.length == 0 && _refreshController.headerStatus == RefreshStatus.completed ? widgetMessage : ListView(
              addAutomaticKeepAlives: true,
              children: buildProductContent()
          )
      ),
    );
  }
  // inputSelects(),

  List<Widget> buildProductContent(){
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
                List<int> goodpricenotinteresteduids = await imHelper.getGoodPriceNotInteresteduids(Global.profile.user!.uid);
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
              _gotoGoodPrice(goodPiceModel.goodpriceid);
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

  //查看goodprice
  Future<void> _gotoGoodPrice(String goodpriceid) async {
    GoodPiceModel? goodprice = await gpService.getGoodPriceInfo(goodpriceid);
    if (goodprice != null) {
      Navigator.pushNamed(
          context, '/GoodPriceInfo', arguments: {
        "goodprice": goodprice
      });
    }
  }
}

class InputSelect1 extends StatelessWidget {
  const InputSelect1(
      {required this.index,
        required this.widget,
        required this.parent,
        required this.choice})
      : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: index == 0 ? EdgeInsets.all(0) : EdgeInsets.only(left: 8),
      child: ChoiceChip(
          label: Text(choice),
          //未选定的时候背景
          selectedColor: Global.profile.backColor,
          backgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          labelStyle: parent.selected == index ? TextStyle(fontSize: 12.0, color: Colors.white): TextStyle(fontSize: 12.0, color: Colors.black),
          labelPadding: EdgeInsets.only(left: 8.0, right: 8.0),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: (bool value) {
            parent.onSelectedChanged(index);
          },
          selected: parent.selected == index),
    );
  }

  final int index;
  final widget;
  final parent;
  final String choice;
}


class SearchBarStyle {
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const SearchBarStyle(
      {this.backgroundColor = const Color.fromRGBO(142, 142, 147, .15),
        this.padding = const EdgeInsets.all(5.0),
        this.borderRadius: const BorderRadius.all(Radius.circular(5.0))});
}
