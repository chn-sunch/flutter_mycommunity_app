// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Like _$LikeFromJson(Map<String, dynamic> json) => Like(
      json['likeid'] as int?,
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      json['liketype'] as int?,
      json['contentid'] as String?,
      json['touid'] as int?,
      json['createtime'] as String?,
    );

Map<String, dynamic> _$LikeToJson(Like instance) => <String, dynamic>{
      'likeid': instance.likeid,
      'liketype': instance.liketype,
      'contentid': instance.contentid,
      'user': instance.user,
      'touid': instance.touid,
      'createtime': instance.createtime,
    };
