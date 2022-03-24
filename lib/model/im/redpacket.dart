import 'package:json_annotation/json_annotation.dart';

part 'redpacket.g.dart';

@JsonSerializable()
class RedPacketModel {
  String redpacketid;
  int uid;
  double amount;
  int redpackettype;
  int redpacketstatus;
  int redpacketnum;
  String createtime;
  String timeline_id;
  String content;
  String username;
  String profilepicture;
  String original_order_id;
  double tofund;//自己领了多少钱
  int touid;
  String tocreatetime;//领取的时间
  bool isexpire;
  int currentnum;

  RedPacketModel(this.redpacketid, this.uid, this.amount, this.redpackettype, this.redpacketstatus, this.redpacketnum, this.createtime,
      this.timeline_id, this.content, this.username, this.profilepicture, this.original_order_id, this.touid, this.tocreatetime, this.tofund, this.isexpire, this.currentnum){

  }

  Map<String, dynamic> toJson() => _$RedPacketModelToJson(this);
  factory RedPacketModel.fromJson(Map<String, dynamic> json) => _$RedPacketModelFromJson(json);
}