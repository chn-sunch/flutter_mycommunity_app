import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/activity/activity_city_bloc.dart';
import '../../util/showmessage_util.dart';
import '../../common/iconfont.dart';
import '../../global.dart';
import 'cityactivitywidget.dart';

class CityActivity extends StatefulWidget{
  final Function? parentJumpShop;

  CityActivity({this.parentJumpShop});

  @override
  _CityActivityState createState() => _CityActivityState();
}

class _CityActivityState extends State<CityActivity>  with  AutomaticKeepAliveClientMixin  {
  late CityActivityDataBloc _cityActivityDataBloc;

  String citycode = "";
  double _scrollThreshold = 100;
  bool _lock = false;//防止滚动条多次执行加载更多
  ScrollController _scrollControllerUserContent = new ScrollController(initialScrollOffset: 0);
  double _lastScroll = 0.0;
  bool _isTop = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    citycode = Global.profile.locationCode;
    _cityActivityDataBloc = BlocProvider.of<CityActivityDataBloc>(context);
    _cityActivityDataBloc.add(PostFetched(citycode));

    _scrollControllerUserContent.addListener(() {
      final maxScrollUser = _scrollControllerUserContent.position.maxScrollExtent;
      double currentUserScroll = _scrollControllerUserContent.position.pixels;

      double currentScroll = _scrollControllerUserContent.position.pixels;
      if(currentScroll < _lastScroll){
        setState(() {
          if(currentScroll == 0){
            _isTop = false;
          }
          else
            _isTop = true;
        });
      }
      else{
        setState(() {
          _isTop = false;
        });
      }


      _lastScroll = currentScroll;

      if (maxScrollUser - currentUserScroll <= _scrollThreshold && !_lock) {
        _cityActivityDataBloc.add(PostFetched(citycode));
        _lock = true;//加载完毕后再解锁
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollControllerUserContent.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);//页面不会被dispose
    Widget maxWidget = SizedBox.shrink();

    citycode = Global.profile.locationCode;
//    print(_scrollController.position.viewportDimension	);
    return Scaffold(
      floatingActionButton: _isTop? FloatingActionButton(
          mini: true,
          heroTag: UniqueKey(),
          backgroundColor: Colors.white,
          onPressed: (){
            _scrollControllerUserContent.jumpTo(0);
            setState(() {
              _isTop = false;
            });
          },
          child: Icon(IconFont.icon_rocket, color: Colors.black45,)) : SizedBox.shrink(),
      body: RefreshIndicator(
          color: Global.profile.backColor,
          onRefresh: () async{
            _cityActivityDataBloc.add(Refreshed(Global.profile.locationCode));
          },
          child: Container(
              child: BlocBuilder<CityActivityDataBloc, CityActivityState>(
                  bloc: _cityActivityDataBloc,
                  builder: (context, state){
                    List<Widget> lists = [];
                    if (state is PostFailure) {
                      ShowMessage.showToast("请检查网络，再试一下!");
                      return buildReLoadData();
                    }
                    if (state is PostSuccess) {
                      if(state.hasReachedMax){
                        //如果已经最大增加一个刷新按钮
                        maxWidget = InkWell(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 50),
                            height: 50,
                            alignment: Alignment.center,
                            child: Text('已经到底了，刷新一下试试吧!', style: TextStyle(color: Colors.blue, fontSize: 13), ),
                          ),
                          onTap: (){
                            _cityActivityDataBloc.add(Refreshed(Global.profile.locationCode));
                          },
                        );
                      }

                      if (state.activitys !=null && state.activitys!.isEmpty) {
                        if(state.isRefreshed){
                        }
                        return InkWell(
                          child: Column(
                              children: [
                                Expanded(child: Container(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text('emmm...这里还没有活动.',
                                      style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
                                  ),
                                )),
                              ]),
                          onTap: (){
                            _cityActivityDataBloc.add(Refreshed(Global.profile.locationCode));
                          },
                        );
                      }
                      if (state.activitys !=null && state.activitys!.length > 0){
                        state.activitys!.forEach((element) {
                          lists.add(Padding(
                            padding: EdgeInsets.only(left: 10, top: 10),
                            child: CityActivityWidget(activity: element,),
                          ));
                        });
                        lists.add(maxWidget);

                        _lock = false;
                        return MediaQuery.removePadding(
                            removeTop: true,
                            context: context,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    child: ListView(
                                      addAutomaticKeepAlives: true,
                                      controller: _scrollControllerUserContent,
                                      children: lists,
                                    ),
                                  )
                                ),
                              ],
                            )
                        );
                      }
//                  flutter applyViewportDimension
                    }
                    else {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Global.profile.backColor),
                        ),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Global.profile.backColor),
                      ),
                    );
                  })
          )),
    );
  }

  Widget buildReLoadData(){
    return InkWell(
      child: Center(
        child: Text('轻触重试', style: TextStyle(color: Colors.black),),
      ),
      onTap: (){
        _cityActivityDataBloc.add(PostFetched(citycode));
      },
    );
  }

  Container buildLoading(){
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
          ),
        ),
      ),);
  }
}


