import 'package:json_annotation/json_annotation.dart';

import 'activity.dart';
import 'user.dart';

part 'order.g.dart';

@JsonSerializable()
class Order{
  String? orderid;
  String? gpactid;
  double? gpprice;
  int?  uid;
  String? createtime;
  String? updatetime;
  int? paymenttype;
  String goodpriceid = "";
  String goodpricesku = "";
  String goodpricebrand = "";
  String? productname;
  String? productpic;
  int? creategpuid;//创建活动的发起人
  int? specsid;
  User? user;
  Activity? activity;
  int? ordertype;//订单类型0拼玩订单3团购订单 和聊天关系表中的relationtype一致
  int? orderstatus;//订单状态，0待付款  1已付款  2已退款 3已转账
  int productnum = 0;
  int? expirestime;//超时时间秒
  String goodpricetitle = "";
  String goodpricepic = "";
  int touid = 0;
  String goodpricespeacename;


  Order(this.orderid, this.gpactid, this.gpprice, this.uid, this.createtime, this.updatetime, this.paymenttype, this.goodpriceid, this.goodpricesku,
      this.productname, this.productpic, this.creategpuid, this.specsid, this.user, this.activity, this.ordertype, this.orderstatus,
      this.productnum, this.expirestime, this.goodpricetitle, this.goodpricepic, this.touid, this.goodpricebrand, this.goodpricespeacename);

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}