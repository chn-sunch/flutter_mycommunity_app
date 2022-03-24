import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
import '../global.dart';

part 'commentreply.g.dart';

enum ReplyMsgType { replymsg, commentmsg, sysnotice, newmember, newfollowed, evaluatemsg, evaluatereplymsg, newfriend, updatefriend,
  sharedReaded, newliked, bugcommentmsg, bugreplymsg, suggestcommentmsg, suggestreplymsg, evaluateactivity, ordermsg, goodpricecommentmsg,
  goodpricereplymsg, orderexpiration, momentcommentmsg, momentreplymsg}

@JsonSerializable()
class CommentReply {
  int? replyid;
  String? actid;
  int? commentid;
  int? evaluateid;
  User? replyuser;
  User? touser;
  String? replycontent;
  String? replycreatetime;
  bool? isread;
  String? type;//0回复 1评论
  bool? ismaster;//是否是楼主
  String? actcontent;
  String? coverimg;
  String? imagepaths;


  Map<String, dynamic> toMap(ReplyMsgType type) {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['replyid'] = this.replyid;
    data['actid'] = this.actid;
    data['commentid'] = this.commentid;
    data['replycontent'] = this.replycontent;
    data['uid'] = this.replyuser!.uid;
    data['isread'] = this.isread! ? 1 : 0;
    data['replycreatetime'] = this.replycreatetime;
    data['username'] = this.replyuser!.username;
    data['profilepicture'] = this.replyuser!.profilepicture;
    data['touid'] = Global.profile.user!.uid;
    data['type'] = type.toString();
    data['ismaster'] = this.ismaster! ? 1 : 0;
    data['actcontent'] = this.actcontent;
    data['coverimg'] = this.coverimg;
    data['imagepaths'] = this.imagepaths;
    data['evaluateid'] = this.evaluateid;


    return data;
  }

  CommentReply.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.actid = data['actid'];

    this.replyid = data['replyid'];
    this.commentid = data['commentid'];
    this.replycontent = data['replycontent'];
    this.replyuser = User(data['uid'], "", data['username'],  null, null, null, null, "", data['profilepicture'], null,null
        , 0, 0, null, null,"", 0, 0, 0, 0, 0, "",0,0,0,0, 0, "", "", "", 0, "", "",false, 0, 0, 0, "", "", "");
    this.touser = null;
    this.replycreatetime = data['replycreatetime'];
    this.isread = data['isread'] == 1 ? true : false;
    this.ismaster = data['ismaster'] == 1 ? true : false;
    this.actcontent = data['actcontent'];
    this.coverimg = data['coverimg'];
    this.evaluateid = data['evaluateid'];
    this.imagepaths = data['imagepaths'];
    this.type = data['type'];
  }

  CommentReply(this.replyid, this.commentid,  this.replyuser, this.touser, this.replycontent, this.replycreatetime, this.isread, this.actid,
      this.ismaster, this.actcontent, this.coverimg, this.evaluateid, this.imagepaths);

  Map<String, dynamic> toJson() => _$CommentReplyToJson(this);
  factory CommentReply.fromJson(Map<String, dynamic> json) => _$CommentReplyFromJson(json);
}