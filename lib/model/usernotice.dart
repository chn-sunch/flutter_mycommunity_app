import 'package:json_annotation/json_annotation.dart';

part 'usernotice.g.dart';

@JsonSerializable()
class UserNotice{
  int uid;

  int unread_comment;
  int read_commentindex;
  int unread_reply;
  int read_replyindex;
  int unread_sysnotice;
  int read_sysnoticeindex;
  int unread_member;
  int read_member;
  int unread_follow;
  int read_follow;
  int unevaluate_activity;
  int evaluate_activity;//这个是已评论的活动数量
  int unread_evaluate;//这个是未读的评价数量
  int read_evaluate;//已读的评价数量
  int unread_evaluatereply;//未读评价回复
  int read_evaluatereply;//已读评价回复
  int unread_friend;//未读朋友申请通过通知
  int read_friend;//已读朋友申请通过通知
  int isUserUpdate;
  int unread_shared;//来自朋友的分享
  int read_shared;//已读的分享
  int unread_orderpending;//新的待支付订单数量
  int unread_orderfinish;//新的待确认订单数量
  int unread_actlike;//活动点赞数量
  int read_actlike;//活动已读点赞数量
  int unread_commentlike;//留言点赞
  int read_commentlike;//留言点赞
  int unread_evaluatelike;//未读评价点赞
  int read_evaluatelike;//已读评价点赞
  int unread_buglike;//未读bug点赞
  int read_buglike;//已读bug点赞
  int unread_suggestlike;//未读建议点赞
  int read_suggestlike;//已读建议点赞
  int unread_momentlike;
  int read_momentlike;
  int unread_bugcomment;//未读的bugcomment
  int read_bugcomment;//已读的bug评论
  int unread_suggestcomment;//未读的建议评论
  int read_suggestcomment;//已读的建议评论
  int unread_momentcomment;
  int read_momentcomment;
  int unread_bugreply;
  int read_bugreply;
  int unread_suggestreply;
  int read_suggestreply;
  int unread_momentreply;
  int read_mementreply;
  int unread_goodpricecomment;//未读的优惠评论
  int read_goodpricecommentindex;//已读的优惠评论
  int unread_goodpricereply;//未读的优惠回复
  int read_goodpricereplyindex;//已读的优惠回复
  int unread_bugcommentlike;
  int read_bugcommentlike;//bug留言点赞
  int unread_suggestcommentlike;
  int read_suggestcommentlike;//suggest留言点赞
  int unread_momentcommentlike;
  int read_momentcommentlike;
  int unread_goodpricecommentlike;//优惠评论点赞
  int read_goodpricecommentlike;//已读的优惠评论点赞
  int unread_gpmsg;
  int read_gpmsg;
  int unread_communitymsg;
  int read_communitymsg;
  int unread_singlemsg;
  int read_singlemsg;
  int order_expiration;


  UserNotice(this.uid, this.unread_comment, this.read_commentindex,  this.unread_reply, this.read_replyindex,
      this.unread_sysnotice, this.read_sysnoticeindex, this.unread_member, this.read_member, this.unread_follow, this.read_follow,
      this.unevaluate_activity, this.evaluate_activity, this.unread_evaluate, this.read_evaluate, this.unread_evaluatereply, this.read_evaluatereply,
      this.unread_friend, this.read_friend, this.isUserUpdate, this.unread_shared, this.read_shared, this.unread_orderpending, this.unread_orderfinish,
      this.unread_actlike, this.read_actlike, this.unread_commentlike, this.read_commentlike, this.unread_evaluatelike, this.read_evaluatelike,
      this.unread_buglike, this.read_buglike, this.unread_suggestlike, this.read_suggestlike, this.unread_bugcomment, this.read_bugcomment,
      this.unread_suggestcomment, this.read_suggestcomment, this.unread_bugreply, this.read_bugreply, this.unread_suggestreply,
      this.read_suggestreply, this.unread_bugcommentlike, this.read_bugcommentlike, this.unread_suggestcommentlike, this.read_suggestcommentlike,
      this.unread_gpmsg, this.read_gpmsg, this.unread_communitymsg, this.read_communitymsg, this.unread_singlemsg, this.read_singlemsg,
      this.unread_goodpricecomment, this.read_goodpricecommentindex, this.unread_goodpricereply, this.read_goodpricereplyindex,
      this.unread_goodpricecommentlike, this.read_goodpricecommentlike, this.order_expiration, this.unread_momentlike, this.read_momentlike,
      this.unread_momentcomment,this.read_momentcomment,this.unread_momentreply,this.read_mementreply, this.unread_momentcommentlike, this.read_momentcommentlike);



  Map<String, dynamic> toJson() => _$UserNoticeToJson(this);
  factory UserNotice.fromJson(Map<String, dynamic> json) => _$UserNoticeFromJson(json);
}