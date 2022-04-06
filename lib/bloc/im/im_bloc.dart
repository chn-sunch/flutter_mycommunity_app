import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert' as JSON;

import '../../service/activity.dart';
import '../../service/imservice.dart';
import '../../util/imhelper_util.dart';
import '../../model/im/grouprelation.dart';
import '../../model/im/timelinesync.dart';
import '../../model/im/sysmessage.dart';
import '../../model/usernotice.dart';

import '../../global.dart';
import 'event/im_event.dart';
import 'state/im_state.dart';
export 'event/im_event.dart';
export 'state/im_state.dart';

class ImBloc extends Bloc<ImEvent, ImState> {
  final ImHelper imHelper = ImHelper();
  String error = "";
  String errorstatusCode = "";
  List<TimeLineSync>? timeLineSyncs;

  // @override
  // ImState get initialState => initImState();
  final ImService imService = ImService();
  final ActivityService activityService = ActivityService();
  ImBloc():super( initImState());

  @override
  Stream<ImState> mapEventToState(
      ImEvent event,
      ) async* {
    try {
      if(event is UserRelationAndMessage){
        List<GroupRelation>? grouprelationlist = [];
        if(event.userNotice != null){
          //聊天通知
          if(event.userNotice!.unread_gpmsg > 0){
            //群聊关系同步本地储存，消息数据异步写入
            //用户登录成功后执行 活动群，自建群聊，私人聊天的同步
            grouprelationlist = await imService.syncActivityRelation(event.user.uid, event.user.token!, errorCallBack);
            if(grouprelationlist != null && grouprelationlist.isNotEmpty) {
              await imService.saveLocalStore(grouprelationlist, event.user.token!, event.user.uid, errorCallBack);
            }
          }
          if(event.userNotice!.unread_communitymsg > 0){
            grouprelationlist = await imService.syncCommunityRelation(event.user.uid, event.user.token!, errorCallBack);
            if(grouprelationlist != null && grouprelationlist.isNotEmpty) {
              await imService.saveLocalStore(grouprelationlist, event.user.token!, event.user.uid, errorCallBack);
            }
          }
          if(event.userNotice!.unread_singlemsg > 0){
            grouprelationlist = await imService.syncSingleRelation(event.user.uid, event.user.token!, errorCallBack);
            if(grouprelationlist != null && grouprelationlist.isNotEmpty) {
              await imService.saveLocalStore(grouprelationlist, event.user.token!, event.user.uid, errorCallBack);
            }
          }
          //活动通知
          await activityService.saveLocalStore(
              event.userNotice!, event.user.token!, event.user.uid,
              errorCallBack);
        }
        //获取本地
        NewMessageState newMessageState = await setAppUnReadCount(event.user.uid);

        //消息通知接收的消息是最新的一条，导航到消息页面后旧的消息可能还没有下载完成。Global.profile.timeline_id是最新的聊天

        if(Global.timeline_id != ""){
          List<TimeLineSync> timeLineSyncs = [];
          timeLineSyncs = await imHelper.getTimeLineSync(Global.profile.user!.uid, 0, 30, Global.timeline_id);
          Global.timeline_id = "";

          yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations, msgMessage: timeLineSyncs);

        }
        else {
          yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations, msgMessage: []);
        }
      }

      if(event is UserCommentReplyNotice){
        UserNotice? userNotice = await activityService.syncUserNotice(
            event.user.uid, event.user.token!, errorCallBack);
        if(userNotice != null) {
          await activityService.saveLocalStore(
              userNotice, event.user.token!, event.user.uid,
              errorCallBack);
        }
      }

