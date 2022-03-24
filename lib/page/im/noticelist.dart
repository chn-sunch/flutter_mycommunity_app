import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import '../../model/commentreply.dart';
import '../../model/grouppurchase/goodpice_model.dart';
import '../../model/evaluateactivity.dart';

import '../../service/commonjson.dart';
import '../../service/gpservice.dart';
import '../../service/activity.dart';

import '../../page/im/specialtextspan.dart';
import '../../util/imhelper_util.dart';
import '../../util/showmessage_util.dart';
import '../../widget/circle_headimage.dart';

class NoticeList extends StatefulWidget {
  @override
  _NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  List<CommentReply> commentReplys = [];
  final ImHelper imHelper = ImHelper();
  final CommonJSONService commonJSONService = CommonJSONService();
  bool isloading = true;
  GPService gpservice = new GPService();
  ActivityService activityService = new ActivityService();


  getNoticelList() async {
    await commonJSONService.getSysNotice((data){
      CommentReply commentReply = new CommentReply(0,0,null,null,data["data"]["value"].toString(),
          data["data"]["createtime"].toString(), false, null, false, null, null,null,null);
      commentReply.type = ReplyMsgType.sysnotice.toString();
      commentReplys.add(commentReply);
    });

    List<CommentReply>? temcommreplys = await imHelper.getCommentReplys( 0, 5000);
    if(temcommreplys != null)
      commentReplys = commentReplys + temcommreplys;

    setState(() {
      isloading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNoticelList();
    commentRead();
  }

  commentRead(){
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.commentmsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.replymsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.bugcommentmsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.bugreplymsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.suggestcommentmsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.suggestreplymsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.evaluatemsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.evaluatereplymsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.goodpricecommentmsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.goodpricereplymsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.momentcommentmsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.momentreplymsg);
    imHelper.updateReplyCommentNoticeRead(ReplyMsgType.sysnotice);
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
          title: Text("评论回复", style: TextStyle(fontSize: 16, color: Colors.black),),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body:  isloading ? SizedBox.shrink() : buildListViewContent()
    );
  }

  Widget buildListViewContent(){
    if(commentReplys == null){
      return Center(
        child: Text('暂时还未收到系统通知！', style: TextStyle(color: Colors.black54, fontSize: 14, ),),
      );
    }
    String msgtype = "留言";

    return Container(
      margin: EdgeInsets.only(top: 10),
      color: Colors.white,
      child: ListView.builder(
          itemCount: commentReplys.length,  //- 要生成的条数
          itemBuilder: (context, index){
            CommentReply item = commentReplys[index];
            return item.type == ReplyMsgType.sysnotice.toString() ? Padding(padding: EdgeInsets.only(bottom: 10), child: buildSysNotice(item) ,): buildCommentReply(item);
          }),
    );
  }

  Widget buildSysNotice(CommentReply item){
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(item.replycreatetime != null ? item.replycreatetime! : '', style: TextStyle(color: Colors.black87, fontSize: 14),),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5),
          ),
          Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(10),
              child: ExtendedText(item.replycontent!, style: TextStyle(color: Colors.black87, fontSize: 14),
                specialTextSpanBuilder: MySpecialTextSpanBuilder(
                  showAtBackground: false,
                ),
              ),
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: Colors.grey.shade200,
              )
          )
        ],
      ),
    );
  }

  Widget buildCommentReply(CommentReply item){
    String msgtype = "留言";
    if(item.type == ReplyMsgType.evaluatemsg.toString()){//评价
      msgtype = "评价";
    }
    else if(item.type == ReplyMsgType.commentmsg.toString()){
      msgtype = "留言";
    }
    else if(item.type == ReplyMsgType.goodpricecommentmsg.toString()){
      msgtype = "评论";
    }
    else if(item.type == ReplyMsgType.momentcommentmsg.toString()){
      msgtype = "留言";
    }
    else{
      msgtype = "回复";
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
                    width: 50,
                    imageUrl: item.replyuser!.profilepicture!,
                    uid: item.replyuser!.uid
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
                    Text(item.ismaster! ? '楼主':item.replyuser!.username.replaceAll('\n', '').toString(), style: TextStyle(color: Colors.black87, fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    item.replycontent != null ? Text('${msgtype} ${item.replycontent}',
                      maxLines:2,style: TextStyle(color: Colors.black45, fontSize: 13), overflow: TextOverflow.ellipsis,
                    ) : Text(''),
                  ],
                ),
              ),
              SizedBox(width: 10,),
              Padding(
                padding: EdgeInsets.only(right: 10),
              ),
            ],
          ),
          onTap: () async {
            //从消息评论列表进入活动详情页面，活动的状态不确定
            if(item.type == ReplyMsgType.commentmsg.toString() || item.type == ReplyMsgType.replymsg.toString())
              Navigator.pushNamed(context, '/ActivityInfo',
                  arguments: {"actid": item.actid, "isShowComment": true, "commentid": item.commentid});
            else if(item.type == ReplyMsgType.evaluatemsg.toString()) {
              GoodPiceModel? goodprice = await gpservice.getGoodPriceInfo(item.actid!);
              if (goodprice != null) {
                Navigator.pushNamed(
                    context, '/GoodPriceInfo', arguments: {
                  "goodprice": goodprice
                });
              }
            }
            else if(item.type == ReplyMsgType.evaluatereplymsg.toString())  {
              EvaluateActivity? evaluateactivity = await activityService.getEvaluateActivityByEvaluateid(item.evaluateid!);
              if(evaluateactivity != null) {
                Navigator.pushNamed(context, '/EvaluateInfo',
                    arguments: {"evaluateActivity": evaluateactivity});
              }
            }
            else if(item.type == ReplyMsgType.bugcommentmsg.toString()){
              Navigator.pushNamed(context, '/BugInfo', arguments: {"bugid": item.actid});
            }
            else if(item.type == ReplyMsgType.bugreplymsg.toString()){
              Navigator.pushNamed(context, '/BugInfo', arguments: {"bugid": item.actid});
            }
            else if(item.type == ReplyMsgType.suggestcommentmsg.toString()){
              Navigator.pushNamed(context, '/SuggestInfo', arguments: {"suggestid": item.actid});
            }
            else if(item.type == ReplyMsgType.suggestreplymsg.toString()){
              Navigator.pushNamed(context, '/SuggestInfo', arguments: {"suggestid": item.actid});
            }
            else if(item.type == ReplyMsgType.goodpricecommentmsg.toString() || item.type == ReplyMsgType.goodpricereplymsg.toString()){
              GoodPiceModel? goodprice = await gpservice.getGoodPriceInfo(item.actid!);
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
            else if(item.type == ReplyMsgType.momentcommentmsg.toString()){
              Navigator.pushNamed(context, '/MomentInfo', arguments: {"momentid": item.actid});
            }
            else if(item.type == ReplyMsgType.momentreplymsg.toString()){
              Navigator.pushNamed(context, '/MomentInfo', arguments: {"momentid": item.actid});
            }
          },
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 30),
        ),
      ],
    );
  }
}
