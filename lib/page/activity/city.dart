
import 'package:flutter/material.dart';
import '../../common/json/city_json.dart';

class ListViewCity extends StatefulWidget {
  Object? arguments;
  String _provinceCode = "";
  ListViewCity({this.arguments}){
    _provinceCode = (arguments as Map)["code"].toString();
  }

  @override
  _ListViewCity createState() => _ListViewCity();
}

class _ListViewCity extends State<ListViewCity> {
  List<String> _citykey = [];
  late Map<String, dynamic> _citydata;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _citydata  = citiesData[widget._provinceCode.toString()];
    _citykey = _citydata.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
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
          itemCount: _citykey.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int position) {
            return buildItemWidget(context, position);
          }
      ),
    );
  }



  Widget buildItemWidget(BuildContext context, int index) {
    return _buildItemWidget(context, index);
  }

  Widget _buildItemWidget(BuildContext context, int index) {
    return  Container(
      child: ListTile(
          onTap: () async {
            Map<String, dynamic> map = {"code":  _citykey[index], "provinceCode": widget._provinceCode, "name": _citydata[_citykey[index]]["name"]};
            Navigator.of(context).pop<Map>(map);
          },
          title: Text(_citydata[_citykey[index]]["name"]),
          trailing: new Icon(Icons.keyboard_arrow_right)
      ),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Color(0xffe5e5e5)))
      ),
    );
  }

}
