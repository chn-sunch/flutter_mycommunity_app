// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      json['reportid'] as String?,
      json['uid'] as int?,
      json['actid'] != null ? json['actid']as String : "",
      json['createtime'] != null ? json['createtime'] as String : "",
      json['updatetime'] != null ? json['updatetime'] as String : "",
      json['repleycontent'] != null ? json['repleycontent'] as String : "",
      json['reporttype'] != null ? json['reporttype'] as int : 0 ,
      json['sourcetype'] as int?,
      json['activity'] == null
          ? null
          : Activity.fromJson(json['activity'] as Map<String, dynamic>),
      json['goodpice'] == null
          ? null
          : GoodPiceModel.fromJson(
              json['goodpice'] as Map<String, dynamic>),
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'reportid': instance.reportid,
      'uid': instance.uid,
      'actid': instance.actid,
      'createtime': instance.createtime,
      'updatetime': instance.updatetime,
      'repleycontent': instance.repleycontent,
      'reporttype': instance.reporttype,
      'sourcetype': instance.sourcetype,
      'activity': instance.activity,
      'goodPiceModel': instance.goodPiceModel,
      'user': instance.user,
    };
