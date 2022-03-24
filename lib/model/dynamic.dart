
import 'package:json_annotation/json_annotation.dart';

part 'dynamic.g.dart';

@JsonSerializable()
class Dynamic {
  int id;
  int uid;
  String actiontype;
  String actiondata;
  String createtime;

  Dynamic(this.id, this.uid, this.actiontype, this.actiondata,this.createtime);

  Map<String, dynamic> toJson() => _$DynamicToJson(this);
  factory Dynamic.fromJson(Map<String, dynamic> json) => _$DynamicFromJson(json);
}