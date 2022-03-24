import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../global.dart';
import '../../bloc/im/reply_notice_bloc.dart';
import '../../model/commentreply.dart';
import '../../model/follow.dart';
import '../../widget/circle_headimage.dart';
import '../../util/imhelper_util.dart';

class NewFollowList extends StatefulWidget {
  @override
  _NewFollowListState createState() => _NewFollowListState();
}

class _NewFollowListState extends State<NewFollowList> {
  late ReplyNoticeBloc _replyNoticeBloc;
  final ImHelper imHelper = ImHelper();
  List<Follow> follows = [];
  bool isloading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowList();
    _replyNoticeBloc = BlocProvider.of<ReplyNoticeBloc>(context);
    _replyNoticeBloc.add(readed(Global.profile.user!, replyMsgType: ReplyMsgType.newfollowed));
  }

  getFollowList() async {
    follows = await imHelper.getFollows( 0, 5000);
    setState(() {
      isloading = false;
    });
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
          title: Text("新增关注", style: TextStyle(fontSize: 16, color: Colors.black),),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: isloading ? SizedBox.shrink() : buildListViewContent()
    );
  }

  Widget buildListViewContent(){
    if(follows.length == 0){
      return Center(
        child: Text('还没新增的关注，快去参加活动吧！', style: TextStyle(color: Colors.black54, fontSize: 14, ),),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 15),
      color: Colors.white,
      child: ListView.builder(
          itemCount: follows.length,  //- 要生成的条数
          itemBuilder: (context, index){
            Follow item = follows[index];
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
                            imageUrl: item.profilepicture!,
                            uid: item.fans!
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
                            Text(item.username!, style: TextStyle(color: Colors.black87, fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                            Text('关注了你', style: TextStyle(color: Colors.black54, fontSize: 13)),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(right: 10),
                      ),
                    ],
                  ),
                  onTap: (){
                    Navigator.pushNamed(context, '/OtherProfile', arguments: {"uid": item.fans});
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
