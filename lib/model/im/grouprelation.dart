
import 'package:json_annotation/json_annotation.dart';

import '../../global.dart';
part 'grouprelation.g.dart';

@JsonSerializable()
class GroupRelation{
  int? id;
  String timeline_id = "";
  int? uid;
  String? jointime;
  int? readindex;
  int unreadcount = 0;
  String? group_name1;
  String? clubicon;
  String? name;
  String? newmsgtime;
  String? newmsg;
  int? timelineType;
  int? istop;
  int? relationtype;//0活动群，1社团群 //2私聊  //3活动群团购
  int? status;//是否拉黑 1正常 2拉黑
  int? locked;//订单是否已经锁定（发货）0未锁定  1已锁定 2已完成
  String? memberupdatetime;//活动成员更新的时间
  String? oldmemberupdatetime;//上次更新的时间
  int? isnotservice;
  String? source_id;
  String goodpriceid = "";

  GroupRelation(this.id, this.timeline_id,  this.readindex, this.unreadcount, this.group_name1, this.clubicon, this.name,
      newmsgtime, newmsg, this.timelineType, this.relationtype, this.status, this.locked, this.memberupdatetime,
      this.isnotservice, this.source_id, this.goodpriceid){
     this.newmsgtime = newmsgtime== null ? '' : newmsgtime;
     this.newmsg = newmsg == null ? '' : newmsg;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    data['timeline_id'] = this.timeline_id;
    data['readindex'] = this.readindex;
    data['unreadcount'] = this.unreadcount;
    data['group_name1'] = this.group_name1;
    data['clubicon'] = this.clubicon;
    data['name'] = this.name;
    data['newmsgtime'] = this.newmsgtime;
    data['newmsg'] = this.newmsg;
    data['timelineType'] = this.timelineType;
    data['uid'] = Global.profile.user!.uid;
    data['istop'] = 0;
    data['isdel'] = 0;
    data['relationtype'] = this.relationtype;
    data['status'] = this.status;
    data['locked'] = this.locked;
    data['memberupdatetime'] = this.memberupdatetime;
    data['oldmemberupdatetime'] = "1999-01-01 00:00:01";
    data['isnotservice'] = 0;
    data['source_id'] = this.source_id;
    data['goodpriceid'] = this.goodpriceid;
    return data;
  }

  GroupRelation.fromMap(Map<String, dynamic> data) {
    this.id = data['id'];
    this.timeline_id = data['timeline_id'];
    this.readindex = data['readindex'];
    this.unreadcount = data['unreadcount'];
    this.group_name1 = data['group_name1'];
    this.clubicon = data['clubicon'];
    this.name = data['name'];
    this.newmsgtime = data['newmsgtime'];
    this.newmsg = data['newmsg'];
    this.timelineType = data['timelineType'];
    this.istop = data['istop'];
    this.relationtype = data['relationtype'];
    this.status = data['status'];
    this.locked = data['locked'];
    this.memberupdatetime = data['memberupdatetime'];
    this.oldmemberupdatetime = data['oldmemberupdatetime'];
    this.isnotservice = data['isnotservice'];
    this.source_id = data['source_id'];
    this.goodpriceid = data['goodpriceid'];
    this.uid = data['uid'];
  }

  Map<String, dynamic> toJson() => _$GroupRelationToJson(this);
  factory GroupRelation.fromJson(Map<String, dynamic> json) => _$GroupRelationFromJson(json);
}