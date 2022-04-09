import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../model/bugsuggestion/bug.dart';
import '../../../service/imservice.dart';
import '../../../common/iconfont.dart';
import '../../../util/showmessage_util.dart';
import '../../../util/common_util.dart';
import '../../../util/imhelper_util.dart';
import '../../../widget/circle_headimage.dart';
import '../../../widget/icontext.dart';
import '../../../global.dart';

class BugList extends StatefulWidget {
  @override
  _BugListState createState() => _BugListState();
}

class _BugListState extends State<BugList> {
  final ImService _imService = new ImService();
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  ImHelper _imHelper = new ImHelper();
  List<Bug> bugs = [];
  bool _ismore = true;
  bool isEnter = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _getBugList() async {
    bugs = await _imService.getBugList(Global.profile.user!.uid, Global.profile.user!.token!, 0, errorResponse);
    await islike();

    _refreshController.refreshCompleted();
    if(mounted)
      setState(() {

      });
  }

  void _onLoading() async{
    if(!_ismore) return;
    final moredata = await _imService.getBugList(Global.profile.user!.uid, Global.profile.user!.token!, bugs.length, errorResponse);

    if(moredata.length > 0)
      bugs = bugs + moredata;

    if(moredata.length >= 25)
      _refreshController.loadComplete();
    else{
      _ismore = false;
      _refreshController.loadNoData();
    }

    await islike();


    if(mounted)
      setState(() {

      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade100,
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: bugs.length >= 25,
          onRefresh: _getBugList,
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
          child: _refreshController.headerStatus == RefreshStatus.completed && bugs.length == 0 ? Center(
            child: Text('还没有人提交Bug',
              style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
          ) : ListView(
            addAutomaticKeepAlives: true,
            children: buildBugContent(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            mini: true,
            onPressed: (){},
            heroTag: UniqueKey(),
            backgroundColor: Colors.white.withAlpha(209),
            child: IconButton(
              icon: Icon(IconFont.icon_bianji2, color: Colors.black54, size: 19,),
              onPressed: (){
                Navigator.pushNamed(context, '/BugReport');
              },
            )) ,
    );
  }


  List<Widget> buildBugContent(){
    List<Widget> widgets = [];
    widgets.add(SizedBox(height: 10,));
    if(bugs != null) {
      bugs.forEach((e) {
        widgets.add(
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.all(
                    Radius.circular(5))),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: InkWell(
                onTap: (){
                  Navigator.pushNamed(context, '/BugInfo', arguments: {"bugid": e.bugid});
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NoCacheCircleHeadImage(imageUrl: e.user!.profilepicture!, uid: e.user!.uid,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.user!.username, style: TextStyle(color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.bold),),
                            Text(CommonUtil.datetimeFormat(DateTime.parse(e.createtime)), style: TextStyle(color: Colors.black87, fontSize: 14, )),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: Text(e.content, style: TextStyle(color: Colors.black87, fontSize: 14, ),),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconText(
                          e.likenum.toString() == "0" ? '点赞':e.likenum.toString(),
                          padding: EdgeInsets.only(right: 2),
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                          icon: e.islike ? Icon(IconFont.icon_zan1, color: Global.profile.backColor,size: 19,): Icon(IconFont.icon_aixin, color: Colors.black54,size: 19,),
                          onTap: () async {
                            if(isEnter) {
                              isEnter = false;
                              bool ret = false;
                              if (e.islike) {
                                ret = await _imService.delBugLike(
                                    e.bugid,
                                    Global.profile.user!.uid,
                                    Global.profile.user!.token!, errorResponse);
                                e.likenum -= 1;
                                e.islike = false;
                              }
                              else {
                                ret = await _imService.updateBugLike(
                                    e.bugid,
                                    Global.profile.user!.uid,
                                    Global.profile.user!.token!, errorResponse);
                                e.likenum += 1;
                                e.islike = true;
                              }
                              if (ret) {
                                isEnter = true;
                                setState(() {});
                              }
                            }
                          },
                        ),
                        SizedBox(width: 20,),
                        IconText(
                          e.commentcount.toString() == "0" ? '评论' : e.commentcount.toString(),
                          padding: EdgeInsets.only(right: 2),
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                          icon: Icon(IconFont.icon_liuyan, color: Colors.black45, size: 19,),
                          onTap: (){
                            Navigator.pushNamed(context, '/BugInfo', arguments: {"bugid": e.bugid}).then((val){
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )
            ),
          )
        );
      });
    }

    return widgets;
  }

  Future<void> islike() async {
    for(int i = 0; i < bugs.length; i++){
      await _imHelper.selBugAndSuggestState(bugs[i].bugid, Global.profile.user!.uid, 0, (List<String> actid){
        if(actid.length > 0)
          bugs[i].islike = true;
      });
    }
  }

  errorResponse(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}
