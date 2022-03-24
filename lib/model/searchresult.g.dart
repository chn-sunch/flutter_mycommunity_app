// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searchresult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) => SearchResult(
      json['id'] as int?,
      json['content'] as String?,
      json['updatetime'] as String?,
      json['searchnum'] as int?,
    );

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'updatetime': instance.updatetime,
      'searchnum': instance.searchnum,
    };
