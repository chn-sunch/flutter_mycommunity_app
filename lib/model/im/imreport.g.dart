// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imreport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImReport _$ImReportFromJson(Map<String, dynamic> json) => ImReport(
      json['reportid'] as String,
      json['uid'] as int,
      json['timeline_id'] as String,
      json['createtime'] as String,
      json['updatetime'] as String,
      json['repleycontent'] as String,
      json['reporttype'] as int,
    );

Map<String, dynamic> _$ImReportToJson(ImReport instance) => <String, dynamic>{
      'reportid': instance.reportid,
      'uid': instance.uid,
      'timeline_id': instance.timeline_id,
      'createtime': instance.createtime,
      'updatetime': instance.updatetime,
      'repleycontent': instance.repleycontent,
      'reporttype': instance.reporttype,
    };
