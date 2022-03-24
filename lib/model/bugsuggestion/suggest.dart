import 'package:json_annotation/json_annotation.dart';

import '../../model/user.dart';
part 'suggest.g.dart';

@JsonSerializable()
class Suggest{
  String suggestid;
  String content;
  String images;
  String createtime;
  int commentcount;
  int likenum;
  User? user;
  bool islike = false;

  Suggest(this.suggestid, this.content, this.images, this.createtime, this.commentcount, this.likenum, this.user){

  }

  Map<String, dynamic> toJson() => _$SuggestToJson(this);
  factory Suggest.fromJson(Map<String, dynamic> json) => _$SuggestFromJson(json);
}