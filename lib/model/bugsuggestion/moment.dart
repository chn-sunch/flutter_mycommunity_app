import 'package:json_annotation/json_annotation.dart';

import '../user.dart';
part 'moment.g.dart';

@JsonSerializable()
class Moment{
  String momentid = "";
  String content = "";
  String images = "";
  String createtime = "";
  int commentcount = 0;
  int likenum = 0;
  String voice = "";
  String coverimgwh = "";
  String category = "";

  User? user;
  bool islike = false;

  Moment(this.momentid, this.content, this.images, this.createtime, this.commentcount, this.likenum,
      this.user, this.voice, this.coverimgwh, this.category){

  }

  Map<String, dynamic> toJson() => _$MomentToJson(this);
  factory Moment.fromJson(Map<String, dynamic> json) => _$MomentFromJson(json);
}