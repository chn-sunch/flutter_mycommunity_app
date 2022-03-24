// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redpacketdetail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedPacketDetail _$RedPacketDetailFromJson(Map<String, dynamic> json) =>
    RedPacketDetail(
      json['rpdetailid'] as String,
      json['redpacketid'] as String,
      (json['fund'] as num).toDouble(),
      json['uid'] as int,
      json['timeline_id'] != null ? json['timeline_id'] as String : "",
      json['createtime'] as String,
      json['username'] as String,
      json['profilepicture'] as String,
    );

Map<String, dynamic> _$RedPacketDetailToJson(RedPacketDetail instance) =>
    <String, dynamic>{
      'rpdetailid': instance.rpdetailid,
      'redpacketid': instance.redpacketid,
      'fund': instance.fund,
      'uid': instance.uid,
      'timeline_id': instance.timeline_id,
      'createtime': instance.createtime,
      'username': instance.username,
      'profilepicture': instance.profilepicture,
    };
