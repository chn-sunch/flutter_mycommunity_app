import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/usernotice.dart';
import '../../model/commentreply.dart';
import '../../service/activity.dart';
import '../../service/imservice.dart';
import '../../util/imhelper_util.dart';

import 'event/reply_notice_event.dart';
import 'state/reply_notice_state.dart';
export 'event/reply_notice_event.dart';
export 'state/reply_notice_state.dart';

class ReplyNoticeBloc  extends Bloc<ReplyNoticeEvent, ReplyNoticeState> {
  final ImHelper imHelper = ImHelper();
  String error = "";
  String errorstatusCode = "";
  final ImService imService = ImService();
  ReplyNoticeBloc() : super(initState());

  final ActivityService activityService = ActivityService();

  // @override
  // ReplyNoticeState get initialState => initState();

  @override
  Stream<ReplyNoticeState> mapEventToState(
      ReplyNoticeEvent event,
      ) async* {
    if(event is initStateNoticeAndReply){
      yield PostInitial();
    }
    //从服务器获取未读回复列表
    if(event is getUserCommentReplyNotice){
      yield ReplyPostLoading();
      UserNotice? userNotice = null;
      if(event.userNotice != null){
        userNotice = event.userNotice;
      }
      else {
        userNotice = await activityService.syncUserNotice(
            event.user.uid, event.user.token!, errorCallBack);
      }
      if(userNotice != null){
        await activityService.saveLocalStore(
            userNotice, event.user.token!, event.user.uid,
            errorCallBack);
      }

      int count = await imHelper.getCommentReplysCount();//新的留言,评论与回复
      int getLikeCount = await imHelper.getNewFollowCount( );//新的关注
      int mynoticecount = 0;
      int activityEvaluteCount = await imHelper.getActivityEvaluateCount(0);//有新的待评价活动不加入提醒，在用户主动点击我的页面后显示
      int newsharedCount = await imHelper.getUserSharedCount();//有新的分享
      int neworderPending = await imHelper.getUserOrder(0);//获取待支付订单
      int neworderFinish =  await imHelper.getUserOrder(1);//获取待确认订单
      int newlithumbupCount = await imHelper.getLikeNoticeCount();//未读的点赞

      //不要把待评价活动加入到桌面图标中
      int sumcount = count + getLikeCount + newsharedCount + neworderPending + neworderFinish + newlithumbupCount + activityEvaluteCount;
      if(sumcount >= 0) {
        setAppUnReadCount(sumcount);
      }
      if((count != null && count >= 0) || getLikeCount >=0){
        yield newReplyCount(count: count + getLikeCount+newlithumbupCount , followcount: getLikeCount);
      }

      mynoticecount = activityEvaluteCount + newsharedCount + neworderPending + neworderFinish;

      int myordercount = neworderPending + neworderFinish;

      if(mynoticecount >= 0){
        yield myNoticeCount(count: mynoticecount);
      }

      if(newsharedCount >= 0) {
        yield newSharedCount(count: newsharedCount);
      }

      if(myordercount >= 0){
        yield newOrderCount(count: myordercount);
      }
//      if(activityEvaluteCount >= 0){
//        yield newUnActivityEvaluteCount(count: activityEvaluteCount);
//      }
      return;
    }

    if(event is readed){
      //评论和评论回复是在同一个页面展示，进入后一起被标记为已读
      if(event.replyMsgType.toString() == ReplyMsgType.commentmsg.toString()){
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.commentmsg);
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.replymsg);
      }

      if(event.replyMsgType.toString() == ReplyMsgType.bugcommentmsg.toString()){
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.bugcommentmsg);
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.bugreplymsg);
      }

      if(event.replyMsgType.toString() == ReplyMsgType.suggestcommentmsg.toString()){
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.suggestcommentmsg);
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.suggestreplymsg);
      }

      if(event.replyMsgType.toString() == ReplyMsgType.evaluatemsg.toString()){
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.evaluatemsg);
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.evaluatereplymsg);
      }

      if(event.replyMsgType.toString() == ReplyMsgType.goodpricecommentmsg.toString()){
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.goodpricecommentmsg);
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.goodpricereplymsg);
      }

      if(event.replyMsgType.toString() == ReplyMsgType.replymsg.toString()){
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.replymsg);
      }

      if(event.replyMsgType.toString() == ReplyMsgType.sysnotice.toString()){
        imHelper.updateReplyCommentNoticeRead(ReplyMsgType.sysnotice);
      }

      if(event.replyMsgType.toString() == ReplyMsgType.newmember.toString()){
        imHelper.updateNewMemberNoticeRead();
      }

      if(event.replyMsgType.toString() == ReplyMsgType.newfollowed.toString()){
        imHelper.updateFollowedNoticeRead();
      }

      if(event.replyMsgType.toString() == ReplyMsgType.newfriend.toString()){
        imHelper.updateNewFriendNoticeRead();
      }

      if(event.replyMsgType.toString() == ReplyMsgType.sharedReaded.toString()){
        imHelper.updateUserSharedRead();
      }

      if(event.replyMsgType.toString() == ReplyMsgType.newliked.toString()){
        imHelper.updateUserLikeRead();
      }


      int count = await imHelper.getCommentReplysCount();
      // int newmembercount = await imHelper.getCommunityMemberCount();
      int getLikeCount = await imHelper.getNewFollowCount();
      // int newfriendCount = await imHelper.getFriendCount();//有新的朋友
      int activityEvaluteCount = await imHelper.getUserUnEvaluateOrder();//有新的待评价活动不加入提醒，在用户主动点击我的页面后显示
      int newsharedCount = await imHelper.getUserSharedCount();//有新的分享
      int newlithumbupCount = await imHelper.getLikeNoticeCount();//未读的点赞

      int sumcount = count +  getLikeCount + newsharedCount;
      if(sumcount >= 0) {
        setAppUnReadCount(count + getLikeCount + newsharedCount);
      }
      int mynoticecount = 0;

      mynoticecount = activityEvaluteCount + newsharedCount;

      if(mynoticecount >= 0){
        yield myNoticeCount(count: mynoticecount);
      }

      if((count != null && count >= 0) || getLikeCount >=0){
        yield newReplyCount(count: count + getLikeCount + newlithumbupCount, followcount: getLikeCount, newlithumbupCount: newlithumbupCount);
        return;
      }

      if(sumcount>=0){
        yield newSharedCount(count: newsharedCount);
      }
    }

    if(event is OrderExpiration){
      activityService.syncOrderExpirationFun(event.user.uid, event.user.token!, errorCallBack);
    }
  }

  setAppUnReadCount(int count){
    int unReadCount = 0;
    // Global.replyCount = count;
    // unReadCount = Global.immsgCount + Global.replyCount;
    if(unReadCount > 0) {
      FlutterAppBadger.updateBadgeCount(unReadCount > 99 ? 99 : unReadCount);
    }
    else
      FlutterAppBadger.removeBadge();
  }

  errorCallBack(String statusCode, String msg) {
    error = msg;
    errorstatusCode = statusCode;
  }

  bool _hasReachedMax(ReplyNoticeState state) =>
      state is ReplyPostSuccess  && state.hasReachedMax!;

}


