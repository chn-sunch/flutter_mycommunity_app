import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../model/aliyun/securitytoken.dart';
import '../../../common/iconfont.dart';
import '../../../util/common_util.dart';
import '../../../util/showmessage_util.dart';
import '../../../widget/captcha/block_puzzle_captcha.dart';
import '../../../widget/my_divider.dart';
import '../../../service/imservice.dart';
import '../../../service/aliyun.dart';
import '../../../global.dart';

class SuggestReport extends StatefulWidget {
  String timeline_id  = "";
  int reporttype = 0;//0拼玩活动 1 社团 2私聊天  3团购

  Object? arguments;

  SuggestReport({this.arguments}){
    if(arguments != null){
      timeline_id = (arguments as Map)["timeline_id"];
      reporttype = (arguments as Map)["reporttype"];
    }
  }

  @override
  _SuggestReportState createState() => _SuggestReportState();
}

class _SuggestReportState extends State<SuggestReport> {
  TextEditingController _textEditingController = new TextEditingController();
  List<AssetEntity> _images = [];
  int _imageMax = 8;//最多上传9张图
  AliyunService _aliyunService = new AliyunService();
  ImService imService = new ImService();
  List<String> _imagesUrl = [];
  SecurityToken? _securityToken;
  FocusNode _contentfocusNode = FocusNode();

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('建议内容', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1,),
          buildContent(),
          SizedBox(height: 10,),
          buildImage()
        ],
      ),
      bottomNavigationBar: buildReportBtn(),
    );
  }

  Widget buildContent(){
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Text('描述建议内容', style: TextStyle(color: Colors.black87, fontSize: 14, ),),
          ),
          MyDivider(),
          TextField(
              controller: _textEditingController,
              maxLines: 9,//最大行数
              autocorrect: true,//是否自动更正
              autofocus: true,//是否自动对焦
              textAlign: TextAlign.left,//文本对齐方式
              style: TextStyle(fontSize: 14.0, color: Colors.black87),//输入文本的样式
              onChanged: (text) {//内容改变的回调
              },

              decoration: InputDecoration(
                border: InputBorder.none,//去掉输入框的下滑线
                hintStyle: TextStyle(fontSize: 14),
                hintText: "请输入",
                filled: true,
                fillColor: Colors.white,
              )
          ),
        ],
      ),
    );
  }

  Widget buildImage(){
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Text('建议内容截图', style: TextStyle(color: Colors.black87, fontSize: 14, ),),
            ),
            buildGridView(),
          ],
        )
    );
  }

  Widget buildGridView() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: GridView.count(
          shrinkWrap: true, // 自动高
          physics: NeverScrollableScrollPhysics(),// 添加
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          children: List.generate(_images.length+1, (index) {
            if(index == _images.length && index < _imageMax){
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
      color: Colors.white,
      padding: EdgeInsets.all(10),
      height: 60,
      child: FlatButton(
        color: Colors.green,
        child: Text(
          '提交',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          if(Global.profile.user != null) {
            if(_textEditingController.text == ""){
              ShowMessage.showToast("请填写建议描述");
              return;
            }
            String temimages = "";
            _imagesUrl.forEach((element) {
              temimages += element + ",";
            });
            if(_images.length > 0){
              temimages = temimages.substring(0, temimages.length-1);
            }

            String reportid = await imService.reportSuggest(
                Global.profile.user!.uid,
                Global.profile.user!.token!,
                _textEditingController.text,
                temimages,"",
                    (code, error){
                      if(code == "-1008"){
                        //需要进行人机验证
                        loadingBlockPuzzle(context, temimages: temimages);
                      }
                      else {
                        ShowMessage.showToast(error);
                      }
                });
            if(reportid != null && reportid != ""){
              Navigator.pushReplacementNamed(context, '/SuggestInfo', arguments: {"suggestid": reportid});
            }
          }
          else{
            Navigator.pushNamed(context, '/Login');
          }
        },
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

    if(resultList != null && resultList.length != 0) {
      //添加图片并上传oss 1.申请oss临时token，1000s后过期
      _securityToken = await _aliyunService.getActivitySecurityToken(
          Global.profile.user!.token!, Global.profile.user!.uid);
      if (_securityToken != null) {
        for (int i = 0; i < resultList.length; i++) {
          String url = await CommonUtil.upLoadImage((await resultList[i].file)!, _securityToken!, _aliyunService);
          if(!_imagesUrl.contains(url)) {
            _imagesUrl.add(url);
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

  //滑动拼图
  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true, String temimages = ""}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v) async {
            String reportid = await imService.reportSuggest(
                Global.profile.user!.uid,
                Global.profile.user!.token!,
                _textEditingController.text,
                temimages,v, (code, error){
                  if(code == "-1008"){
                    //需要进行人机验证
                    loadingBlockPuzzle(context, temimages: temimages);
                  }
                  else {
                    ShowMessage.showToast(error);
                  }
                });
            if(reportid != null && reportid != ""){
              Navigator.pushReplacementNamed(context, '/SuggestInfo', arguments: {"suggestid": reportid});
            }
          },
          onFail: (){

          },
        );
      },
    );
  }
}
