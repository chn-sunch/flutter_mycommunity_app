import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'specialtextspan.dart';
import '../../bloc/im/im_bloc.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/my_divider.dart';
import '../../util/showmessage_util.dart';
import '../../model/im/grouprelation.dart';
import '../../common/IconFont.dart';
import '../../global.dart';

class SharedRelationList extends StatefulWidget {
  Object? arguments;
  String content = "";//描述内容
  String contentid = "";//根据类型匹配的id
  String image = "";//图片
  String localimg = "";//本地图片路径带有http  这个其实不用区分都是缓存在本地KEY 就是url
  String sharedtype = "";//分享类型 0 活动 1商品 2动态

  SharedRelationList({this.arguments}){
    if(arguments != null) {
      content = (arguments as Map)["content"];
      contentid = (arguments as Map)["contentid"];
      image = (arguments as Map)["image"];
      localimg = (arguments as Map)["localimg"];
      sharedtype = (arguments as Map)["sharedtype"];
    }
  }

  @override
  _SharedRelationListState createState() => _SharedRelationListState();
}

class _SharedRelationListState extends State<SharedRelationList> {
  late ImBloc _imBloc;

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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('聊天', style: TextStyle(color:  Colors.black87, fontSize: 16), ),
        centerTitle: true,
      ),
        body: BlocBuilder<ImBloc, ImState>(
            builder: (context, state) {
              if(state is initImState) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                  ),
                );
              }
              if(state is PostLoading){
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                  ),
                );
              }
              if(state is errorState){
                ShowMessage.showToast(state.error);
              }
              if(state is NewMessageState)
                return UserRelationList(state);
              else
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                  ),
                );
            }
        )

    );
  }

  Widget UserRelationList(state){
    if(state is NewMessageState){
      List<GroupRelation> groupRelations = state.groupRelations;
      if(groupRelations == null || groupRelations.length == 0){
        return Center(
          child: Text('聊天列表里一个人也么有..！', style: TextStyle(color: Colors.black54, fontSize: 14, ),),
        );
      }

      return Container(
        color: Colors.white,
        child: ListView.builder(
            itemCount: state.groupRelations.length,  //- 要生成的条数
            itemBuilder: (context, index){
              GroupRelation item = groupRelations[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  GestureDetector(
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
                              child:  item.relationtype == 1 ? CommunityClipRRectHeadImage(imageUrl: item.clubicon , width: 45, cid: item.timeline_id, uid: Global.profile.user!.uid,):
                              item.relationtype == 2 ? NoCacheClipRRectHeadImage(imageUrl: item.clubicon!, width: 45, uid: getUidByTimeline_id(item.timeline_id),) :
                              ActivityClipRRectHeadImage(imageUrl: item.clubicon , width: 45, actid: item.timeline_id, uid: Global.profile.user!.uid,),
                            ),
                            item.relationtype == 2 || item.relationtype == 0 || item.relationtype == 3 || item.relationtype == 1 ? SizedBox.shrink() : Container(
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
                                    color: item.relationtype == 0 || item.relationtype == 3 ? Global.profile.backColor : Colors.orangeAccent
                                ),
                                width: 15,
                                height: 15,
                                child:  Icon(IconFont.icon_qizi_icon, color: Colors.white, size: 14,),
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
                                        Text(item.group_name1!.replaceAll('\n', '').toString(), style: TextStyle(color: Colors.black, fontSize: 14), overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 5,),
                                        item.newmsg != null ? ExtendedText(item.newmsg!, maxLines:1,style: TextStyle(color: Colors.black26 ,fontSize: 12), overflow: TextOverflow.ellipsis,
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
                                          child: Text(item.newmsgtime != null && item.newmsgtime!.isNotEmpty ? item.newmsgtime!.substring(10, 16) : "", style: TextStyle(color: Colors.black38, fontSize: 13),),
                                        ),

                                        item.unreadcount == 0 ? SizedBox.shrink() : Container(
                                          margin: EdgeInsets.only(right: 10),
                                          child: Badge(
                                            toAnimate: false,
                                            badgeContent: Text(item.unreadcount >= 100 ? "..." : item.unreadcount.toString(), style: TextStyle(fontSize: 10, color: Colors.white),),
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
                    onTap: (){
                      _imBloc.add(Already(Global.profile.user!, item.timeline_id) );
                      Navigator.pushReplacementNamed(context, '/MyMessage', arguments: {"GroupRelation": item, "sharedcontent":
                      "|shared: ${widget.sharedtype}#${widget.contentid}#${widget.content}#${widget.image}|","localsharedcontent":
                      "|shared: ${widget.sharedtype}#${widget.contentid}#${widget.content}#${widget.localimg}|"},).then((val){
                        _imBloc.add(getlocalRelation(Global.profile.user!));
                      });
                    }
                  ),
                  SizedBox(height: 10,),
                ],
              );
            }),
      );
    }

    return SizedBox.shrink();
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
