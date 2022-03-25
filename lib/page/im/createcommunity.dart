
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../widget/circle_headimage.dart';
import '../../model/aliyun/securitytoken.dart';
import '../../model/user.dart';
import '../../model/im/community.dart';
import '../../service/aliyun.dart';
import '../../service/userservice.dart';
import '../../service/imservice.dart';
import '../../util/showmessage_util.dart';
import '../../util/imhelper_util.dart';
import '../../global.dart';


class CreateCommunity extends StatefulWidget {

  @override
  _CreateCommunityState createState() => _CreateCommunityState();
}

class _CreateCommunityState extends State<CreateCommunity> {
  AliyunService _aliyunService = new AliyunService();
  ImService _imService = new ImService();
  List<int> selectItem = [];
  List<String> selectItemName = [];
  UserService _userService = new UserService();

  double fontsize = 15;
  double contentfontsize = 14;
  String clubicon = "";
  String notice = "";
  String city = "";
  String province = "";
  String communityname = "";
  String joinruleValue = "1";
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  bool _isButtonEnable = true;
  ImHelper imHelper = new ImHelper();
  final _picker = ImagePicker();
  double pageheight = 0.0;
  List<User> users = [];
  bool _ismore = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _getFansList() async {
    users = await _userService.getFans(Global.profile.user!.uid, 0);
    _refreshController.refreshCompleted();
    if(mounted)
      setState(() {

      });
  }

