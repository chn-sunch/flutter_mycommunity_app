import 'package:json_annotation/json_annotation.dart';

import '../../model/user.dart';
part 'community.g.dart';

@JsonSerializable()
class Community {
  String cid;//群聊id
  String communityname;//群聊名称
  int uid;//团长id
  int categoryid;//所属分类
  String province;//所在省份
  String city;//所在城市
  String joinrule;//加入规则
  String notice;//社团公告
  String clubicon;//社团图标
  String grade;//社团等级
  String score;//社团得分
  String username;
  List<User>? members;//成员
  String status;
  double star;//星级
  int limitnum;//限制人数
  int membernum;//成员人数
  int activitynum;
  String activityimages;
  int evaluatenum;

  Community(this.cid, this.communityname, this.categoryid, this.province, this.city, this.joinrule, this.notice,
      this.clubicon, this.grade, this.score, this.status, this.star, this.limitnum, this.membernum, this.username, this.uid, this.activitynum, this.activityimages, this.evaluatenum);


  Map<String, dynamic> toJson() => _$CommunityToJson(this);
  factory Community.fromJson(Map<String, dynamic> json) => _$CommunityFromJson(json);

  factory Community.fromNumm(){
    return Community("", "", 0, "", "", "", "", "", "", "", "",0,0,0,"",0,0,"",0);//好坑的实例化
  }
}
