import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../model/aliyun/securitytoken.dart';
import '../../../common/iconfont.dart';
import '../../../util/showmessage_util.dart';
import '../../../util/common_util.dart';
import '../../../widget/captcha/block_puzzle_captcha.dart';
import '../../../widget/photo/playrecorder.dart';
import '../../../widget/photo/playvoice.dart';
import '../../../service/imservice.dart';
import '../../../service/aliyun.dart';
import '../../../global.dart';
import 'categoryinfo.dart';

class MomentReport extends StatefulWidget {

  @override
  _MomentReportState createState() => _MomentReportState();
}

class _MomentReportState extends State<MomentReport> {
  TextEditingController _textEditingController = new TextEditingController();
  List<AssetEntity> _images = [];
  int _imageMax = 4;//最多上传4张图
  AliyunService _aliyunService = new AliyunService();
  ImService _imService = new ImService();
  List<String> _imagesUrl = [];
  List<String> _imagesWH = [];//图片的分辨率
  FocusNode _contentfocusNode = FocusNode();

  SecurityToken? _securityToken;
  String _voice = "";
  List<String> _categorys = [];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textEditingController.dispose();
    _contentfocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context, "");
          },
        ),
        title: Text('', style: TextStyle(color: Colors.black, fontSize: 17)),
        centerTitle: true,
        actions: [
          SizedBox(
            height: 20,
            width: 66,
            child: InkWell(
              child: Container(
                margin: EdgeInsets.only(top: 13, bottom: 13, right: 10),
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Text('发布', style: TextStyle(color: Colors.white, fontSize: 14),),
                decoration: BoxDecoration(
                  color: Global.profile.backColor,
                  borderRadius: BorderRadius.all(new Radius.circular(9.0)),
                ),
              ),
              onTap: () async {
                String temimages = "";
                _imagesUrl.forEach((element) {
                  temimages += element + ",";
                });
                if(_images.length > 0){
                  temimages = temimages.substring(0, temimages.length-1);
                }

                String temcategory = "";
                _categorys.forEach((element) {
                  temcategory += element + ",";
                });
                if(_categorys.length > 0){
                  temcategory = temcategory.substring(0, temcategory.length-1);
                }

                if(_textEditingController.text == "" && temimages == "" && _voice == ""){
                  return;
                }

                String reportid = await _imService.reportMoment(
                    Global.profile.user!.uid,
                    Global.profile.user!.token!,
                    _textEditingController.text,
                    _voice,
                    temimages,
                    temimages.length > 0 ?_imagesWH[0] : "",
                    temcategory,
                    "", (code, error){
                      if(code == "-1008"){
                        //需要进行人机验证
                        loadingBlockPuzzle(context, temimages: temimages, temcategory: temcategory);
                      }
                      else {
                        ShowMessage.showToast(error);
                      }
                    });
                if(reportid != null && reportid != ""){
                  Navigator.pop(context, reportid);
                }
              },
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 1,),
              buildContent(),
              SizedBox(height: 10,),
            ],
          ),
          buildReportBtn(),
        ],
      ),
    );
  }


  Widget buildContent(){
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
              controller: _textEditingController,
              focusNode: _contentfocusNode,
              maxLines: 15,//最大行数
              autocorrect: true,//是否自动更正
              autofocus: false,//是否自动对焦
              textAlign: TextAlign.left,//文本对齐方式
              style: TextStyle(fontSize: 14.0, color: Colors.black87),//输入文本的样式
              onChanged: (text) {//内容改变的回调
              },

              decoration: InputDecoration(
                border: InputBorder.none,//去掉输入框的下滑线
                hintStyle: TextStyle(fontSize: 14),
                hintText: "记录你的精彩瞬间...",
                filled: true,
                fillColor: Colors.white,
              )
          ),
        ],
      ),
    );
  }

  Widget buildSound(){
    Widget sound = Container(
      child: Row(
        children: [
          PlayVoice(_voice),
          IconButton(onPressed: (){
            setState(() {
              _voice = "";
            });
          }, icon: Icon(Icons.cancel, color: Colors.black54))
        ],
      ),
    );
    return _voice != null && _voice != "" ? sound:SizedBox.shrink();
  }

  Widget buildImage(){
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildGridView(),
          ],
        )
    );
  }

  Widget buildGridView() {
    return Container(
      margin: EdgeInsets.only(left: 0, right: 10, bottom: 10),
      child: GridView.count(
          shrinkWrap: true, // 自动高
          physics: NeverScrollableScrollPhysics(),// 添加
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 4,
          children: List.generate(_images.length == _imageMax ? _images.length : _images.length+1, (index) {
            if(index == _images.length && index < _imageMax && index != 0){
              return Container(
                child: Center(
                  child: IconButton(
                    alignment: Alignment.center,
                    icon: Icon(IconFont.icon_tianjiajiahaowubiankuang, size: 30, color: Colors.grey,),
                    onPressed: (){
                      loadAssets();
                    },
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.all(new Radius.circular(5.0)),
                ),
              );
            }
            else if(index == _imageMax){
              return Container();
            }
            else if(index < _images.length){
              AssetEntity asset = _images[index];
              return Stack(
                children: <Widget>[
                  ClipRRect(
                    child: ExtendedImage(
                      image: AssetEntityImageProvider(
                        asset,
                      ),
                      width: 300,
                      height: 300,
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  Positioned(
                    right: 0.08,
                    top: 0.08,
                    child: new GestureDetector(
                      onTap: (){
                        _images.removeAt(index);
                        _imagesUrl.removeAt(index);
                        _imagesWH.removeAt(index);
                        setState(() {

                        });
                      },
                      child: new Container(
                        decoration: new BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: new Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            else{
              return SizedBox.shrink();
            }
          }
          )),
    );
  }

  Widget buildReportBtn(){
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _voice != "" ? buildSound() : buildImage(),
          _categorys.length > 0 ? SizedBox(height: 30, child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(0.0),
              itemCount: _categorys.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int position) {
                return InkWell(
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                    child: Row(
                      children: [
                        Text('#' + _categorys[position], style: TextStyle(color: Colors.black, fontSize: 14),),
                        SizedBox(width: 3,),
                        Icon(Icons.clear, color: Colors.black45, size: 14,)
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(new Radius.circular(8.0)),
                      border: new Border.all(width: 1, color: Colors.black45, ),
                    ),
                  ),
                  onTap: (){
                    setState(() {
                      _categorys.remove(_categorys[position]);
                    });
                  },
                );
              }
          ),)  : SizedBox(),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: 10,),

                  InkWell(
                    child: Icon(IconFont.icon_luyin2, size: 26, color: _images.length == 0 ? Colors.black : Colors.grey,),
                    onTap: (){
                      if(_images.length > 0){
                        return;
                      }

                      showPlayRecorderView();
                    },
                  ),
                  SizedBox(width: 20,),
                  InkWell(
                    child: Icon(IconFont.icon_photo, size: 26, color: _voice == "" ? Colors.black : Colors.grey,),
                    onTap: (){
                      if(_voice != ""){
                        return;
                      }
                      loadAssets();
                    },
                  ),
                ],
              ),
              InkWell(
                child: Container(
                  child: Text('# 加话题', style: TextStyle(fontSize: 16),),
                ),
                onTap: (){
                  showCategoryList();
                },
              )
            ],

          )
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(new Radius.circular(5.0)),
      ),
    );
  }

  Future<void> loadAssets() async {
    List<AssetEntity>? resultList;
    _contentfocusNode.unfocus();

    try {
      resultList = await AssetPicker.pickAssets(
        context,
        maxAssets: _imageMax,
        selectedAssets: _images,
        requestType: RequestType.image,
      );
    } on Exception catch (e) {
      print(e.toString());
    }
    //添加图片并上传oss 1.申请oss临时token，1000s后过期
    if (resultList != null && resultList.length != 0) {
      _securityToken = await _aliyunService.getMomentSecurityToken(Global.profile.user!.token!,  Global.profile.user!.uid);
      if(_securityToken != null) {
        for (int i = 0; i < resultList.length; i++) {
          int width = resultList[i].orientatedWidth;
          int height = resultList[i].orientatedHeight;
          String url = await CommonUtil.upLoadImage((await resultList[i].file)!, _securityToken!, _aliyunService);
          if(!_imagesUrl.contains(url)) {
            _imagesUrl.add(url);
            _imagesWH.add("${width},${height}");
          }
        }
        if (!mounted) return;
        setState(() {
          if(resultList!.length != 0)
            _images = resultList;
        });
      }
    }
  }

  Future<void> showPlayRecorderView() async {
    showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) => StatefulBuilder( // 嵌套一个StatefulBuilder 部件
                builder: (context, setState) => PlayRecorder()
            )).then((value)  {
      if(value != null && value != ""){
        _voice = value;
        setState(() {

        });
      }
    });
  }

  Future<void> showCategoryList() async {
    showModalBottomSheet<String>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context){
          return AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: double.infinity,
              height: 310,
              child: StatefulBuilder( // 嵌套一个StatefulBuilder 部件
                  builder: (context, setState) => CategoryInfo(_categorys)),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(9.0), topRight: Radius.circular(9.0))
              ),
            ),
          );
        }).then((value)  {
      if(value != null && value != ""){
        setState(() {
          _categorys = value.toString().split(',');
        });
      }
    });
  }

  //滑动拼图
  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true, required String temimages, required String temcategory}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v) async {
            String reportid = await _imService.reportMoment(
                Global.profile.user!.uid,
                Global.profile.user!.token!,
                _textEditingController.text,_voice, temimages, temimages.length > 0 ?_imagesWH[0] : "", temcategory, v, (code, error){
                  if(code == "-1008"){
                    //需要进行人机验证
                    loadingBlockPuzzle(context, temimages: temimages, temcategory: temcategory);
                  }
                  else {
                    ShowMessage.showToast(error);
                  }
                });
            if(reportid != null && reportid != ""){
              Navigator.pop(context, reportid);
            }
          },
          onFail: (){

          },
        );
      },
    );
  }

}