  void _onLoading() async{
    if(!_ismore) return;
    final moredata = await _userService.getFans(Global.profile.user!.uid, users.length);

    if(moredata.length > 0)
      users = users + moredata;

    if(moredata.length >= 25)
      _refreshController.loadComplete();
    else{
      _ismore = false;
      _refreshController.loadNoData();
    }

    if(mounted)
      setState(() {

      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),

          title: Text('发起群聊',  style: TextStyle(color:  Colors.black87, fontSize: 16)),
          centerTitle: true,
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: users.length >= 25,
          onRefresh: _getFansList,
          header: MaterialClassicHeader(distance: 100, ),
          footer: CustomFooter(
            builder: (BuildContext context,LoadStatus? mode){
              Widget body ;
              if(mode==LoadStatus.idle){
                body =  Text("加载更多", style: TextStyle(color: Colors.black45, fontSize: 13));
              }
              else if(mode==LoadStatus.loading){
                body =  Center(
                  child: CircularProgressIndicator(
                    valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
                  ),
                );
              }
              else if(mode == LoadStatus.failed){
                body = Text("加载失败!点击重试!", style: TextStyle(color: Colors.black45, fontSize: 13));
              }
              else if(mode == LoadStatus.canLoading){
                body = Text("放开我,加载更多!", style: TextStyle(color: Colors.black45, fontSize: 13));
              }
              else{
                body = Text("—————— 我也是有底线的 ——————", style: TextStyle(color: Colors.black45, fontSize: 13));
              }
              print(mode);
              return Container(
                height: 55.0,
                child: Center(child:body),
              );
            },
          ),
          controller: _refreshController,
          onLoading: _onLoading,
          child: _refreshController.headerStatus == RefreshStatus.completed && users.length == 0 ? Center(
            child: Text('要先有粉丝才能创建群聊哦~', style: TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2,),
          ) :buildMyFans(),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(10),
          color: Colors.grey.shade100,
          alignment: Alignment.centerRight,
          height: 59,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 100,
                child: TextButton(
                  child: Text(selectItem.length > 0 ? '完成(${selectItem.length})' : '完成', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
                  style: selectItem.length > 0 ? ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Global.defredcolor),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                9))),
                  ) : ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Global.defredcolor.withAlpha(119)),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
                  ),
                  onPressed: () async{
                    try{
                      if(_isButtonEnable) {
                        if(selectItem.length <= 0){
                          ShowMessage.showToast("请选择群成员");
                          return;
                        }

                        _isButtonEnable = false;
                        Community? communiy = await _imService.createCommunity(
                            Global.profile.user!.token!,
                            Global.profile.user!.uid,
                            "群聊",
                            province,
                            city,
                            clubicon,
                            '',
                            joinruleValue,
                            selectItem,
                            selectItemName,
                            errorCallBack
                        );
                        _isButtonEnable = true;
                        if (communiy != null) {
                          Navigator.pop(context, communiy);
                        }
                      }
                    }
                    catch(e)
                    {
                      _isButtonEnable = true;
                      ShowMessage.showToast("网络不给力，请再试一下!");}
                    setState(() {
                    });
                  },
                ),
              )
            ],
          ),
        )
    );
  }

  Widget buildMyFans(){
    List<Widget> contents = [];
    if(users != null){
      for(User user in users){
        contents.add(
          ListTile(
            title: Row(
              children: [
                RoundCheckBox(
                  value: selectItem.indexOf(user.uid) >= 0,
                ),
                SizedBox(width: 10,),
                NoCacheClipRRectOhterHeadImage(imageUrl: user.profilepicture!, width: 30, uid: user.uid, cir: 50,),
                SizedBox(width: 10,),
                Text(user.username, style: TextStyle(color: Colors.black87, fontSize: 14),),
              ],
            ),
            onTap: (){
              if(!(selectItem.indexOf(user.uid) >= 0)){
                selectItem.add(user.uid);
                selectItemName.add(user.username);
              }
              else{
                selectItem.remove(user.uid);
                selectItemName.remove(user.username);
              }
              setState(() {

              });
            },
          ),
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 20),
      color: Colors.white,
      child: Column(
        children: [

          Expanded(child: ListView(
            children: contents,
          ),)
        ],
      )
    );
  }

  void showDemoActionSheet({required BuildContext context,required Widget child}) {
    File? imageFile;
    File? croppedFile;
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((value) async {
      if (value != null) {
        if(value == "Camera"){
          PickedFile? image = await _picker.getImage(source: ImageSource.camera);
          imageFile = File(image!.path);
        }else if(value == "Gallery"){
          PickedFile? image = await _picker.getImage(source: ImageSource.gallery);
          imageFile = File(image!.path);
        }
        else{
          return;
        }
      }
      if(imageFile != null){
        croppedFile = await ImageCropper().cropImage(
            maxWidth: 750,
            maxHeight: 750,
            compressQuality: 30,
            sourcePath: imageFile!.path,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: '裁剪',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: true),
            iosUiSettings: IOSUiSettings(
                title: '裁剪',
                minimumAspectRatio: 1.0,
                aspectRatioLockEnabled: true
            )
        );
        if (croppedFile !=null) {
          String ossimagpath = "";
          //转成png格式
          final Directory _directory = await getTemporaryDirectory();
          final Directory _imageDirectory =
              await new Directory('${_directory.path}/profilepicture/images/')
              .create(recursive: true);
          String _path = _imageDirectory.path;
          Uint8List imageData = await croppedFile!.readAsBytes();
          String md5name = md5.convert(imageData).toString();

          File imageFile = new File('${_path}originalImage_$md5name.png')
            ..writeAsBytesSync(imageData);

          //上传图片到oss
          SecurityToken? securityToken = await _aliyunService.getActivitySecurityToken(Global.profile.user!.token!,  Global.profile.user!.uid);
          if(securityToken != null) {
            ossimagpath = await _aliyunService.uploadImage(
                securityToken, imageFile.path, '${md5name}.png', Global.profile.user!.uid);
          }
          if(ossimagpath.isNotEmpty){
            bool ret = await _imService.updateCommunityPicture(Global.profile.user!.token!, Global.profile.user!.uid,
                Global.profile.user!.uid.toString(), ossimagpath, errorCallBack);
            if(ret) {
              clubicon = ossimagpath;
              if (mounted) {
                setState(() {

                });
              }
            }
          }
        }
      }
    });
  }



  void errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}

class RoundCheckBox extends StatefulWidget {
  RoundCheckBox({Key? key, required this.value})
      : super(key: key);

  final bool value;
  @override
  State<StatefulWidget> createState() {
    return RoundCheckBoxWidgetBuilder();
  }
}

class RoundCheckBoxWidgetBuilder extends State<RoundCheckBox> {
  Widget build(BuildContext context) {
    return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: widget.value ? Global.profile.backColor! : Color(0xff999999)),
            color: widget.value ? Global.profile.backColor : Color(0xffffffff),
            borderRadius: BorderRadius.circular(24)),
        child: Center(
          child: Icon(
            Icons.check,
            color: Color(0xffffffff),
            size: 20,
          ),
        ));
  }
}
