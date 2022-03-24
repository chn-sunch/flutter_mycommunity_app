
class HisSearch {
  String? content;
  String? time;
  int? type;//0 社团搜索  1 活动搜索

  Map<String, dynamic> toMap(int type) {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['content'] = this.content;
    data['time'] = this.time;
    data['type'] = this.type;

    return data;
  }

  HisSearch.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.content = data['content'];
    this.time = data['time'];
    this.type = data['type'];
  }

  HisSearch(this.content, this.time, this.type);

}