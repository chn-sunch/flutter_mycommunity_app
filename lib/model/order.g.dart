// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      json['orderid'] as String?,
      json['gpactid'] as String?,
      (json['gpprice'] as num?)?.toDouble(),
      json['uid'] as int?,
      json['createtime'] as String?,
      json['updatetime'] as String?,
      json['paymenttype'] as int?,
      json['goodpriceid'] != null ? json['goodpriceid'] as String : "",
      json['goodpricesku'] != null ? json['goodpricesku'] as String : "",
      json['productname'] as String?,
      json['productpic'] as String?,
      json['creategpuid'] as int?,
      json['specsid'] as int?,
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      json['activity'] == null
          ? null
          : Activity.fromJson(json['activity'] as Map<String, dynamic>),
      json['ordertype'] as int?,
      json['orderstatus'] as int?,
      json['productnum'] != null ? json['productnum'] as int : 0,
      json['expirestime'] as int?,
      json['goodpricetitle'] != null ? json['goodpricetitle'] as String : "",
      json['goodpricepic'] != null ? json['goodpricepic'] as String : "",
      json['touid'] != null ? json['touid'] as int : 0,
      json['goodpricebrand'] != null ? json['goodpricebrand'] as String : "",
      json['goodpricespeacename'] != null ? json['goodpricespeacename'] as String : ""
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'orderid': instance.orderid,
      'gpactid': instance.gpactid,
      'gpprice': instance.gpprice,
      'uid': instance.uid,
      'createtime': instance.createtime,
      'updatetime': instance.updatetime,
      'paymenttype': instance.paymenttype,
      'goodpriceid': instance.goodpriceid,
      'goodpricesku': instance.goodpricesku,
      'productname': instance.productname,
      'productpic': instance.productpic,
      'creategpuid': instance.creategpuid,
      'specsid': instance.specsid,
      'user': instance.user,
      'activity': instance.activity,
      'ordertype': instance.ordertype,
      'orderstatus': instance.orderstatus,
      'productnum': instance.productnum,
      'expirestime': instance.expirestime,
      'goodpricebrand': instance.goodpricebrand,
      'goodpricespeacename': instance.goodpricespeacename
    };
