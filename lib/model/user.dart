import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int uid;
  String username = "";
  String? sex;
  String? country;
  String? province;
  String? city;
  String signature = "";
  String? profilepicture;
  int? pwerrorcount;
  String? birthday;
  int? followers;//关注我的人
  int? following;//我关注的人
  bool isFollow = false;

  String? updatetime;//更新时间
  int? likenum;
  String? token = "";

  int? likeact;
  int? collectionact;
  int likecomment;
  int? likeevaluate;
  int? collectionproduct;
  String aliuserid = "";
  String wxuserid = "";
  String iosuserid = "";
  int likebug = 0;
  int likesuggest = 0;
  int likebugcomment = 0;
  int likesuggestcomment = 0;
  int likemoment = 0;
  int likemomentcomment = 0;
  int likegoodpricecomment = 0;
  String mobile = "";
  String? notinteresteduids;
  String? blacklist;
  String? goodpricenotinteresteduids;

  int? usertype;
  String? interest;
  String? voice;
  bool? isNew;//是否是新注册用户，用于广告监测统计
  int business = 0;//是否是商户
  String subject;//关注的主题

  User(this.uid, this.mobile, this.username, this.sex, this.country, this.province, this.city, this.signature, this.profilepicture,
      this.pwerrorcount, this.birthday, this.followers, this.following, this.updatetime, this.likenum, this.token, this.likeact, this.collectionact,
      this.likecomment, this.likeevaluate, this.collectionproduct, this.aliuserid, this.likebug, this.likesuggest, this.likebugcomment,
      this.likesuggestcomment, this.likegoodpricecomment, this.notinteresteduids, this.blacklist, this.goodpricenotinteresteduids,
      this.usertype, this.interest, this.voice, this.isNew, this.business, this.likemoment, this.likemomentcomment, this.wxuserid,
      this.iosuserid, this.subject);

  Map<String, dynamic> toJson() => _$UserToJson(this);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
