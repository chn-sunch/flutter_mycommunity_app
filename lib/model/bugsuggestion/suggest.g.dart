// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Suggest _$SuggestFromJson(Map<String, dynamic> json) => Suggest(
      json['suggestid'] as String,
      json['content'] as String,
      json['images'] as String,
      json['createtime'] as String,
      json['commentcount'] as int,
      json['likenum'] as int,
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SuggestToJson(Suggest instance) => <String, dynamic>{
      'suggestid': instance.suggestid,
      'content': instance.content,
      'images': instance.images,
      'createtime': instance.createtime,
      'commentcount': instance.commentcount,
      'likenum': instance.likenum,
      'user': instance.user,
      'islike': instance.islike,
    };