      if(event is NewMessage){
        //活动群聊同步
        List<GroupRelation> grouprelationlist = [];
        List<TimeLineSync> timeLineSyncs = [];
        // grouprelationlist = await imService.syncActivityRelation(event.user.uid, event.user.token, errorCallBack);
        //群聊关系同步本地储存，消息数据异步写入
        String message = event.content;
        if(message != null && message != "") {
          if(Global.isInDebugMode)
            print(message);
          Map<String, dynamic> data = (JSON.jsonDecode(message)) as Map<String, dynamic>;

          GroupRelation groupRelation = GroupRelation.fromJson(data["groupRelation"] as Map<String, dynamic>);
          grouprelationlist.add(groupRelation);
          if(await imHelper.saveGroupRelation(grouprelationlist) > 0) {
            TimeLineSync timeLineSync = TimeLineSync.fromMapByServer(data);
            await imService.saveTimeLineSync(
                timeLineSync, event.user.token, event.user.uid,
                errorCallBack);
          }
          timeLineSyncs = await imHelper.getTimeLineSync(Global.profile.user!.uid, 0, timeLineSyncs.length + 30, groupRelation.timeline_id );
        }
        //用户本地替换服务器数据
        NewMessageState newMessageState = await setAppUnReadCount(event.user.uid);
        yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations,  msgMessage: timeLineSyncs);
      }

      if(event is NewCommunityMessage){
        List<GroupRelation> grouprelationlist = [];
        List<TimeLineSync> timeLineSyncs = [];

        String message = event.content;
        if(message != null && message != "") {
          Map<String, dynamic> data = (JSON.jsonDecode(message)) as Map<String, dynamic>;
          GroupRelation groupRelation = GroupRelation.fromJson(data["groupRelation"] as Map<String, dynamic>);
          grouprelationlist.add(groupRelation);
          if(await imHelper.saveGroupRelation(grouprelationlist) > 0) {
            TimeLineSync timeLineSync = TimeLineSync.fromMapByServer(data);
            await imService.saveCommunityTimeLineSync(
                timeLineSync, event.user.token, event.user.uid,
                errorCallBack);
          }
          timeLineSyncs = await imHelper.getTimeLineSync(Global.profile.user!.uid, 0, timeLineSyncs.length + 30, groupRelation.timeline_id );
        }
        //用户本地替换服务器数据
        NewMessageState newMessageState = await setAppUnReadCount(event.user.uid);
        yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations,  msgMessage: timeLineSyncs);
      }
      //有新的私聊
      if(event is NewUserMessage){
        List<TimeLineSync> timeLineSyncs = [];
        List<GroupRelation> grouprelationlist = [];
        String message = event.content;
        if(message != null && message != "") {
          Map<String, dynamic> data = (JSON.jsonDecode(message)) as Map<String, dynamic>;
          if(Global.isInDebugMode)
            print(data);
          GroupRelation groupRelation = GroupRelation.fromJson(data["groupRelation"] as Map<String, dynamic>);
          grouprelationlist.add(groupRelation);
          if(await imHelper.saveGroupRelation(grouprelationlist) > 0) {
            TimeLineSync timeLineSync = TimeLineSync.fromMapByServer(data);
            await imService.saveSingleTimeLineSync(
                timeLineSync, event.user.token, event.user.uid,
                errorCallBack);
          }
          timeLineSyncs = await imHelper.getTimeLineSync(Global.profile.user!.uid, 0, timeLineSyncs.length + 30, groupRelation.timeline_id);
        }
        //群聊关系同步本地储存，消息数据异步写入
        //私人群聊同步
        //用户本地替换服务器数据
        NewMessageState newMessageState = await setAppUnReadCount(event.user.uid);
        yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations, msgMessage: timeLineSyncs);
      }
      if(event is ReCallMessage){
        //撤回消息,接收方
        List<TimeLineSync> timeLineSyncs = [];
        //撤回消息根据source_id, 需要改两个地方，一个是relation_table 一个是synctable
        String timeline_id = event.content.split("^※^")[0];
        String source_id = event.content.split("^※^")[1];
        String reCallContent =  event.content.split("^※^")[2];
        ///撤回数据
        await imHelper.recallMessageToUid(source_id, reCallContent);
        await imHelper.recallGroupRelation(source_id, reCallContent);
        //用户本地替换服务器数据
        NewMessageState newMessageState = await setAppUnReadCount(event.user.uid);
        timeLineSyncs = await imHelper.getTimeLineSync(Global.profile.user!.uid, 0, timeLineSyncs.length + 30, timeline_id);
        yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations, msgMessage: timeLineSyncs);
      }
      if(event is getlocalRelation){
        NewMessageState newMessageState = await setAppUnReadCount(event.user.uid);
        yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations, msgMessage: []);
      }
      //将未读消息状态改成已读
      if(event is Already){
        await imHelper.updateAlready(event.timeline_id);
      }
      //将群聊置顶
      if(event is RelationTop){
        if(await imHelper.updateTop(event.timeline_id, event.user.uid) > 0) {
          NewMessageState newMessageState = await setAppUnReadCount(event.user.uid);
          yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations, msgMessage: []);
        }
      }
      //取消置顶
      if(event is RelationTopCancel){
        if(await imHelper.updateTopCancel(event.timeline_id, event.user.uid) > 0) {
          NewMessageState newMessageState = await setAppUnReadCount(event.user.uid);
          yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations, msgMessage: []);
        }
      }
      //删除群聊关系
      if(event is RelationDel){
        if(await imHelper.delGroupRelation(event.timeline_id, event.user.uid) > 0){
          imHelper.delTimeLineSync(event.user.uid, event.timeline_id);
          NewMessageState newMessageState = await setAppUnReadCount(event.user.uid);
          yield NewMessageState(sysMessage: newMessageState.sysMessage, groupRelations: newMessageState.groupRelations, msgMessage: []);
        }
      }
    }
    catch(_){

    }
  }


  Future<NewMessageState> setAppUnReadCount(int uid) async {

    int unAllReadCount = 0;//所有未读消息 待付款 待评价
    NewMessageState newMessageState = await getAllMessage(uid);



    unAllReadCount = newMessageState.sysMessage.newImMode + newMessageState.sysMessage.neworderpending_count
        + newMessageState.sysMessage.neworderfinish_count + newMessageState.sysMessage.activityevalute_count;


    if(unAllReadCount > 0) {
      FlutterAppBadger.updateBadgeCount(unAllReadCount > 99 ? 99 : unAllReadCount);
    }
    else
      FlutterAppBadger.removeBadge();

    return newMessageState;
  }

  Future<NewMessageState> getAllMessage(int uid) async {
    int unImReadCount = 0;
    List<GroupRelation> grouprelationlist = await imHelper.getGroupRelation(uid.toString());
    //IM为读
    if(grouprelationlist != null && grouprelationlist.length > 0){
      for(GroupRelation groupRelation in grouprelationlist){
        unImReadCount += groupRelation.unreadcount;
      }
    }
    int commentreply_count = await imHelper.getCommentReplysCount();//新的留言,评论与回复
    int follow_count = await imHelper.getNewFollowCount();//新的关注
    int activityevalute_count = await imHelper.getUserUnEvaluateOrder();//有新的待评价活动不加入提醒，在用户主动点击我的页面后显示
    int neworderpending_count = await imHelper.getUserOrder(0);//获取待支付订单
    int neworderfinish_count =  await imHelper.getUserOrder(1);//获取待确认订单
    int newlithumbup_count = await imHelper.getLikeNoticeCount();//未读的点赞

    SysMessage sysMessage = new SysMessage(commentreply_count, follow_count, activityevalute_count, neworderpending_count,
        neworderfinish_count, newlithumbup_count, unImReadCount + commentreply_count + follow_count + newlithumbup_count,
        activityevalute_count + neworderpending_count + neworderfinish_count);

    return NewMessageState(groupRelations: grouprelationlist, sysMessage: sysMessage, msgMessage: []);
  }

  errorCallBack(String statusCode, String msg) {
    error = msg;
    errorstatusCode = statusCode;
  }

  bool _hasReachedMax(ImState state) =>
      state is PostSuccess  && state.hasReachedMax!;

}
