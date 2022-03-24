import 'package:json_annotation/json_annotation.dart';

import 'activity.dart';

part 'activityevaluate.g.dart';

@JsonSerializable()
class ActivityEvaluate {
  int? actevaluateid;
  Activity? activity;
  String? createtime;
  int? evaluatestatus;

  ActivityEvaluate({this.actevaluateid, this.activity, this.createtime, this.evaluatestatus});

  Map<String, dynamic> toJson() => _$ActivityEvaluateToJson(this);
  factory ActivityEvaluate.fromJson(Map<String, dynamic> json) => _$ActivityEvaluateFromJson(json);

  ActivityEvaluate.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.actevaluateid = data['actevaluateid'];
    this.createtime = data['createtime'];
    this.evaluatestatus = data['evaluatestatus'];
    this.activity = new Activity.fromNullObject();
    this.activity!.actid = data['actid'];
    this.activity!.content = data['content'];
    this.activity!.coverimg = data['coverimg'];
    this.activity!.coverimgwh = data['coverimgwh'];

    this.activity!.peoplenum = data['peoplenum'];
    this.activity!.currentpeoplenum = data['currentpeoplenum'];
    this.activity!.user!.uid = data['actuid'];
    this.activity!.user!.profilepicture = data['profilepicture'];
  }
}
