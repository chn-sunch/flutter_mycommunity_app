// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      json['actid'] != null ? json['actid'] as String : "",
      json['peoplenum'] as int?,
      json['createtime'] as String?,
      json['updatetime'] as String?,
      json['content'] != null ? json['content'] as String : "",
      json['score'] as String?,
      json['actimagespath'] as String?,
      json['status'] as int?,
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      json['actcity'] as String?,
      json['actprovince'] as String?,
      json['coverimg'] as String?,
      json['coverimgwh'] == null ? "" : json['coverimgwh'] as String,
      json['likenum'] as int,
      json['collectionnum'] as int,
      json['startyear'] as int?,
      json['endyear'] as int?,
      json['commentnum'] as int?,
      json['currentpeoplenum'] as int?,
      json['mincost'] ==  null ? 0 : (json['mincost'] as num).toDouble(),
      json['maxcost'] ==  null ? 0 : (json['maxcost'] as num).toDouble(),
      json['address'] as String?,
      (json['lat'] as num?)?.toDouble(),
      (json['lng'] as num?)?.toDouble(),
      json['addresstitle'] as String?,
      json['paytype'] as int?,
      json['orderid'] as String?,
      json['goodpriceid'] as String?,
      json['joinnum'] as int?,
      json['viewnum'] as int?,
      json['locked'] as int?,

      json['goodprice'] == null
          ? null
          : GoodPiceModel.fromJson(json['goodprice'] as Map<String, dynamic>),
    )
      ..members = (json['members'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList()
      ..activityEvaluate = json['activityEvaluate'] == null
          ? null
          : ActivityEvaluate.fromJson(
              json['activityEvaluate'] as Map<String, dynamic>);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'actid': instance.actid,
      'members': instance.members,
      'peoplenum': instance.peoplenum,
      'createtime': instance.createtime,
      'updatetime': instance.updatetime,
      'content': instance.content,
      'score': instance.score,
      'actimagespath': instance.actimagespath,
      'status': instance.status,
      'user': instance.user,
      'actcity': instance.actcity,
      'actprovince': instance.actprovince,
      'coverimg': instance.coverimg,
      'coverimgwh': instance.coverimgwh,
      'likenum': instance.likenum,
      'collectionnum': instance.collectionnum,
      'startyear': instance.startyear,
      'endyear': instance.endyear,
      'commentnum': instance.commentnum,
      'currentpeoplenum': instance.currentpeoplenum,
      'mincost': instance.mincost,
      'maxcost': instance.maxcost,
      'address': instance.address,
      'addresstitle': instance.addresstitle,
      'lat': instance.lat,
      'lng': instance.lng,
      'paytype': instance.paytype,
      'goodpriceid': instance.goodpriceid,
      'activityEvaluate': instance.activityEvaluate,
      'joinnum': instance.joinnum,
      'viewnum': instance.viewnum,
      'orderid': instance.orderid,
      'locked': instance.locked,
      'goodPiceModel': instance.goodPiceModel
    };
