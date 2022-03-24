// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'securitytoken.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityToken _$SecurityTokenFromJson(Map<String, dynamic> json) {
  return SecurityToken(
    json['ossAccessKeyId'] as String,
    json['policy'] as String,
    json['signature'] as String,
    json['dir'] as String,
    json['host'] as String,
    json['expire'] as String,
  );
}

Map<String, dynamic> _$SecurityTokenToJson(SecurityToken instance) =>
    <String, dynamic>{
      'ossAccessKeyId': instance.ossAccessKeyId,
      'policy': instance.policy,
      'signature': instance.signature,
      'dir': instance.dir,
      'host': instance.host,
      'expire': instance.expire,
    };
