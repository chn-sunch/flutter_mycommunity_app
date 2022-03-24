import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../service/imservice.dart';
import '../../../util/imhelper_util.dart';
import '../../../util/showmessage_util.dart';

import '../../../model/bugsuggestion/moment.dart';

import '../../../global.dart';
import 'momentwidget.dart';

class SearchMomentResultPage extends StatefulWidget {
  Object? arguments;
  String content = "";
  SearchMomentResultPage({this.arguments}){
    content = (arguments as Map)["content"];
  }

  @override
  _SearchMomentResultPageState createState() => _SearchMomentResultPageState();
}

class _SearchMomentResultPageState extends State<SearchMomentResultPage> {
  SearchBarStyle searchBarStyle = const SearchBarStyle();
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  ImService _imService = ImService();
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
  final ImHelper _imHelper = new ImHelper();
  List<Moment> moments = [];
  bool _ismore = true;
  Widget widgetMessage = Center(child: Text('没搜索到你想要的内容哦', style: TextStyle(color: Colors.black54, fontSize: 15),));
  List<int> _notinteresteduids = [];


  void _onRefresh() async{
    moments = await _imService.searchMoment(0, widget.content, errorCallBack);


    if(Global.profile.user != null) {
      _notinteresteduids = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
      await _islike();
    }


    if(moments.length < 25){
      _ismore = false;
    }
    _refreshController.refreshCompleted();
    if(mounted)
      setState(() {

      });
  }

  Future<void> _islike() async {
    for(int i = 0; i < moments.length; i++){
      await _imHelper.selBugAndSuggestState(moments[i].momentid, Global.profile.user!.uid, 2, (List<String> actid){
        if(actid.length > 0)
          moments[i].islike = true;
      });
    }
  }


  void _onLoading() async{
    if(!_ismore) return;

    final moredata = await  _imService.searchMoment(moments.length, widget.content, errorCallBack);

    if(moredata.length > 0) {
      moments = moments + moredata;
    }
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
          enablePullUp: moments.length >= 25,
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
          child: moments.length == 0 && _refreshController.headerStatus == RefreshStatus.completed ? widgetMessage : ListView(
              addAutomaticKeepAlives: true,
              children: buildProductContent()
          )
      ),
    );
  }
  // inputSelects(),

  List<Widget> buildProductContent(){
    List<Widget> lists = [];
    moments.forEach((element) {
      if(_notinteresteduids != null && _notinteresteduids.length > 0) {
        if (!_notinteresteduids.contains(element.user!.uid)){
          lists.add(Padding(
            padding: EdgeInsets.only(left: 10, top: 10),
            child: MomentWidget(moment: element, refresh: _onRefresh),
          ));
        }
      }
      else {
        lists.add(Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: MomentWidget(moment: element,  refresh:  _onRefresh),
        ));
      }
    });

    return lists;
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
