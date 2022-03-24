import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../global.dart';
import '../../../model/bugsuggestion/moment.dart';
import '../../../service/imservice.dart';
import '../../../util/showmessage_util.dart';
import '../../../util/imhelper_util.dart';
import '../../../page/user/square/momentwidget.dart';
import '../../../bloc/user/authentication_bloc.dart';

class MomentList extends StatefulWidget {
  GlobalKey<ScaffoldState> indexkey;
  Function initSubject;
  MomentList(this.indexkey, this.initSubject);

  @override
  _MomentListState createState() => _MomentListState();
}

class _MomentListState extends State<MomentList> {
  List<Moment> moments = [];
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  ImHelper _imHelper = new ImHelper();
  bool _ismore = true;
  final ImService _imService = new ImService();
  List<int> _notinteresteduids = [];


  void _getMomentList() async {
    if(Global.profile.user != null) {
      moments = await _imService.getMomentList(0, Global.profile.user!.subject, _errorResponse);
      _notinteresteduids = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
      await _islike();
    }
    else{
      moments = await _imService.getMomentList(0, "", _errorResponse);
    }

    _refreshController.refreshCompleted();
    if(mounted)
      setState(() {

      });
  }

  void _onLoading() async{
    if(!_ismore) return;

    List<Moment> moredata = [];

    if(Global.profile.user != null) {
      moredata = await _imService.getMomentList(
          moments.length, Global.profile.user!.subject, _errorResponse);
    }
    else{
      moredata = await _imService.getMomentList(
          moments.length, "", _errorResponse);
    }

    if(moredata.length > 0)
      moments = moments + moredata;

    if(moredata.length >= 25)
      _refreshController.loadComplete();
    else{
      _ismore = false;
      _refreshController.loadNoData();
    }

    if(Global.profile.user != null) {
      await _islike();
    }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }



  @override
  Widget build(BuildContext context) {


    double statusBarHeight = MediaQuery.of(context).padding.top;
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
                            Text('大家都在搜什么', style: TextStyle(color: Colors.black38, fontSize: 14),)
                          ],
                        )
                    ),
                    onTap: (){
                      Navigator.pushNamed(context, '/SearchMoment');
                    },
                  )
              ),
              SizedBox(width: 10,),
              Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          '话题',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                      ),
                    ],),
                  onTap: (){
                    widget.initSubject();
                    widget.indexkey.currentState!.openEndDrawer();
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      buildWhen: (previousState, state) {
        if(state is AuthenticationAuthenticated || state is LoginOuted ) {
          _getMomentList();
          return true;
        }
        else {
          return false;
        }
      },

      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: (){
                if(Global.profile.user == null) {
                  Navigator.pushNamed(context, '/Login').then((value) {
                    if(Global.profile.user != null) {
                      Navigator.pushNamed(context, '/MomentReport').then((value) {
                        if(value != null && value != "")
                          _getMomentList();
                      });
                    }
                  });
                }
                else{
                  Navigator.pushNamed(context, '/MomentReport').then((value) {
                    if(value != null && value != "")
                      _getMomentList();
                  });
                }
              },
              child: Icon(Icons.add_a_photo,  color:  Global.profile.backColor)
          ),
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
          body: SmartRefresher(
            enablePullDown: true,
            enablePullUp: moments.length >= 25,
            onRefresh: _getMomentList,
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
            child: _refreshController.headerStatus == RefreshStatus.completed && moments.length == 0 ? Center(
              child: Text('这里空空的',
                style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
            ) : ListView(
              addAutomaticKeepAlives: true,
              children: _buildMomentContent(),
            ),
          ),
        );
      });
  }

  List<Widget> _buildMomentContent(){
    List<Widget> lists = [];
    moments.forEach((element) {
      if(_notinteresteduids != null && _notinteresteduids.length > 0) {
        if (!_notinteresteduids.contains(element.user!.uid)){
          lists.add(Padding(
            padding: EdgeInsets.only(left: 10, top: 10),
            child: MomentWidget(moment: element, refresh: _getMomentList),
          ));
        }
      }
      else {
        lists.add(Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: MomentWidget(moment: element,  refresh:  _getMomentList),
        ));
      }
    });

    return lists;
  }

  _errorResponse(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}
