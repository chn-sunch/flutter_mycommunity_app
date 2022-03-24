import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../global.dart';
import '../../bloc/im/reply_notice_bloc.dart';
import '../../model/like.dart';
import '../../model/commentreply.dart';
import '../../model/grouppurchase/goodpice_model.dart';
import '../../widget/circle_headimage.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../service/gpservice.dart';

class ThumbUpList extends StatefulWidget {
  @override
  _ThumbUpListState createState() => _ThumbUpListState();
}

class _ThumbUpListState extends State<ThumbUpList> {
  late ReplyNoticeBloc _replyNoticeBloc;
  List<Like> likes = [];
  ImHelper imHelper = ImHelper();
  bool isLoading = true;

  Future<void> getLikeList() async {
    likes = await imHelper.getThumbUps( 0, 5000);
    isLoading = false;
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLikeList();
    _replyNoticeBloc = BlocProvider.of<ReplyNoticeBloc>(context);
    _replyNoticeBloc.add(readed(Global.profile.user!, replyMsgType: ReplyMsgType.newliked));//全部点赞都已读
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
          title: Text("收到的赞", style: TextStyle(fontSize: 16, color: Colors.black),),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: buildListViewContent()
    );
  }

  Widget buildListViewContent(){
    if(isLoading){
      return SizedBox.shrink();
    }
    if(likes.length == 0){
      return Center(
        child: Text('还没有收到赞，快去参加活动吧！',  style: TextStyle(color: Colors.black54, fontSize: 14,),),
      );
    }
    String subtile = "给你点了个赞";
    return Container(
      margin: EdgeInsets.only(top: 15),
      color: Colors.white,
      child: ListView.builder(
          itemCount: likes.length,  //- 要生成的条数
          itemBuilder: (context, index){
            Like item = likes[index];
             //点赞类型 0 活动 1 留言 2评价 3bug 4建议
            if(item.liketype == 0){
              subtile = "给你的活动点了个赞";
            }

            if(item.liketype == 1){
              subtile = "给你的留言点了个赞";
            }

            if(item.liketype == 2){
              subtile = "给你的活动评价点了个赞";
            }

            if(item.liketype == 3){
              subtile = "给你提交的BUG点了个赞";
            }

            if(item.liketype == 4){
              subtile = "给你提交的建议点了个赞";
            }

            if(item.liketype == 5){
              subtile = "给你的留言点了个赞";
            }

            if(item.liketype == 6){
              subtile = "给你的留言点了个赞";
            }

            if(item.liketype == 7){
              subtile = "给你的评论点了个赞";
            }

            if(item.liketype == 8){
              subtile = "给你的动态点了个赞";
            }

            if(item.liketype == 9){
              subtile = "给你的留言点了个赞";
            }


            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                      ),
                      Container(
                        child: NoCacheCircleHeadImage(
                            width: 45,
                            imageUrl: item.user!.profilepicture!,
                            uid: item.user!.uid
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(item.user!.username, style: TextStyle(color: Colors.black87, fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                            Text(subtile, style: TextStyle(color: Colors.black54, fontSize: 13)),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(right: 10),
                      ),
                    ],
                  ),
                  onTap: () async {
                    if(item.liketype == 0){
                      Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": item.contentid});
                    }

                    if(item.liketype == 1){
                      Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": item.contentid});

                    }

                    if(item.liketype == 2){
                      Navigator.pushNamed(context, '/EvaluateListInActivity', arguments: {"actid": item.contentid});
                    }

                    if(item.liketype == 3){
                      Navigator.pushNamed(context, '/BugInfo', arguments: {"bugid": item.contentid});
                    }

                    if(item.liketype == 4){
                      Navigator.pushNamed(context, '/SuggestInfo', arguments: {"suggestid": item.contentid});
                    }

                    if(item.liketype == 5){
                      Navigator.pushNamed(context, '/BugInfo', arguments: {"bugid": item.contentid});
                    }

                    if(item.liketype == 6){
                      Navigator.pushNamed(context, '/SuggestInfo', arguments: {"suggestid": item.contentid});
                    }

                    if(item.liketype == 7){
                      GPService gpservice = new GPService();
                      GoodPiceModel? goodprice = await gpservice.getGoodPriceInfo(item.contentid!);
                      if(goodprice != null) {
                        Navigator.pushNamed(
                            context, '/GoodPriceInfo', arguments: {
                          "goodprice": goodprice
                        });
                      }
                      else{
                        ShowMessage.showToast("来晚了，活动已下架");
                      }
                    }

                    if(item.liketype == 8 || item.liketype == 9){
                      Navigator.pushNamed(context, '/MomentInfo', arguments: {"momentid": item.contentid});
                    }

                  },
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                ),
              ],
            );
          }),
    );
  }
}
