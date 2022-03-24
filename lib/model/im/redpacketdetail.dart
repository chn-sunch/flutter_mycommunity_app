import 'package:json_annotation/json_annotation.dart';

part 'redpacketdetail.g.dart';

@JsonSerializable()
class RedPacketDetail {
  String rpdetailid;
  String redpacketid;
  double fund;
  int uid;
  String timeline_id;
  String createtime;
  String username;
  String profilepicture;

  RedPacketDetail(this.rpdetailid, this.redpacketid, this.fund, this.uid, this.timeline_id, this.createtime, this.username, this.profilepicture){

  }

  Map<String, dynamic> toJson() => _$RedPacketDetailToJson(this);
  factory RedPacketDetail.fromJson(Map<String, dynamic> json) => _$RedPacketDetailFromJson(json);
}