

import 'package:json_annotation/json_annotation.dart';

part 'imreport.g.dart';

@JsonSerializable()
class ImReport{
  String reportid;
  int uid;
  String timeline_id;
  String createtime;
  String updatetime;
  String repleycontent;
  int reporttype;//0拼玩活动 1 社团 2私聊天  3团购



  ImReport(this.reportid, this.uid, this.timeline_id, this.createtime, this.updatetime, this.repleycontent, this.reporttype);

  factory ImReport.fromJson(Map<String, dynamic> json) => _$ImReportFromJson(json);
  Map<String, dynamic> toJson() => _$ImReportToJson(this);

}