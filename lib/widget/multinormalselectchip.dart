import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyMultiNormalSelectChip extends StatefulWidget {
  /// 标签的list
  final List<String> dataList;

  /// 标签的list
  final List<String> selectList;
  final Function(List<String>) onSelectionChanged;

  MyMultiNormalSelectChip(this.dataList, {required this.selectList,required this.onSelectionChanged});


  @override
  _MyMultiNormalSelectChipState createState() => _MyMultiNormalSelectChipState(selectList);
}

class _MyMultiNormalSelectChipState  extends State<MyMultiNormalSelectChip> {
  List<String> selectList;

  _MyMultiNormalSelectChipState(this.selectList);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        selectList.length > 0 ?Padding(
          child: Text("已选话题", style: TextStyle(color: Colors.grey, fontSize: 13),),
          padding: EdgeInsets.only(left: 10, bottom: 10),
        ):Container(),
        Wrap(
          alignment: WrapAlignment.start,
          children: _buildselectedChoiceList(),
        ),
        Padding(
          child: Text("热门话题", style: TextStyle(color: Colors.grey, fontSize: 13),),
          padding: EdgeInsets.only(left: 10, bottom: 10,top: 10),
        ),
        Container(
          height: 188,
          child: ListView(
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.start,
                children: _buildChoiceList(),
              ),
            ],
          )
        )
      ],
    );
  }
  ///创建标签
  _buildChoiceList() {
    List<Widget> choices = [];
    widget.dataList.forEach((item) {
      choices.add(Container(
        margin: EdgeInsets.only(left: 10),
        child: ChoiceChip(
          label: Text(
            '#${item}',
            style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: selectList.contains(item)?FontWeight.bold:FontWeight.w100),
          ),
          shape: StadiumBorder(
              side: BorderSide(
                  width: 1,
                  color: Colors.black12,
                  style: BorderStyle.solid),
          ),

          selected: selectList.contains(item),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          selectedColor: Colors.white,
          backgroundColor: Colors.white,
          onSelected: (selected) {

            setState(() {
              if(selectList.contains(item)) {
                selectList.remove(item);
              }
              else{
                // if(selectList.length >= 1){
                //   return;
                // }
                selectList.removeRange(0, selectList.length);
                selectList.add(item);
              }
              widget.onSelectionChanged(selectList);
            });
          },
        ),
      ));
    });
    return choices;
  }
  ///已选标签
  _buildselectedChoiceList(){
    List<Widget> choices = [];
    selectList.forEach((item) {
      choices.add(Container(
        margin: EdgeInsets.only(left: 10),
        child: ChoiceChip(
          label: Text(
            '#${item} x',
            style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: selectList.contains(item)?FontWeight.bold:FontWeight.w100),
          ),
          shape: StadiumBorder(
            side: BorderSide(
                width: 1,
                color: Colors.black12,
                style: BorderStyle.solid),
          ),
          selected: selectList.contains(item),
          selectedColor: Colors.white,
          backgroundColor: Colors.white,
          onSelected: (selected) {
            setState(() {
              selectList.contains(item)
                  ? selectList.remove(item)
                  : selectList.add(item);
              widget.onSelectionChanged(selectList);
            });
          },
        ),
      ));
    });
    return choices;
  }
  Widget selectedChoice(){
    return Column(
      children: <Widget>[
        Padding(
          child: Text("已选标签", style: TextStyle(color: Colors.grey, fontSize: 13),),
          padding: EdgeInsets.only(left: 10, bottom: 10),
        ),
        Wrap(
          alignment: WrapAlignment.start,
          children: _buildChoiceList(),
        )
      ],
    );
  }
}
