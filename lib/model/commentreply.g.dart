// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commentreply.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentReply _$CommentReplyFromJson(Map<String, dynamic> json) => CommentReply(
      json['replyid'] as int?,
      json['commentid'] as int?,
      json['replyuser'] == null
          ? null
          : User.fromJson(json['replyuser'] as Map<String, dynamic>),
      json['touser'] == null
          ? null
          : User.fromJson(json['touser'] as Map<String, dynamic>),
      json['replycontent'] as String?,
      json['replycreatetime'] as String?,
      json['isread'] as bool?,
      json['actid'] as String?,
      json['ismaster'] as bool?,
      json['actcontent'] as String?,
      json['coverimg'] as String?,
      json['evaluateid'] as int?,
      json['imagepaths'] as String?,
    )..type = json['type'] as String?;

Map<String, dynamic> _$CommentReplyToJson(CommentReply instance) =>
    <String, dynamic>{
      'replyid': instance.replyid,
      'actid': instance.actid,
      'commentid': instance.commentid,
      'evaluateid': instance.evaluateid,
      'replyuser': instance.replyuser,
      'touser': instance.touser,
      'replycontent': instance.replycontent,
      'replycreatetime': instance.replycreatetime,
      'isread': instance.isread,
      'type': instance.type,
      'ismaster': instance.ismaster,
      'actcontent': instance.actcontent,
      'coverimg': instance.coverimg,
      'imagepaths': instance.imagepaths,
    };
