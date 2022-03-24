import 'package:badges/badges.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/im/im_bloc.dart';
import '../../model/im/grouprelation.dart';
import '../../model/im/sysmessage.dart';
import '../../common/iconfont.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../widget/my_divider.dart';
import '../../widget/circle_headimage.dart';
import '../../global.dart';
import 'specialtextspan.dart';

class RelationList extends StatefulWidget {
  @override
  _RelationListState createState() => _RelationListState();
}
enum WhyFarther {
  im,
  addfriend,
}

class _RelationListState extends State<RelationList> {
  late ImBloc _imBloc;
  final ImHelper imHelper = ImHelper();
  final Widget _widgetFollow = Container(
    width: 50,
    height: 50,
    child: Icon(IconFont.icon_gerenzhongxin, size: 30, color: Colors.blueAccent,),
    decoration: BoxDecoration(
      color: Colors.blueAccent.shade100.withAlpha(200),
      borderRadius: BorderRadius.circular(16),
    ),
  );
  final Widget _widgetLike = Container(
    width: 50,
    height: 50,
    child: Icon(IconFont.icon_zan1, size: 30, color: Colors.pinkAccent,),
    decoration: BoxDecoration(
      color: Colors.pinkAccent.shade100.withAlpha(200),
      borderRadius: BorderRadius.circular(16),
    ),
  );
  final Widget _widgetCommentReply = Container(
    width: 50,
    height: 50,
    child: Icon(IconFont.icon_duihua, size: 30, color: Colors.greenAccent.shade700,),
    decoration: BoxDecoration(
      color: Colors.greenAccent.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imBloc = BlocProvider.of<ImBloc>(context);
    _imBloc.add(getlocalRelation(Global.profile.user!));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text('消息', style: TextStyle(color: Colors.black87, fontSize: 16), ),
          centerTitle: true,
          actions: <Widget>[
            InkWell(
              child: Container(
                margin: EdgeInsets.only(right: 10),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Text('群聊', style: TextStyle(color: Colors.black87, fontSize: 16))
                  ],
                )
              ),
              onTap: (){
                Navigator.pushNamed(context, '/CreateCommunity');
              },
            )
          ], //
        ),
        body: BlocBuilder<ImBloc, ImState>(
            buildWhen: (context, state){
              if(state is NewMessageState)
                return true;
              else
                return false;
            },
            builder: (context, state) {
              if(state is errorState){
                ShowMessage.showToast(state.error);
              }
              if(state is NewMessageState)
                return UserRelationList(state.groupRelations, state.sysMessage);
              else
                return SizedBox.shrink();
            }
        )
    );
  }

  Widget UserRelationList(List<GroupRelation> groupRelations, SysMessage sysMessage){
    Widget relations =  SizedBox.shrink();
    List<Widget> lists = [];
    lists.add(
        Container(
          margin: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                child: Column(
                  children: [
                    sysMessage.newlithumbup_count > 0 ? Badge(
                        toAnimate: false,
                        badgeContent: Text(sysMessage.newlithumbup_count > 99 ? '...' : sysMessage.newlithumbup_count.toString(),
                          style: TextStyle(fontSize: 10, color: Colors.white),),
                        child: _widgetLike) : _widgetLike,
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text('收到的赞', style: TextStyle(color: Colors.black87, fontSize: 14),),
                    )
                  ],
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/ThumbUpList').then((val) {
                    setState(() {
                      sysMessage.newlithumbup_count = 0;
                    });
                  });
                },
              ),
              InkWell(
                child:  Column(
                  children: [
                    sysMessage.follow_count > 0 ? Badge(
                        toAnimate: false,
                        badgeContent: Text(sysMessage.follow_count > 99 ? '...' : sysMessage.follow_count.toString(),
                          style: TextStyle(fontSize: 10, color: Colors.white),),
                        child: _widgetFollow) : _widgetFollow,
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text('新增关注', style: TextStyle(color: Colors.black87, fontSize: 14),),
                    )
                  ],
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/NewFollowList').then((val) {
                    setState(() {
                      sysMessage.follow_count = 0;
                    });
                  });
                },
              ),
              InkWell(
                child: Column(
                  children: [
                    sysMessage.commentreply_count > 0 ? Badge(
                        toAnimate: false,
                        badgeContent: Text(sysMessage.commentreply_count > 99 ? '...' : sysMessage.commentreply_count.toString(),
                          style: TextStyle(fontSize: 10, color: Colors.white),),
                        child: _widgetCommentReply) : _widgetCommentReply,
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text('评论回复', style: TextStyle(color: Colors.black87, fontSize: 14),),
                    )
                  ],
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/NoticeList').then((val) {
                    setState(() {
                      sysMessage.commentreply_count = 0;
                    });
                  });
                },
              ),
            ],
          ),
        )
    );

    lists.add(SizedBox(height: 20,));

    if(groupRelations != null && groupRelations.length > 0){
      lists.addAll( getRelationList(groupRelations));
    }
    else{
      lists.add(Container(
        height: 200,
        child: Center(
            child: Text('Emmm...就是没人找你聊天...', style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),)),
      ));
    }
    relations = ListView(
      children:lists,
    );

    return relations;
  }

  List<Widget> getRelationList(List<GroupRelation> groupRelations, ) {
    List<Widget> relationList = [];
    groupRelations.forEach((item) {
      if (item.newmsg != null) {
        item.newmsg = item.newmsg!.replaceAll("|sysactivitynotice:", '');
      }
      relationList.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            Stack(
              children: <Widget>[
                Container(
                  height: 45,
                  child: item.relationtype == 1 ? CommunityClipRRectHeadImage(
                    imageUrl: item.clubicon, width: 45,
                    cid: item.timeline_id, uid: Global.profile.user!.uid,) :
                  item.relationtype == 2 ? NoCacheClipRRectHeadImage(
                    imageUrl: item.clubicon!, width: 45,
                    uid: getUidByTimeline_id(item.timeline_id),) :
                  ActivityClipRRectHeadShortCacheImage(imageUrl: item.clubicon,
                    width: 45,
                    actid: item.timeline_id,
                    uid: Global.profile.user!.uid,),
                ),
                item.relationtype == 2 || item.relationtype == 3 || item.relationtype == 0 || item.relationtype == 1 ? SizedBox.shrink() : Container(
                  width: 20,
                  height: 20,
                  margin: EdgeInsets.only(top: 28, left: 28),
                  decoration: BoxDecoration(
                    borderRadius: new BorderRadius.circular((5.0)), // 圆角度
                    color: Colors.white,
                  ),
                  child: Container(
                    margin: EdgeInsets.only(top: 2, left: 2),
                    decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular((5.0)), // 圆角度
                        color: item.relationtype == 0 || item.relationtype == 3
                            ? Global.profile.backColor
                            : Colors.orangeAccent
                    ),
                    width: 15,
                    height: 15,
                    child: Icon(
                      IconFont.icon_qizi_icon, color: Colors.white, size: 14,),
//                                child: item.relationtype == 0 ? Icon(IconFont.icon_qizi_icon, color: Colors.white, size: 14,):
//                                (item.relationtype==1?Icon(IconFont.icon_shetuanxiu, color: Colors.white, size: 14,):SizedBox.shrink()),
//                              原来是活动和社团有各自的下图标现在改为只有社团带一个红旗图标
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(item.group_name1!
                                .replaceAll('\n', '').toString(),
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                            SizedBox(height: 5,),
                            item.newmsg != null ? ExtendedText(
                                item.newmsg!, maxLines: 1,
                                style: TextStyle(
                                    color: Colors.black26, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                specialTextSpanBuilder: MySpecialTextSpanBuilder(
                                  isopen: false,
                                  showAtBackground: false,
                                  isText: true,
                                  myonTap: (v){}
                                )) : Text(''),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Text(item.newmsgtime != null &&
                                  item.newmsgtime!.isNotEmpty ? item.newmsgtime!
                                  .substring(10, 16) : "",
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 13),),
                            ),

                            item.unreadcount == 0
                                ? SizedBox.shrink()
                                : Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Badge(
                                toAnimate: false,
                                badgeContent: Text(
                                  item.unreadcount >= 100 ? "..." : item
                                      .unreadcount.toString(), style: TextStyle(
                                    fontSize: 10, color: Colors.white),),
                              ),
                            ),

                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 17,),
                  MyDivider()
                ],
              ),
            )
          ],
        ),
        onTap: () {
          _imBloc.add(Already(Global.profile.user!, item.timeline_id));
          Navigator.pushNamed(
              context, '/MyMessage', arguments: {"GroupRelation": item}).then((
              val) {
            _imBloc.add(getlocalRelation(Global.profile.user!));
          });
        },
        onLongPressStart: (detail) {
          final RelativeRect position = RelativeRect.fromLTRB(
              detail.globalPosition.dx,
              detail.globalPosition.dy,
              //取text高度做弹出y坐标（这样弹出就不会遮挡文本）
              detail.globalPosition.dx,
              detail.globalPosition.dy);
          showMenu(context: context,
              position: position,
              items: <PopupMenuEntry>[
                PopupMenuItem(
                  child: InkWell(
                    child: Text('${item.istop == 0 ? "置顶" : "取消置顶"}'),
                    onTap: () {
                      if (item.istop == 0)
                        _imBloc.add(RelationTop(Global.profile.user!, item
                            .timeline_id));
                      else
                        _imBloc.add(RelationTopCancel(Global.profile.user!, item
                            .timeline_id));

                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    child: Text('删除'),
                    onTap: () {
                      _imBloc.add(RelationDel(Global.profile.user!,
                          item.timeline_id));
                      Navigator.pop(context);

                    },
                  ),
                )
              ]
          ).then((value){
            setState(() {

            });
          });
        },
      ));
      relationList.add(SizedBox(height: 10,));
    });

    if(groupRelations.isEmpty){
      relationList.add(Center(
          child: Text('Emmm...还没人找你聊天...', style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),))
      );
    }

    return relationList;
  }
  //私聊的timeline_id是两个uid相加，通过这个方法获取另一个id
  int getUidByTimeline_id(String timeline_id){
    int index = timeline_id.indexOf(Global.profile.user!.uid.toString());
    String tem= "";
    if(index == 0){
      tem = timeline_id.substring(Global.profile.user!.uid.toString().length, timeline_id.length);
    }
    else{
      tem = timeline_id.substring(0, Global.profile.user!.uid.toString().length);

    }

    return int.parse(tem);
  }
}
