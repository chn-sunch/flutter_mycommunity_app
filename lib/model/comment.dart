import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
import 'commentreply.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  int? commentid;
  String? actid;
  User? user;
  String? content;
  int? likenum;
  String? createtime;
  List<CommentReply>? replys;//活动
  int likeuid;



  Comment(this.commentid, this.actid,  this.user, this.content, this.likenum, this.createtime, this.likeuid);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}