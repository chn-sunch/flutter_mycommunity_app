// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    user: json['user'] == null
        ? null
        : User.fromJson(json['user'] as Map<String, dynamic>),

    backColorval: json['backColorval'] as int ,
    fontColorval: json['fontColorval'] as int ,
    locationName: json['locationName'] as String,
    locationCode: json['locationCode'] as String,
    profilePicture: json['profilePicture'] != null ? json['profilePicture'] as String : "",
    isLogGuided: json['isLogGuided'] as bool,
    lat: json['lat'] as double,
    lng: json['lng'] as double,
    locationGoodPriceCode: json['locationGoodPriceCode'] as String,
    locationGoodPriceName: json['locationGoodPriceName'] as String
  )..communitys = (json['communitys'] != null ? json['communitys'] as List<dynamic> : null)?.map((e) => e.toString()).toList();
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'user': instance.user,
  'backColorval': instance.backColorval,
  'fontColorval': instance.fontColorval,
  'locationName': instance.locationName,
  'locationCode': instance.locationCode,
  'profilePicture': instance.profilePicture,
  'isLogGuided': instance.isLogGuided,
  'communitys': instance.communitys,
  'lat': instance.lat,
  'lng': instance.lng,
  'locationGoodPriceCode': instance.locationGoodPriceCode,
  'locationGoodPriceName': instance.locationGoodPriceName
};