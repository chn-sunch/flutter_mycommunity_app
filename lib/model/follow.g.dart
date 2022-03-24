// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Follow _$FollowFromJson(Map<String, dynamic> json) => Follow(
      json['uid'] as int?,
      json['username'] as String?,
      json['profilepicture'] as String?,
      json['isread'] as int?,
      json['fans'] as int?,
      json['createtime'] as String?,
      json['id'] as int?,
      json['type'] as int?,
    );

Map<String, dynamic> _$FollowToJson(Follow instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'fans': instance.fans,
      'username': instance.username,
      'profilepicture': instance.profilepicture,
      'isread': instance.isread,
      'createtime': instance.createtime,
      'type': instance.type,
    };
