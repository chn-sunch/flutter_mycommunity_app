// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goodpice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoodPiceModel _$GoodPiceModelFromJson(Map<String, dynamic> json) =>
    GoodPiceModel(
      json['goodpriceid'] != null ?  json['goodpriceid'] as String : "",
      json['title'] != null ?  json['title'] as String : "",
      json['content'] != null ?  json['content'] as String : "",
      json['category'] != null ?  json['category'] as int : 0,
      json['brand'] != null ?  json['brand'] as String : "",
      json['discount'] != null ?  json['discount'] as double : 0,
      json['endtime'] != null ?  json['endtime'] as String : "",
      json['createtime'] != null ?  json['createtime'] as String : "",
      json['albumpics'] != null ?  json['albumpics'] as String : "",
      json['pic'] != null ?  json['pic'] as String : "",
      json['collectionnum'] != null ?  json['collectionnum'] as int : 0,
      json['sellnum'] != null ?  json['sellnum'] as int : 0,
      json['province'] != null ?  json['province'] as String : "",
      json['city'] != null ?  json['city'] as String : "",
      json['uid'] != null ?  json['uid'] as int : 0,
      json['username'] != null ?  json['username'] as String : "",
      json['profilepicture'] != null ?  json['profilepicture'] as String : "",
      json['likenum'] != null ?  json['likenum'] as int : 0,
      json['unlikenum'] != null ?  json['unlikenum'] as int : 0,
      json['commentnum'] != null ?  json['commentnum'] as int : 0,
      json['productstatus'] != null ?  json['productstatus'] as int : 0,
      json['satisfactionrate'] != null ?  json['satisfactionrate'] as double : 0,
      json['activitycount'] != null ?  json['activitycount'] as int : 0,
      json['tag'] != null ?  json['tag'] as String : "",
      json['msg'] != null ?  json['msg'] as String : "",

      json['addresstitle'] != null ?  json['addresstitle'] as String : "",
      json['address'] != null ?  json['address'] as String : "",
      json['lat'] != null ?  json['lat'] as double : 0,
      json['lng'] != null ?  json['lng'] as double : 0,
      json['mincost'] != null ?  json['mincost'] as double : 0,
      json['maxcost'] != null ?  json['maxcost'] as double : 0,

      json['evaluatenum'] != null ? json['evaluatenum'] as int : 0
    );

Map<String, dynamic> _$GoodPiceModelToJson(GoodPiceModel instance) =>
    <String, dynamic>{
      'goodpriceid': instance.goodpriceid,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'brand': instance.brand,
      'discount': instance.discount,
      'endtime': instance.endtime,
      'createtime': instance.createtime,
      'albumpics': instance.albumpics,
      'pic': instance.pic,
      'sellnum': instance.sellnum,
      'collectionnum': instance.collectionnum,
      'province': instance.province,
      'city': instance.city,
      'uid': instance.uid,
      'username': instance.username,
      'profilepicture': instance.profilepicture,
      'likenum': instance.likenum,
      'unlikenum': instance.unlikenum,
      'commentnum': instance.commentnum,
      'productstatus': instance.productstatus,
      'satisfactionrate': instance.satisfactionrate,
      'activitycount': instance.activitycount,
      'tag': instance.tag,
      'msg': instance.msg,
      'addresstitle': instance.addresstitle,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
      'mincost': instance.mincost,
      'maxcost': instance.maxcost
    };
