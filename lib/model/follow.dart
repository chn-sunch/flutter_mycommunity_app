import 'package:json_annotation/json_annotation.dart';

part 'follow.g.dart';

@JsonSerializable()
class Follow {
  int? id;
  int? uid;
  int? fans;
  String? username;
  String? profilepicture;
  int? isread;
  String? createtime;
  int? type; //0关注 1点赞

  Map<String, dynamic> toMap(Follow type) {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    data['uid'] = this.uid;
    data['fans'] = this.fans;
    data['username'] = this.username;
    data['profilepicture'] = this.profilepicture;
    data['isread'] = 0;
    data['createtime'] = this.createtime;
    data['type'] = this.type;

    return data;
  }

  Follow.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.id = data['id'];
    this.uid = data['uid'];
    this.fans = data['fans'];
    this.username = data['username'];
    this.profilepicture = data['profilepicture'];
    this.isread = data['isread'];
    this.createtime = data['createtime'];
    this.type = data['type'];
  }


  Follow(this.uid, this.username,  this.profilepicture, this.isread, this.fans, this.createtime, this.id, this.type);

  Map<String, dynamic> toJson() => _$FollowToJson(this);
  factory Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);
}