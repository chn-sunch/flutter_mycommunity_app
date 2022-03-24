import 'package:equatable/equatable.dart';
import '../../../model/commentreply.dart';

abstract class ReplyNoticeState extends Equatable {
  const ReplyNoticeState();

  @override
  List<Object> get props => [];
}

class initState extends ReplyNoticeState {}

class ReplyPostSuccess extends ReplyNoticeState {
  //消息库
  final List<CommentReply>? commentReplys;
  final bool? hasReachedMax;

  const ReplyPostSuccess({
    this.commentReplys,
    this.hasReachedMax,
  });

  ReplyPostSuccess copyWith({
    List<CommentReply>? commentReplys,
    bool? hasReachedMax,
  }) {
    return ReplyPostSuccess(
      commentReplys: commentReplys ?? this.commentReplys,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [commentReplys??[], hasReachedMax??false];

  @override
  String toString() =>
      'PostSuccess { posts: ${commentReplys}, hasReachedMax: $hasReachedMax }';
}
//获取消息失败
class ReplyPostFailure extends ReplyNoticeState {}

class ReplyPostLoading extends ReplyNoticeState {}

class PostInitial extends ReplyNoticeState {}

//有新的评论回复数量
class newReplyCount extends ReplyNoticeState{
  int? count;
  int? followcount;
  int? newlithumbupCount;

  newReplyCount({this.count, this.followcount, this.newlithumbupCount});

  @override
  List<Object> get props => [count??0];
}

class myNoticeCount extends ReplyNoticeState{
  int? count;
  myNoticeCount({this.count});

  @override
  List<Object> get props => [count??0];
}


//有新好友分享
class newSharedCount extends ReplyNoticeState{
  int? count;
  newSharedCount({this.count});

  @override
  List<Object> get props => [count??0];
}

//有新的待评论活动
class newUnActivityEvaluteCount extends ReplyNoticeState{
  int? count;
  newUnActivityEvaluteCount({this.count});

  @override
  List<Object> get props => [count??0];
}

//有新的订单
class newOrderCount extends ReplyNoticeState{
  int? count;
  newOrderCount({this.count});

  @override
  List<Object> get props => [count??0];
}


