
import 'package:json_annotation/json_annotation.dart';

import 'activity.dart';
import 'user.dart';
import 'grouppurchase/goodpice_model.dart';

part 'report.g.dart';

@JsonSerializable()
class Report{
  String? reportid;
  int? uid;
  String actid = "";
  String createtime = "";
  String updatetime = "";
  String repleycontent = "";
  int reporttype = 0;//0 疑似欺诈 1低俗图片 2其他
  int? sourcetype;//0活动  1goodprice 2 用户
  Activity? activity;
  GoodPiceModel? goodPiceModel;
  User? user;


  Report(this.reportid, this.uid, this.actid, this.createtime, this.updatetime, this.repleycontent, this.reporttype, this.sourcetype, this.activity, this.goodPiceModel, this.user);

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}