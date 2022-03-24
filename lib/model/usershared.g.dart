// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usershared.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserShared _$UserSharedFromJson(Map<String, dynamic> json) => UserShared(
      json['sharedid'] as int?,
      json['uid'] as int?,
      json['content'] as String?,
      json['contentid'] as String?,
      json['image'] as String?,
      json['sharedtype'] as int?,
      json['createtime'] as String?,
      json['fromuid'] as int?,
      json['fromusername'] as String?,
      json['fromprofilepicture'] as String?,
      (json['mincost'] as num?)?.toDouble(),
      (json['maxcost'] as num?)?.toDouble(),
      (json['lat'] as num?)?.toDouble(),
      (json['lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UserSharedToJson(UserShared instance) =>
    <String, dynamic>{
      'sharedid': instance.sharedid,
      'uid': instance.uid,
      'content': instance.content,
      'contentid': instance.contentid,
      'image': instance.image,
      'sharedtype': instance.sharedtype,
      'createtime': instance.createtime,
      'fromuid': instance.fromuid,
      'fromusername': instance.fromusername,
      'fromprofilepicture': instance.fromprofilepicture,
      'mincost': instance.mincost,
      'maxcost': instance.maxcost,
      'lat': instance.lat,
      'lng': instance.lng,
    };
