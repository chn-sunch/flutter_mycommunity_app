// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluateactivity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EvaluateActivity _$EvaluateActivityFromJson(Map<String, dynamic> json) =>
    EvaluateActivity(
      json['evaluateid'] as int?,
      json['actid'] as String?,
      json['user'] == null ? null : User.fromJson(json['user'] as Map<String, dynamic>),
      json['content'] as String?,
      json['likenum'] as int?,
      json['createtime'] as String?,
      json['likeuid'] != null ? json['likeuid'] as int : 0,
      json['replynum'] as int?,
      json['imagepaths'] as String?,
      json['touid'] as int?,
      json['liketype'] as int?,
      json['actcontent'] as String?,
      json['coverimg'] as String?,
      json['orderid'] != null ? json['orderid'] as String : "",
      json['goodpriceid'] != null ? json['goodpriceid'] as String : "",
    )
      ..replys = (json['replys'] as List<dynamic>?)
          ?.map(
              (e) => EvaluateActivityReply.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$EvaluateActivityToJson(EvaluateActivity instance) =>
    <String, dynamic>{
      'evaluateid': instance.evaluateid,
      'actid': instance.actid,
      'user': instance.user,
      'touid': instance.touid,
      'content': instance.content,
      'imagepaths': instance.imagepaths,
      'liketype': instance.liketype,
      'likenum': instance.likenum,
      'likeuid': instance.likeuid,
      'createtime': instance.createtime,
      'actcontent': instance.actcontent,
      'coverimg': instance.coverimg,
      'replys': instance.replys,
      'replynum': instance.replynum,
      'orderid': instance.orderid,
      'goodpriceid': instance.goodpriceid
    };
