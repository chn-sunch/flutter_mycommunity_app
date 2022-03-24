import 'package:flutter/material.dart';

import '../../common/json/city_json.dart';

class ListViewProvince extends StatefulWidget {
  ListViewProvince(){}
  @override
  _ListViewProvince createState() => _ListViewProvince();
}

class _ListViewProvince extends State<ListViewProvince> {
  List<String> keys = [];
  @override
  Widget build(BuildContext context) {
    keys = provincesData.keys.toList();
    return   Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('所在位置', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(0.0),
        itemCount: keys.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int position) {
        return buildItemWidget(context, position);
        },
      ),
    );
  }

  Widget buildItemWidget(BuildContext context, int index) {
    return _buildItemWidget(context, index);
  }

  Widget _buildItemWidget(BuildContext context, int index) {

    return  Container(
      child: ListTile(
        onTap: (){
          if(index == 0){
            //全国
            Map<String, dynamic> map = {"code":  "allCode", "provinceCode": "allCode", "name": "全国"};
            Navigator.of(context).pop<Map>(map);
            return;
          }
          if(provincesData[keys[index]]!.split(',').length > 1){
            Map<String, dynamic> map = {"code":  keys[index], "provinceCode": keys[index], "name": provincesData[keys[index]]!.split(',')[0]};
            Navigator.of(context).pop<Map>(map);
          }
          else {
            Navigator.pushNamed(context, '/ListViewCity',
                arguments: {"code": keys[index]})
                .then((onValue) {
              if (onValue != null)
                Navigator.of(context).pop<Map>(onValue as Map);
            });
          }
        },
        title: Text(provincesData[keys[index]]!.split(',')[0]),
        trailing: new Icon(Icons.keyboard_arrow_right)
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Color(0xffe5e5e5)))
      ),
    );
  }
}
