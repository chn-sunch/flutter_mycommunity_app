
part 'usershared.g.dart';



class UserShared {
  int? sharedid;
  int? uid;
  String? content;
  String? contentid;
  String? image;
  int? sharedtype;
  String? createtime;

  int? fromuid;
  String? fromusername;
  String? fromprofilepicture;
  double? mincost;
  double? maxcost;
  double? lat;//坐标
  double? lng;//坐标



  UserShared(this.sharedid, this.uid, this.content, this.contentid, this.image, this.sharedtype, this.createtime, this.fromuid,
      this.fromusername, this.fromprofilepicture, this.mincost, this.maxcost, this.lat, this.lng);

  factory UserShared.fromJson(Map<String, dynamic> json) => _$UserSharedFromJson(json);

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['sharedid'] = this.sharedid;
    data['uid'] = this.uid;
    data['content'] = this.content;
    data['contentid'] = this.contentid;
    data['image'] = this.image;
    data['sharedtype'] = this.sharedtype;
    data['createtime'] = this.createtime;
    data['fromuid'] = this.fromuid;
    data['fromusername'] = this.fromusername;
    data['fromprofilepicture'] = this.fromprofilepicture;
    data['mincost'] = this.mincost;
    data['maxcost'] = this.maxcost;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['isread'] = 0;

    return data;
  }



  UserShared.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.sharedid = data['sharedid'];
    this.uid = data['uid'];
    this.fromuid = data['touid'];
    this.content = data['content'];
    this.createtime = data['createtime'];
    this.contentid = data['contentid'];
    this.image = data['image'];
    this.sharedtype = data['sharedtype'];

    this.fromprofilepicture = data['fromprofilepicture'];
    this.fromusername = data['fromusername'];
    this.mincost = data['mincost'];
    this.maxcost = data['maxcost'];

    this.lat = data['lat'];
    this.lng = data['lng'];

  }
}
