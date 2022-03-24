import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';

import '../bloc/im/im_bloc.dart';
import '../model/usernotice.dart';
import '../service/activity.dart';
import '../global.dart';

class NetworkManager{

  static final ImBloc _imBloc =  BlocProvider.of<ImBloc>(Global.mainkey.currentContext!);
  static ActivityService activityService =  ActivityService();

  static IOWebSocketChannel? channel;
  /** 缓存的网络数据，暂未处理（一般这里有数据，说明当前接收的数据不是一个完整的消息，需要等待其它数据的到来拼凑成一个完整的消息） */
  static Int8List cacheData = Int8List(0);
  static void init(User, BuildContext context) {
    connect();
  }

  static onDone({bool isouted=false}) async {
    if(channel != null) {
      if(Global.isInDebugMode)
        print("websocket done!");
      channel!.sink.close();
      channel = null;

      while(channel == null && !isouted){
        await Future.delayed(Duration(seconds:1),(){connect();});
      }
    }
  }

  static onMessage(data){
    List<String> msgs = data.toString().split('※^*@_@*^※');
    String type = msgs[0].toString();
    String content = "0";
    String notice = "";
    print("onMessage:" + msgs.toString());
    if(msgs.length > 1) {
      content = msgs[1].split('※notice_json※')[0];
      notice = msgs[1].split('※notice_json※')[1];
    }

    switch(type){
      //有新消息
      case 'NEWIMMESSAGE':
        _imBloc.add(new NewMessage(Global.profile.user!, content));
        break;
      //新的社团消息
      case 'NEWCOMMUNITYIMMESSAGE':
        _imBloc.add(new NewCommunityMessage(Global.profile.user!, content));
        break;
      //新的私聊消息
      case 'NEWUSERIMMESSAGE':
        _imBloc.add(new NewUserMessage(Global.profile.user!, content));
        break;
      //有新的回复
      case 'NEWREPLY':
        _imBloc.add(new UserCommentReplyNotice(Global.profile.user!));
        break;
      //有新的评论
      case 'NEWCOMMENTY':
        _imBloc.add(new UserCommentReplyNotice(Global.profile.user!));
        break;
      case 'NEWACTLIKE':
        _imBloc.add(new UserCommentReplyNotice(Global.profile.user!));
        break;
      case 'NEWACTCOMMENTLIKE':
        _imBloc.add(new UserCommentReplyNotice(Global.profile.user!));
        break;
    //有新的成员
      case 'NEWMEMBER':
        _imBloc.add(new UserCommentReplyNotice(Global.profile.user!));
        break;
      //有新的关注
      case 'NEWFOLLOWED':
        _imBloc.add(new UserCommentReplyNotice(Global.profile.user!));
        break;
      //有新的未评价活动
      case 'UNACTIVITYEVALUATE':
        _imBloc.add(new UserCommentReplyNotice(Global.profile.user!));
        break;
      //有新的评价,新的评价点赞
      case 'NEWEVALUATE':
        _imBloc.add(new UserCommentReplyNotice(Global.profile.user!));
        break;

      case 'NEWORDER':
        print("----------------------neworder-------------------------");
        _imBloc.add(new UserCommentReplyNotice(Global.profile.user!));
        break;


      case 'RECALL':
        _imBloc.add(new ReCallMessage(Global.profile.user!,  content));
        break;
    //链接成功
      case 'success':
        /*
        链接成功后
        1.获取群聊关系与消息，活动群和社团群分开，1对1聊天
        2.获取活动评论回复
        3.获取评论
        4.获取系统通知
        5.社团有成员加入通知
        6.获取我的朋友
         */

        initLogin();
        break;
    }
  }

  static onError(error){
    if(Global.isInDebugMode)
      print(error);
  }

  static initLogin() async {
    if(Global.profile.user != null) {
      UserNotice? userNotice = await activityService.syncUserNotice(
          Global.profile.user!.uid, Global.profile.user!.token!, () {});
      _imBloc.add(new UserRelationAndMessage(
          Global.profile.user!, userNotice: userNotice));
    }
  }

  static connect(){
    if(Global.profile.user != null ){
      if(Global.isInDebugMode)
        print("websocket init");
      channel = new IOWebSocketChannel.connect(
          '${Global.serviceIM}',
          pingInterval: Duration(milliseconds: 3000));
      channel!.stream
          .listen((data) => onMessage(data), onError: onError, onDone: onDone);
      channel!.sink.add(
        jsonEncode(
          {
            "uid": Global.profile.user!.uid,
            'token': Global.profile.user!.token,
          },
        ),
      );
    }
  }
}


