import 'package:json_annotation/json_annotation.dart';

import 'evaluateactivityreply.dart';
import 'user.dart';

part 'evaluateactivity.g.dart';

@JsonSerializable()
class EvaluateActivity {
  int? evaluateid;
  String? actid;
  User? user;
  int? touid;
  String? content;
  String? imagepaths;
  int? liketype;
  int? likenum;
  int? likeuid;//用于查询本地用户是否有点赞
  String? createtime;
  String? actcontent;
  String? coverimg;
  List<EvaluateActivityReply>? replys;//活动ee
  int? replynum;//回复数
  String orderid = "";
  String goodpriceid = "";

  EvaluateActivity(this.evaluateid, this.actid,  this.user, this.content, this.likenum, this.createtime, this.likeuid,
      this.replynum, this.imagepaths, this.touid, this.liketype, this.actcontent, this.coverimg, this.orderid, this.goodpriceid);

  Map<String, dynamic> toJson() => _$EvaluateActivityToJson(this);
  factory EvaluateActivity.fromJson(Map<String, dynamic> json) => _$EvaluateActivityFromJson(json);
}