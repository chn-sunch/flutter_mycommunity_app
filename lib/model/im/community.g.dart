// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Community _$CommunityFromJson(Map<String, dynamic> json) => Community(
      json['cid'] as String,
      json['communityname'] as String,
      json['categoryid'] != null ?  json['categoryid'] as int : 0,
      json['province'] != null ?  json['province'] as String : "",
      json['city']  != null ?  json['city'] as String : "",
      json['joinrule'] != null ?  json['joinrule'] as String : "",
      json['notice']  != null ?  json['notice'] as String : "",
      json['clubicon'] != null ?  json['clubicon'] as String : "",
      json['grade'] != null ?  json['grade'] as String : "",
      json['score'] != null ?  json['score'] as String : "",
      json['status']  != null ?  json['status'] as String : "",
      json['star'] != null ? (json['star']as num).toDouble() : 0,
      json['limitnum']  != null ?  json['limitnum'] as int : 0,
      json['membernum'] != null ?  json['membernum'] as int : 0,
      json['username'] != null ?  json['username'] as String : "",
      json['uid']  != null ?  json['uid'] as int : 0,
      json['activitynum']  != null ?  json['activitynum'] as int : 0,
      json['activityimages']  != null ?  json['activityimages'] as String : "",
      json['evaluatenum'] != null ?  json['evaluatenum'] as int : 0,
    )..members = (json['members'] as List<dynamic>?)
        ?.map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$CommunityToJson(Community instance) => <String, dynamic>{
      'cid': instance.cid,
      'communityname': instance.communityname,
      'uid': instance.uid,
      'categoryid': instance.categoryid,
      'province': instance.province,
      'city': instance.city,
      'joinrule': instance.joinrule,
      'notice': instance.notice,
      'clubicon': instance.clubicon,
      'grade': instance.grade,
      'score': instance.score,
      'username': instance.username,
      'members': instance.members,
      'status': instance.status,
      'star': instance.star,
      'limitnum': instance.limitnum,
      'membernum': instance.membernum,
      'activitynum': instance.activitynum,
      'activityimages': instance.activityimages,
      'evaluatenum': instance.evaluatenum,
    };
