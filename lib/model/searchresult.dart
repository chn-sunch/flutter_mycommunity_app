import 'package:json_annotation/json_annotation.dart';

part 'searchresult.g.dart';

@JsonSerializable()
class SearchResult {
  int? id;
  String? content;
  String? updatetime;
  int? searchnum;

  Map<String, dynamic> toMap(SearchResult type) {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    data['content'] = this.content;
    data['updatetime'] = this.updatetime;
    data['searchnum'] = this.searchnum;

    return data;
  }

  SearchResult.fromMap(Map<String, dynamic> data) {
//    User user = User.fromJson(data['sender'] as Map<String, dynamic>);
    this.id = data['id'];
    this.content = data['content'];
    this.updatetime = data['updatetime'];
    this.searchnum = data['searchnum'];
  }

  SearchResult(this.id, this.content, this.updatetime,  this.searchnum);

  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
  factory SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);
}