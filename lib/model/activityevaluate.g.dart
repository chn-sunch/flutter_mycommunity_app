// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activityevaluate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityEvaluate _$ActivityEvaluateFromJson(Map<String, dynamic> json) =>
    ActivityEvaluate(
      actevaluateid: json['actevaluateid'] as int?,
      activity: json['activity'] == null
          ? null
          : Activity.fromJson(json['activity'] as Map<String, dynamic>),
      createtime: json['createtime'] as String?,
      evaluatestatus: json['evaluatestatus'] as int?,
    );

Map<String, dynamic> _$ActivityEvaluateToJson(ActivityEvaluate instance) =>
    <String, dynamic>{
      'actevaluateid': instance.actevaluateid,
      'activity': instance.activity,
      'createtime': instance.createtime,
      'evaluatestatus': instance.evaluatestatus,
    };
