import 'package:json_annotation/json_annotation.dart';

import '../../global.dart';
import '../user.dart';

part 'timelinesync.g.dart';

enum ContentType { Type_Text, Type_System, Type_Image, Type_Sound, Type_Location, Type_shared}//Type_localSystem本地的系统通知，不从服务器取数据

@JsonSerializable()
class TimeLineSync {
  String? timeline_id;
  int? sequence_id;
  int? conversation;
  String? send_time;
  int? sender;
  String? serdername;
  String? serderpicture;
  String? content;
  int? contenttype;//0文本 1 系统 2 图片 3声音 4地图 5分享
  User? senderUser;
  bool? isplay = false;
  String? localpath;
  int? isopen = 0;//是否打开过红包
  String? source_id = "";//来源ID


  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['timeline_id'] = this.timeline_id;
    data['sequence_id'] = this.sequence_id;
    data['conversation'] = this.conversation;
    data['send_time'] = this.send_time;
    data['serdername'] = this.senderUser == null ? this.serdername : this.senderUser!.username;
    data['serderpicture'] = this.senderUser == null ? this.serderpicture : this.senderUser!.profilepicture;
    data['content'] = this.content;
    data['contenttype'] = this.contenttype;
    if(sender != null && sender == 0){
      data['sender'] = this.sender;
    }
    else {
      data['sender'] =
      this.senderUser == null ? this.sender : this.senderUser!.uid;
    }
    data['uid'] = Global.profile.user!.uid;
    data['localpath'] = this.localpath;
    data['isopen'] = this.isopen;
    data['source_id'] = this.source_id;
    return data;
  }

  TimeLineSync.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.timeline_id = data['timeline_id'];
    this.sequence_id = data['sequence_id'];
    this.conversation = data['conversation'];
    this.send_time = data['send_time'];
    this.sender = data['sender'];
    this.serdername = data['serdername'];
    this.serderpicture = data['serderpicture'];
    this.content = data['content'];
    this.contenttype = data['contenttype'];
    this.localpath = data['localpath'];
    this.isopen = data['isopen'];
    this.source_id = data['source_id'];
  }

  TimeLineSync.fromMapByServer(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.timeline_id = data['timeline_id'];
    this.sequence_id = data['sequence_id'];
    this.conversation = data['conversation'];
    this.send_time = data['send_time'];
    this.senderUser = (data['sender'] == null ? null
        : User.fromJson(data['sender'] as Map<String, dynamic>));
    this.serdername = (this.senderUser!.username == null ? "" : this.senderUser!.username);
    this.serderpicture = (this.senderUser!.profilepicture == null ? "" : this.senderUser!.profilepicture);
    this.content = data['content'];
    this.contenttype = data['contenttype'];
    this.localpath = '';
    this.source_id = data['source_id'];
  }


  TimeLineSync(this.timeline_id, this.sequence_id, this.conversation, this.send_time, this.senderUser,
      this.content, this.contenttype, this.localpath, this.source_id){
    if(conversation == 0){
      //拉黑取消拉黑举报等本地提示
      this.sender = 0;
      this.serdername = "system";
      this.serderpicture = "";
    }
    else{
      this.sender = senderUser!.uid;
      this.serdername = senderUser!.username;
      this.serderpicture = senderUser!.profilepicture;
    }
  }



//  Map<String, dynamic> toJson() => _$TimeLineSyncToJson(this);
  factory TimeLineSync.fromJson(Map<String, dynamic> json) => _$TimeLineSyncFromJson(json);
}