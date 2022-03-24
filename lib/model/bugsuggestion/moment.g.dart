// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Moment _$MomentFromJson(Map<String, dynamic> json) => Moment(
      json['momentid'] != null ? json['momentid'] as String : "",
      json['content'] != null ? json['content'] as String : "",
      json['images'] != null ? json['images'] as String : "",
      json['createtime'] != null ? json['createtime'] as String : "",
      json['commentcount'] != null ? json['commentcount'] as int : 0,
      json['likenum'] != null ? json['likenum'] as int : 0,
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      json['voice'] != null ? json['voice'] as String : "",
      json['coverimgwh'] != null ? json['coverimgwh'] as String : "",
      json['category'] != null ? json['category'] as String : "",
    );

Map<String, dynamic> _$MomentToJson(Moment instance) => <String, dynamic>{
      'momentid': instance.momentid,
      'content': instance.content,
      'images': instance.images,
      'createtime': instance.createtime,
      'commentcount': instance.commentcount,
      'likenum': instance.likenum,
      'user': instance.user,
      'islike': instance.islike,
      'voice': instance.voice,
      'coverimgwh': instance.coverimgwh,
      'category': instance.category,
    };
