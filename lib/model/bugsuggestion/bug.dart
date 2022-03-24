import 'package:json_annotation/json_annotation.dart';

import '../user.dart';
part 'bug.g.dart';

@JsonSerializable()
class Bug{
  String bugid;
  String content;
  String images;
  String createtime;
  int commentcount;
  int likenum;
  User? user;
  bool islike = false;

  Bug(this.bugid, this.content, this.images, this.createtime, this.commentcount, this.likenum, this.user){

  }

  Map<String, dynamic> toJson() => _$BugToJson(this);
  factory Bug.fromJson(Map<String, dynamic> json) => _$BugFromJson(json);
}