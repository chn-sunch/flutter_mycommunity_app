import '../../../model/user.dart';
import '../../../model/usernotice.dart';

abstract class ImEvent  {
  final User user;
  const ImEvent(this.user);

  @override
  List<Object> get props => [user];

}
//用户关系每次获取都要更新，客户端先删除再保存，消息只插入不删除
class UserRelationAndMessage extends ImEvent{
  final UserNotice? userNotice;
  UserRelationAndMessage(User user, {this.userNotice}):super(user);
}

class UserCommentReplyNotice extends ImEvent{
  UserCommentReplyNotice(User user):super(user);
}
//如果是收到新消息需要等待返回
class NewMessage extends ImEvent{
  final String content;
  NewMessage(User user, this.content):super(user);
}
//撤销
class ReCallMessage extends ImEvent{
  final String content;
  ReCallMessage(User user, this.content):super(user);
}

class NewCommunityMessage extends ImEvent{
  final String content;
  NewCommunityMessage(User user, this.content):super(user);
}

class NEWFRIEND extends ImEvent{
  NEWFRIEND(User user):super(user);
}

class NewUserMessage extends ImEvent{
  final String content;

  NewUserMessage(User user, this.content):super(user);
}

class getlocalRelation extends ImEvent{
  getlocalRelation(User user):super(user);
}

//已读
class Already extends ImEvent{
  final String timeline_id;

  Already(User user, this.timeline_id):super(user);
}
//置顶
class RelationTop extends ImEvent{
  final String timeline_id;

  RelationTop(User user, this.timeline_id):super(user);
}

//取消置顶
class RelationTopCancel extends ImEvent{
  final String timeline_id;

  RelationTopCancel(User user, this.timeline_id):super(user);
}

//删除
class RelationDel extends ImEvent{
  final String timeline_id;

  RelationDel(User user,this.timeline_id):super(user);
}

//获取用户评论,回复，系统通知
class getUserCommentReplyNotice extends ImEvent{
  int id;
  UserNotice? userNotice;
  getUserCommentReplyNotice(User user, this.id, {this.userNotice}):super(user);
}