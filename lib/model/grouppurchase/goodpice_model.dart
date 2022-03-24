import 'package:json_annotation/json_annotation.dart';

part 'goodpice_model.g.dart';

@JsonSerializable()
class GoodPiceModel{
  String goodpriceid = "";
  String title = "";//标题
  String content = "";//内容
  int category = 0;//分类
  String brand = "";//品牌
  double discount = 1;//折扣
  String endtime = "";//折扣结束时间
  String createtime = "";
  String albumpics = "";
  String pic = "";
  int sellnum = 0;//销售数量
  int collectionnum = 0;//收藏数量
  String province = "";//所在省
  String city = "";//所在城市
  int uid = 0;//用户id
  String username = "";//名称
  String profilepicture = "";//
  int likenum = 0;
  int unlikenum = 0;
  int commentnum = 0;
  int productstatus = 1; //0未审核  1已审核 2退回 3已过期
  double satisfactionrate = 0;//好评率
  int activitycount = 0; //活动数
  String tag = "";
  String msg = "";
  String addresstitle = "";
  String address = "";
  double lat = 0;
  double lng = 0;
  double mincost = 0;
  double maxcost = 0;
  int evaluatenum = 0;

  GoodPiceModel(this.goodpriceid, this.title, this.content, this.category, this.brand,
      this.discount,  this.endtime, this.createtime, this.albumpics, this.pic, this.collectionnum, this.sellnum,
      this.province, this.city, this.uid, this.username, this.profilepicture, this.likenum, this.unlikenum,
      this.commentnum, this.productstatus, this.satisfactionrate, this.activitycount, this.tag, this.msg, this.addresstitle, this.address,
  this.lat, this.lng, this.mincost, this.maxcost, this.evaluatenum);

  factory GoodPiceModel.fromJson(Map<String, dynamic> json) => _$GoodPiceModelFromJson(json);

  GoodPiceModel.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.goodpriceid = data['goodpriceid'];
    this.title = data['title'];
    this.content = data['content'];
    this.category = data['category'];
    this.brand = data['brand'];
    this.discount = data['discount'];
    this.endtime = data['endtime'];
    this.createtime = data['createtime'];
    this.albumpics = data['albumpics'];
    this.pic = data['pic'];
    this.collectionnum = data['collectionnum'];
    this.province = data['province'];
    this.city = data['city'];
    this.uid = data['uid'];
    this.username = data['username'];
    this.profilepicture = data['profilepicture'];
    this.likenum = data['likenum'];
    this.unlikenum = data['unlikenum'];
    this.commentnum = data['commentnum'];
    this.productstatus = data['productstatus'];
    this.satisfactionrate = data['satisfactionrate'];
    this.activitycount = data['activitycount'];
    this.tag = data['tag'];
    this.addresstitle = data['addresstitle'];
    this.address = data['address'];
    this.lat = data['lat'];
    this.lng = data['lng'];
    this.sellnum = data['sellnum'] ?? 0;
    this.mincost = data['mincost'];
    this.maxcost = data['maxcost'];
    this.evaluatenum = data['evaluatenum'] != null ? data['evaluatenum'] as int : 0;
  }
}