import 'package:equatable/equatable.dart';

import '../../../model/usernotice.dart';
import '../../../model/user.dart';
import '../../../model/commentreply.dart';

abstract class  ReplyNoticeEvent extends Equatable {

  final User user;
  const ReplyNoticeEvent(this.user);

  @override
  List<Object> get props => [user];

}

//获取用户评论,回复，系统通知
// ignore: must_be_immutable
class getUserCommentReplyNotice extends ReplyNoticeEvent{
  int id;
  UserNotice? userNotice;
  getUserCommentReplyNotice(User user, this.id, {this.userNotice}):super(user);
}

class OrderExpiration extends ReplyNoticeEvent{
  OrderExpiration(User user):super(user);
}




//获取本地用户回复列表
class getlocalNotice extends ReplyNoticeEvent{
  getlocalNotice(User user):super(user);

}

//获取本地系统通知列表
class getlocalSysNotice extends ReplyNoticeEvent{
  getlocalSysNotice(User user):super(user);

}

//初始化状态
class initStateNoticeAndReply  extends ReplyNoticeEvent{
  initStateNoticeAndReply(User user):super(user);
}

class readed extends ReplyNoticeEvent{
  ReplyMsgType? replyMsgType;
  readed(User user, {this.replyMsgType}):super(user);
}
