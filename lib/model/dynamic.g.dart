// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dynamic _$DynamicFromJson(Map<String, dynamic> json) => Dynamic(
      json['id'] as int,
      json['uid'] as int,
      json['actiontype'] as String,
      json['actiondata'] as String,
      json['createtime'] as String,
    );

Map<String, dynamic> _$DynamicToJson(Dynamic instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'actiontype': instance.actiontype,
      'actiondata': instance.actiondata,
      'createtime': instance.createtime,
    };
