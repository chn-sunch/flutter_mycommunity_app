// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bug.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bug _$BugFromJson(Map<String, dynamic> json) => Bug(
      json['bugid'] as String,
      json['content'] as String,
      json['images'] as String,
      json['createtime'] as String,
      json['commentcount'] as int,
      json['likenum'] as int,
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BugToJson(Bug instance) => <String, dynamic>{
      'bugid': instance.bugid,
      'content': instance.content,
      'images': instance.images,
      'createtime': instance.createtime,
      'commentcount': instance.commentcount,
      'likenum': instance.likenum,
      'user': instance.user,
      'islike': instance.islike,
    };
