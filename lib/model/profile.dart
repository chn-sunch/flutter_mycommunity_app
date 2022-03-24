import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import '../global.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  User? user;
  Color? backColor;
  Color? fontColor;
  Color? disableColor;
  int backColorval;
  int fontColorval;
  String locationName;
  String locationCode;
  String locationGoodPriceName;
  String locationGoodPriceCode;
  double lat;
  double lng;
  ImageProvider? defProfilePicture;
  String? profilePicture;
  bool isLogGuided = true;
  List<String>? communitys = [];

  ///获取服务器静态json
  //0xFF9C27B0 紫色 0xFFFFFFFF 白色 Color(0xffff2442);
  Profile({this.user,  this.backColorval = 0xffff2442, this.fontColorval=0xFFFFFFFF,
     this.locationName= "", this.locationCode= "", profilePicture = "", this.isLogGuided=true, this.lat=0, this.lng=0, this.locationGoodPriceCode = "", this.locationGoodPriceName = ""}) {

    if(user != null){
      if(user!.profilepicture != null && user!.profilepicture!.isNotEmpty){
        defProfilePicture = new NetworkImage(user!.profilepicture!);
      }
    }
    else{
      defProfilePicture = AssetImage(Global.headimg);
//      setProfilepicture();
    }
    //backColor = Color(0xffff2442);
    backColor = Color(0xffff2442);
    fontColor = Color(fontColorval);
    disableColor = backColor!.withAlpha(100);

    if(disableColor == null)
      disableColor = Colors.purple.shade100;
  }

//  Future<void> setProfilepicture() async {
//    ///请求服务器配置
//    await _commonJSONController.getAppProfileConfig((Map<String, dynamic> data) {
//      if (data["data"] != null) {
//        for (int i = 0; i < data["data"].length; i++) {
//          profilePicture = data["data"][i]["value"];
//          if (user == null) {
//            ///用户未登录使用服务器配置图片
//            defProfilePicture =
//                CachedNetworkImageProvider(profilePicture);
//          }
//        }
//      }
//    });
//  }

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
