import 'package:extended_image/extended_image.dart';
import 'package:ff_stars/ff_stars.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../global.dart';
import '../../../model/order.dart';
import '../../../model/aliyun/securitytoken.dart';
import '../../../service/aliyun.dart';
import '../../../service/activity.dart';
import '../../../common/iconfont.dart';
import '../../../util/common_util.dart';
import '../../../util/showmessage_util.dart';

class Evaluate extends StatefulWidget {
  Object? arguments;
  late Order order;

  Evaluate({this.arguments}){
    order = (arguments as Map)["order"];
  }

  @override
  _EvaluateState createState() => _EvaluateState();
}

class _EvaluateState extends State<Evaluate> {
  TextEditingController _textEditingController = new TextEditingController();
  ActivityService _activityService = new ActivityService();
  AliyunService _aliyunService = new AliyunService();
  List<AssetEntity> _images = [];
  int _imageMax = 3;//最多上传3张图
  SecurityToken? _securityToken;
  List<String> _imagesUrl = [];
  List<String> _imagesWH = [];//图片的分辨率
  int _liketype = 5;//1非常差 2差 3一般 4好 5非常好
  String _msg = "非常好";
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
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, size: 18,),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text('商品评价',textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          buildEvaluateType(),
          buildEvaluateText(),
          buildGridView(),
          SizedBox(height: 10,),
        ],
      ),
      bottomNavigationBar: buildSubBtn(),
    );
  }

  Widget buildEvaluateText(){
    return TextField(
        controller: _textEditingController,
        focusNode: _contentfocusNode,
        maxLength: 500,//最大长度，设置此项会让TextField右下角有一个输入数量的统计字符串
        maxLines: 9,//最大行数
        autocorrect: true,//是否自动更正
        autofocus: false,//是否自动对焦
        textAlign: TextAlign.left,//文本对齐方式
        style: TextStyle(fontSize: 14.0, color: Colors.black87),//输入文本的样式
        onChanged: (text) {//内容改变的回调
        },

        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,//去掉输入框的下滑线
          hintText: "您的评价会帮助我们选择更好的商品哦~",
          filled: true,
          fillColor: Colors.white,
        )
    );
  }

  Widget buildGridView() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: GridView.count(
            shrinkWrap: true, // 自动高
            physics: NeverScrollableScrollPhysics(),// 添加
            childAspectRatio: 1.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            children: List.generate(_images.length == _imageMax ? _images.length : _images.length+1, (index) {
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

              return SizedBox.shrink();
            })),
      ),
    );
  }

  Widget buildEvaluateType(){
    return Container(
      padding: EdgeInsets.only(left: 10, top: 20, bottom: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('商品评价', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold ),),
          SizedBox(width: 20,),
          FFStars(
            normalStar: Image.asset("images/orangeNormal.png"),
            selectedStar: Image.asset("images/orangeSelected.png"),
            starsChanged: (realStars, selectedStars) {
              if(realStars == 5){
                _msg = "非常好";
              }
              if(realStars == 4){
                _msg = "好";
              }
              if(realStars == 3){
                _msg = "一般";
              }
              if(realStars == 2){
                _msg = "差";
              }
              if(realStars == 1){
                _msg = "非常差";
              }
              _liketype = realStars.toInt();
              setState(() {

              });
            },
            step: 1.0,
            defaultStars: 5,
          ),
          SizedBox(width: 20,),
          Text(_msg, style: TextStyle(color: Colors.black45, fontSize: 14),)
        ],
      ),
    );
  }

  Widget buildSubBtn(){
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: RaisedButton(
          color: Global.profile.backColor,
          elevation: 0,
          child: Text('提交评价', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
          onPressed: () async {
            String temimageurl = "";
            if(_imagesUrl.length > 0){
              for(int i=0; i < _imagesUrl.length; i ++){
                temimageurl += _imagesUrl[i] + ",";
              }
              temimageurl = temimageurl.substring(0, temimageurl.length-1);
            }
            bool ret = await _activityService.evaluateActivity(Global.profile.user!.uid,
                Global.profile.user!.token!, _textEditingController.text, widget.order.orderid!, temimageurl,
                _liketype, (String statusCode, String msg){
                  ShowMessage.showToast(msg);
                });
            if(ret){
              Navigator.pop(context, 1);
            }
          },
        ),
      ),
    );
  }
  //加载图片并处理
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
            int width = resultList[i].orientatedWidth;
            int height = resultList[i].orientatedWidth;
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

}
