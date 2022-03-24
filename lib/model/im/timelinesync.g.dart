// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timelinesync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeLineSync _$TimeLineSyncFromJson(Map<String, dynamic> json) => TimeLineSync(
      json['timeline_id'] as String?,
      json['sequence_id'] as int?,
      json['conversation'] as int?,
      json['send_time'] as String?,
      json['senderUser'] == null
          ? null
          : User.fromJson(json['senderUser'] as Map<String, dynamic>),
      json['content'] as String?,
      json['contenttype'] as int?,
      json['localpath'] as String?,
      json['source_id'] as String?,
    )
      ..sender = json['sender'] as int?
      ..serdername = json['serdername'] as String?
      ..serderpicture = json['serderpicture'] as String?
      ..isplay = json['isplay'] as bool?
      ..isopen = json['isopen'] as int?;

Map<String, dynamic> _$TimeLineSyncToJson(TimeLineSync instance) =>
    <String, dynamic>{
      'timeline_id': instance.timeline_id,
      'sequence_id': instance.sequence_id,
      'conversation': instance.conversation,
      'send_time': instance.send_time,
      'sender': instance.sender,
      'serdername': instance.serdername,
      'serderpicture': instance.serderpicture,
      'content': instance.content,
      'contenttype': instance.contenttype,
      'senderUser': instance.senderUser,
      'isplay': instance.isplay,
      'localpath': instance.localpath,
      'isopen': instance.isopen,
      'source_id': instance.source_id,
    };
