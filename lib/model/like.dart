//final String createLikeTableShelf = "CREATE TABLE $t_like (likeid INTEGER , uid INTEGER, liketype INTEGER, contentid TEXT)";
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'like.g.dart';

@JsonSerializable()
class Like {
  int? likeid;//活动点赞， 留言点赞， 评价点赞， bug点赞，建议点赞表的id主键
  int? liketype;//点赞类型 0 活动 1 留言 2评价 3bug 4建议
  String? contentid;//活动或者留言、评价等的id
  User? user;
  int? touid;
  String? createtime;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['likeid'] = this.likeid;
    data['uid'] = this.user!.uid;
    data['username'] = this.user!.username;
    data['profilepicture'] = this.user!.profilepicture;
    data['liketype'] = this.liketype;
    data['contentid'] = this.contentid;
    data['touid'] = this.touid;
    data['isread'] = 0;
    data['createtime'] = this.createtime;
    return data;
  }

  Like.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.likeid = data['likeid'];
    this.user = User(0,"", "","","","","","","",0,"",0,0,"",0,"",0,0,0,0,0, "", 0, 0, 0, 0, 0, "", "", "", 0, "", "", false, 0, 0, 0, "", "", "");
    this.user!.profilepicture = data['profilepicture'];
    this.user!.username = data['username'];
    this.user!.uid = data['uid'];
    this.liketype = data['liketype'];
    this.contentid = data['contentid'];
    this.touid = data['touid'];
    this.createtime = data['createtime'];
  }


  Like(this.likeid, this.user,  this.liketype, this.contentid, this.touid, this.createtime);

  Map<String, dynamic> toJson() => _$LikeToJson(this);
  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);
}