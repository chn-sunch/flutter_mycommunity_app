import 'dart:convert';
import 'package:flutter/material.dart';

import '../../model/grouppurchase/goodpice_model.dart';
import '../../model/grouppurchase/skuspecs.dart';
import '../../service/gpservice.dart';
import '../../widget/my_divider.dart';
import '../../widget/circle_headimage.dart';
import '../../util/showmessage_util.dart';

import '../../global.dart';
import 'widget/numberwidget.dart';

class CreateOrder extends StatefulWidget {
  Object? arguments;
  late GoodPiceModel goodPiceModel;
  late String actid;


  CreateOrder({required this.arguments}){
    if(arguments != null) {
      goodPiceModel = (arguments as Map)["goodprice"];
      actid = (arguments as Map)["actid"];
    }
  }
  @override
  _CreateOrderPageState createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrder> {
  int _selectIndexSpeace1 = -1; //规格1的选中
  int _selectIndexSpeace2 = -1; //规格2的选中
  String _selectIndexValue1 = ""; //选定的值规格1
  String _selectIndexValue2 = ""; //选定的值规格2
  GPService _gpService = new GPService();


  int _productNum = 1;
  String _speace1Name = "";
  String _speace2Name = "";
  List<Skuspecs> skuSpecsList = [];
  int _speaceCount = 0; //规格的数量

  String _priceinfo = "";//价格描述
  String _seltext = "";//选的内容文本
  num _selprice = -1;//选中显示的价格
  num _saleprice = -1;//实际价格，优惠等
  String _specsid = "";
  List _responseJson = [];



  _getGoodPriceSpecsList() async {
    skuSpecsList = await _gpService.getProductSpecsList(widget.goodPiceModel.goodpriceid);
    if(skuSpecsList != null && skuSpecsList.length > 0){
      _responseJson = json.decode(skuSpecsList[0].spdata);
      _speaceCount = _responseJson.length;

      if(skuSpecsList != null && skuSpecsList.length > 0){
        skuSpecsList.sort((l, r) => l.cost.compareTo(r.cost));
        num min = skuSpecsList[0].cost;
        num max = skuSpecsList[skuSpecsList.length - 1].cost;

        if(min != max){
          _priceinfo = '${min}~${max}';
        }
        else{
          _priceinfo = '${min}';
        }
      }

      setState(() {

      });
    }

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getGoodPriceSpecsList();
    _getSelValue( );
  }

  @override
  Widget build(BuildContext context) {

    List<Map> maps = [];
    //处理规格种类

    List<Widget> specsContent = []; //活动内容
    if(_responseJson.length == 1)
      _speace1Name =  _responseJson[0]["key"].toString();

    if(_responseJson.length > 1)
      _speace2Name =  _responseJson[1]["key"].toString();

    if(_seltext.isEmpty){
      _seltext = '请选择 ${_speace1Name}  ${_speace2Name}';
    }
    //keys规格
    for (int i = 0; i < _responseJson.length; i++) {
      List<Widget> values = [];//规格值
      for(int j =0; j < skuSpecsList.length; j++){
        List temJson = json.decode(skuSpecsList[j].spdata);
        //最多只有两种规格
        if(_responseJson[i]["key"].toString() == temJson[0]["key"].toString()){
          values.add(ChoiceChip(
            selectedShadowColor: Global.profile.backColor,
            label: Text(temJson[0]["value"].toString()),
            selected: _selectIndexSpeace1 == j,
            onSelected:  (v) {
              setState(() {
                _selectIndexSpeace1 = j;
                _selectIndexValue1 = temJson[0]["value"].toString();
                _specsid = skuSpecsList[j].specsid.toString();
                _getSelValue( );
              });
            },
          ));
        }
        if(temJson.length > 1) {
          if (_responseJson[i]["key"].toString() ==
              temJson[1]["key"].toString()) {
            values.add(ChoiceChip(
              selectedShadowColor: Global.profile.backColor,
              label: Text(temJson[1]["value"].toString()),
              selected: _selectIndexSpeace2 == j,
              onSelected: (v) {
                setState(() {
                  _selectIndexSpeace2 = j;
                  _selectIndexValue2 = temJson[1]["value"].toString();
                  _getSelValue();
                });
              },
            ));
          }
        }
      }
      specsContent.add(
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(_responseJson[i]["key"], style: TextStyle(color:  Colors.black87, fontSize: 16),),
                ),
                Wrap(
                  spacing: 13,
                  children: values,
                )
              ],
            ),
          )
      );
    }

    specsContent.add(MyDivider());
    specsContent.add(Container(
        child: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text('数量', style: TextStyle(color:  Colors.black87, fontSize: 16),),
              ),
              NumberControllerWidget(
                numText: _productNum.toString(),
                addValueChanged: (num){
                  setState(() {
                    _productNum = num;
                    _getSelValue();
                  });
                },
                removeValueChanged: (num){
                  setState(() {
                    _productNum = num;
                    _getSelValue();
                  });                },
                updateValueChanged: (num){
                  setState(() {
                    _productNum = num;
                    _getSelValue();
                  });                },
              )
            ],
          ),
        )
    ),);
    specsContent.add(MyDivider());

    return  Scaffold(
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(widget.goodPiceModel.title, style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
          children: [
            buildHeadInfo(),
            Expanded(
              child: ListView(
                children: specsContent,
              ),
            ),

            _buildBtn()
          ]
      ),
    );
  }

  void _getSelValue(){
    //只有一种规格
    if(_speaceCount == 1){
      if(_selectIndexValue1 != ""){
        for(int i =0; i < skuSpecsList.length; i++){
          List temJson = json.decode(skuSpecsList[i].spdata);
          if(_selectIndexValue1 == temJson[0]["value"].toString()) {
            _selprice = skuSpecsList[i].cost * _productNum;;
            _saleprice = skuSpecsList[i].cost * widget.goodPiceModel.discount * _productNum;;
            _saleprice = num.parse(_saleprice.toStringAsFixed(2));
            _seltext = '已选择： ${_selectIndexValue1}';
            _selectIndexValue2 = "";
          }
        }
      }
    }

    //有两种规格
    if(_speaceCount == 2){
      if(_selectIndexValue1 != ""){
        _seltext = '请选择： ${_speace2Name}';
      }

      if(_selectIndexValue2 != ""){
        _seltext = '请选择： ${_speace1Name}';
      }

      if(_selectIndexValue1.isNotEmpty && _selectIndexValue2.isNotEmpty){
        for(int i =0; i < skuSpecsList.length; i++){
          List temJson = json.decode(skuSpecsList[i].spdata);
          if(_selectIndexValue1 == temJson[0]["value"].toString() && _selectIndexValue2 == temJson[1]["value"].toString()) {
            _selprice = skuSpecsList[i].cost * _productNum;
            _saleprice = skuSpecsList[i].cost * widget.goodPiceModel.discount * _productNum;
            //saleprice.toStringAsFixed(2);
            _saleprice = num.parse(_saleprice.toStringAsFixed(2));
          }
        }

        _seltext = '已选择： ${_selectIndexValue1} ${_selectIndexValue2}';
      }
    }
  }

  Widget buildHeadInfo(){
    Widget price;
    if(_selprice == -1){
      price = Text('￥${_priceinfo}', style: TextStyle(color: Global.profile.backColor, fontSize: 15),);
    }
    else if(_selprice == _saleprice){
      price = Text('￥${_selprice}', style: TextStyle(color: Global.profile.backColor, fontSize: 15),);
    }
    else {
      price = Row(
        children: [
          Text('￥${_selprice}', style: TextStyle(color: Global.profile.backColor, fontSize: 16),),
          SizedBox(width: 10,),
          Text('折后 ￥${_saleprice}', style: TextStyle(color: Global.profile.backColor, fontSize: 14))
        ],
      );
    }

    return Container(
      height: 110,
      color: Colors.white,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 10),
            height: 100,
            width: 100,
            child: ClipRRectOhterHeadImageContainer(imageUrl: widget.goodPiceModel.pic,  cir: 10,),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  price,
                  Text(_seltext, style: TextStyle(color:  Colors.black87, fontSize: 15),)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBtn(){
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
        color: Colors.white,
        height: 50,
        width: double.infinity,
        alignment: Alignment.centerRight,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                  child: Text('确定选择', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
                  style: ButtonStyle(
                    backgroundColor:  _specsid == "" ? MaterialStateProperty.all(Global.defredcolor.withAlpha(119)) :
                      MaterialStateProperty.all(Global.defredcolor),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9))),
                  ) ,
                  onPressed: () async {
                    if(_specsid == ""){
                      return;
                    }

                    String speaceName = "";

                    if(_speace1Name != ""){
                      speaceName += _speace1Name + "|";
                    }

                    if(_speace2Name != ""){
                      speaceName += _speace2Name + "|";
                    }
                    if(speaceName != "") {
                      speaceName = speaceName.substring(0, speaceName.length -1);
                    }

                    Navigator.pushNamed(context, '/OrderConfirm',
                        arguments: {"goodprice": widget.goodPiceModel, "specsid": _specsid,
                        "productNum": _productNum, "specsname": speaceName , "saleprice": _saleprice});
                  }),
            ),
          ],
        )
    );
  }
}

