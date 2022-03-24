import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/service/commonjson.dart';

/**
 * @desc   选择城市地区联动索引页
 * @author xiedong
 * @date   2020-04-30.
 */


class PhoneCountryCodeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PhoneCountryCodeViewState();
}

class PhoneCountryCodeViewState extends State<PhoneCountryCodeView> {
  CommonJSONService _commonJSONController = new CommonJSONService();

  List<String> letters = [];
  List<PhoneCountryCodeData> data = [];

  ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getPhoneCodeDataList();
  }

  getPhoneCodeDataList() async {
    var resultEntity;
    await _commonJSONController.getPhoneCode((Map<String, dynamic> data){
      if(data != null && data["data"] != null) {
        resultEntity = new PhoneCountryCodeEntity.fromJson(data);
      }
    });


    if(resultEntity.code==200){
      this.setState(() {
        data = resultEntity.data;
        for (int i = 0; i < data.length; i++) {
          letters.add(data[i].name.toUpperCase());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('国家和地区', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          data == null || data.length == 0 ? Text("") : Padding(
            padding: EdgeInsets.only(left: 20),
            child: ListView.builder(
                controller: _scrollController,
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      PhoneCodeIndexName(data[index].name.toUpperCase()),
                      ListView.builder(
                          itemBuilder: (BuildContext context, int index2) {
                            return InkWell(
                              child: Container(
                                  height: 46,
                                  width: double.maxFinite,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 50),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                            "${data[index].listData[index2].name}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff434343))),
                                        Text(
                                          "+${data[index].listData[index2].code}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  )),
                              onTap: () {
                                Navigator.of(context).pop(
                                    data[index].listData[index2].code);
                              },
                            );
                          },
                          itemCount: data[index].listData.length,
                          shrinkWrap: true,
                          physics:
                          NeverScrollableScrollPhysics()) //禁用滑动事件),
                    ],
                  );
                }),
          ),
          Align(
            alignment: new FractionalOffset(1.0, 0.5),
            child: SizedBox(
              width: 25,
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: ListView.builder(
                  itemCount: letters.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: Text(
                        letters[index],
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                        var height = index * 45.0;
                        for (int i = 0; i < index; i++) {
                          height += data[i].listData.length * 46.0;
                        }
                        _scrollController.jumpTo(height);
                      },
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

class PhoneCodeIndexName extends StatelessWidget {
  String indexName;

  PhoneCodeIndexName(this.indexName);

  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: double.infinity,
      child: Padding(
        child: Text(indexName,
            style: TextStyle(fontSize: 20, color: Color(0xff434343))),
        padding: EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}


class PhoneCountryCodeEntity {
  int code = 0;
  List<PhoneCountryCodeData> data = [];
  String message = "";

  PhoneCountryCodeEntity({this.code = 0, required this.data, this.message = ""});

  PhoneCountryCodeEntity.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null && json['data']['value'] != null) {
      this.code = 200;
      var content = jsonDecode(json['data']['value']);
      data = [];
      (content["data"] as List).forEach((v) {
        data.add(new PhoneCountryCodeData.fromJson(v));
      });

      message = json['data']['parameterkey'];

    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class PhoneCountryCodeData {
  List<PhoneCountryCodeDataListdata> listData = [];
  String name = "";

  PhoneCountryCodeData({ required this.listData, this.name = ""});

  PhoneCountryCodeData.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = [];
      (json['listData'] as List).forEach((v) {
        listData.add(new PhoneCountryCodeDataListdata.fromJson(v));
      });
    }
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listData != null) {
      data['listData'] = this.listData.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    return data;
  }
}

class PhoneCountryCodeDataListdata {
  String code = "";
  String name = "";
  int id = 0;
  String groupCode = "";

  PhoneCountryCodeDataListdata({this.code = "", this.name = "", this.id = 0, this.groupCode = ""});

  PhoneCountryCodeDataListdata.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    id = json['id'];
    groupCode = json['groupCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['id'] = this.id;
    data['groupCode'] = this.groupCode;
    return data;
  }
}