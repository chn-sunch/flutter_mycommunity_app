import 'package:json_annotation/json_annotation.dart';

import 'activityevaluate.dart';
import 'user.dart';
import 'grouppurchase/goodpice_model.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  String actid = "";
  List<User>? members;
  int? peoplenum;
  String? createtime;
  String? updatetime;
  String content = "";
  String? score;
  String? actimagespath;
  int? status;
  User? user;
  String? actcity;
  String? actprovince;
  String? coverimg;
  String coverimgwh = "";
  int likenum = 0;
  int collectionnum = 0;
  int? startyear;
  int? endyear;
  int? commentnum;
  int? currentpeoplenum;
  double maxcost = 0;
  double mincost = 0;
  String? address;//活动位置
  String? addresstitle;
  double? lat;//坐标
  double? lng;//坐标
  int? paytype;//0 免费  1后付款  2先付款团购
  String? goodpriceid;//goodprice

  ActivityEvaluate? activityEvaluate;//未评价 1已评价
  int? joinnum;
  int? viewnum;
  String? orderid;
  int? locked;//是否已经开始活动
  GoodPiceModel? goodPiceModel;


  Activity(this.actid,  this.peoplenum, this.createtime,
      this.updatetime, this.content, this.score, this.actimagespath, this.status, this.user,
      this.actcity, this.actprovince, this.coverimg, this.coverimgwh,
      this.likenum, this.collectionnum, this.startyear, this.endyear, this.commentnum, this.currentpeoplenum,
      this.mincost, this.maxcost, this.address, this.lat, this.lng, this.addresstitle,  this.paytype,
      this.orderid, this.goodpriceid, this.joinnum, this.viewnum, this.locked, this.goodPiceModel);


  Map<String, dynamic> toJson() => _$ActivityToJson(this);
  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);

  factory Activity.fromNullObject(){
    Activity activity = Activity("", 0, "", "", "", "", "", 0, null,"","", "","", 0,0,0,0,0,0, 0.0, 0.0, "", 0.0, 0.0, "", 0, "", "", 0, 0, 0, null);

    activity.user = User(0, "", "","","","","","","",0,"",0,0,"",0,"",0 ,0 ,0 ,0 ,0, "", 0, 0, 0, 0, 0, "", "", "", 0, "", "", false, 0,0,0, "", "", "");
    return activity;
  }

  Activity.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.actid = data['actid'];
    this.coverimgwh = data['coverimgwh'];
    this.coverimg = data['coverimg'];
    this.content = data['content'];

    this.peoplenum = data['peoplenum'];
    this.user = User(0, "", "","","","","","","",0,"",0,0,"",0,"",0,0,0,0,0, "", 0, 0, 0, 0, 0, "", "", "", 0, "", "", false, 0,0,0, "", "", "");
    this.user!.profilepicture = data['profilepicture'];
    this.user!.username = data['username'];

    this.address = data["address"];
    this.lat = data["lat"];
    this.lng = data["lng"];
    this.mincost = data["mincost"];
    this.maxcost = data["maxcost"];
    this.addresstitle = data["addresstitle"];
  }

  Activity.fromMapCollection(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.actid = data['actid'];
    this.coverimgwh = data['coverimgwh'];
    this.coverimg = data['coverimg'];
    this.content = data['content'];

    this.peoplenum = data['peoplenum'];
    this.user = User(0, "", data["user"]["username"],"","","","","",data["user"]["profilepicture"],0,"",0,0,"",0,"",0,0,0,0,0, "",
        0, 0, 0, 0, 0, "", "", "", 0,"","", false, 0, 0, 0, "", "", "");
    this.user!.profilepicture = data["user"]["profilepicture"];
    this.user!.username = data["user"]["username"];

    this.address = data["address"];
    this.lat = data["lat"];
    this.lng = data["lng"];
    this.mincost = data["mincost"];
    this.maxcost = data["maxcost"];
    this.addresstitle = data["addresstitle"];
  }

  Activity.fromMapCollectionTable(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.actid = data['actid'];
    this.coverimgwh = data['coverimgwh'];
    this.coverimg = data['coverimg'];
    this.content = data['content'];
    this.peoplenum = data['peoplenum'];
    this.user = User(0, "", data["username"],"","","","","",data["profilepicture"],0,"",0,0,"",0,"",0,0,0,0,0, "", 0, 0, 0, 0, 0,
        "", "", "", 0, "", "", false, 0, 0, 0, "", "", "");
    this.user!.profilepicture = data["profilepicture"];
    this.user!.username = data["username"];
    this.address = data["address"];
    this.lat = data["lat"];
    this.lng = data["lng"];
    this.mincost = data["mincost"];
    this.maxcost = data["maxcost"];
    this.addresstitle = data["addresstitle"];
  }
}
