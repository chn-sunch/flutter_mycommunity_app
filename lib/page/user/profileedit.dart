import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../model/user.dart';
import '../../model/aliyun/securitytoken.dart';
import '../../util/common_util.dart';
import '../../util/showmessage_util.dart';
import '../../common/iconfont.dart';
import '../../service/aliyun.dart';
import '../../service/userservice.dart';
import '../../bloc/user/authentication_bloc.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/my_divider.dart';
import '../../widget/interest.dart';
import '../../widget/photo/playrecorder.dart';
import '../../global.dart';


class MyProfileEdit extends StatefulWidget {
  @override
  _MyProfileEditState createState() => _MyProfileEditState();
}

class _MyProfileEditState extends State<MyProfileEdit> {
  AliyunService _aliyunService = new AliyunService();
  late User user;
  late AuthenticationBloc _bloc;
  double fontsize = 15;
  double contentfontsize = 14;
  final _picker = ImagePicker();
  List<String> interest = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = Global.profile.user!;
    _bloc = BlocProvider.of<AuthenticationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          ShowMessage.showToast(state.error!);
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          buildWhen: (previousState, state) {
            if(state is AuthenticationAuthenticated) {
              return true;
            }
            else
              return false;
          },
          builder: (context, state) {
            interest = [];
            user = Global.profile.user!;
            if(user.interest != null && user.interest != ""){
              user.interest!.split(',').forEach((element) {
                interest.add(element);
              });
            }
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                title: Text('资料编辑', style: TextStyle(color: Colors.black, fontSize: 16)),
                centerTitle: true,
              ),
              body: Container(
                margin: EdgeInsets.only(top: 10, bottom: 20),
                color: Colors.white,
                child: ListView(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          showDemoActionSheet(
                            context: context,
                            child: CupertinoActionSheet(
                              //message: const Text('Please select the best mode from the options below.'),
                              actions: <Widget>[
                                CupertinoActionSheetAction(
                                  child: const Text('拍照', style: TextStyle(color: Colors.grey),),
                                  onPressed: () {
                                    Navigator.pop(context, 'Camera');
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child: const Text('相册', style: TextStyle(color: Colors.grey)),
                                  onPressed: () {
                                    Navigator.pop(context, 'Gallery');
                                  },
                                ),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                child: const Text('取消', style: TextStyle(color: Colors.grey)),
                                isDefaultAction: true,
                                onPressed: () {
                                  Navigator.pop(context, 'Cancel');
                                },
                              ),
                            ),
                          );
                        },
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("头像", style: TextStyle(fontSize: fontsize)),
                              NoCacheClipRRectOhterHeadImage(imageUrl: user.profilepicture!, cir: 8, uid: user.uid,),
                            ],
                          ),
                        ),

                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),//头像
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          //类型等于1是修改昵称
                          Navigator.pushNamed(context, '/NameAndSignature', arguments: {"type": "1","content": user.username}).then((onValue){
                            if(onValue!=null && onValue != ""){
                              user.username = onValue.toString();
                              setState(() {

                              });
                            }
                          });
                        },
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("昵称", style: TextStyle(fontSize: fontsize),),
                              Text(user.username, style: TextStyle(color: Colors.black45, fontSize: contentfontsize),)
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),//昵称
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          Navigator.pushNamed(context, '/ListViewProvince', arguments:{"isPermanent":true}).then((dynamic value) async {
                            if(value != null){
                              String citycode = value["code"].toString();
                              String provinceCode = value["provinceCode"].toString();
                              _bloc.add(UpdateUserLocationPressed(user: user, province: provinceCode, city: citycode));
                              setState(() {

                              });
                            }
                          });
                        },
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("常住", style: TextStyle(fontSize: fontsize)),
                              Text(user.city!=null && user.city!.isNotEmpty?CommonUtil.getCityName(user.province, user.city):'选择位置',
                                style: TextStyle(color: Colors.black45, fontSize: contentfontsize),)
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),//位置
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return GenderChooseDialog();
                              }
                          ).then((onValue) async {
                            if(Global.profile.user!.sex != onValue && onValue != null){
                              _bloc.add(UpdateUserSexPressed(user: Global.profile.user!, sex: onValue));
                            }
                          });
                        },
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("性别", style: TextStyle(fontSize: fontsize)),
                              Text(user.sex == '1'?'男':(user.sex == '0' ? '女' : '保密'), style: TextStyle(color: Colors.black45, fontSize: contentfontsize),)
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),//设置性别
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          showDefaultYearPicker(context);
                        },
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("生日", style: TextStyle(fontSize: fontsize)),
                              Text(user.birthday !=null ? user.birthday! :"",
                                style: TextStyle(color: Colors.black45, fontSize: contentfontsize),)
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),//设置生日
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          //类型等于1是修改昵称,0修改个人简介
                          Navigator.pushNamed(context, '/NameAndSignature', arguments: {"type": "0","content": user.signature}).then((onValue){
                            if(onValue!=null && onValue != ""){
                              user.signature = onValue.toString();
                              setState(() {

                              });
                            }
                          });
                        },
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("简介", style: TextStyle(fontSize: fontsize), ),
                              Padding(padding: EdgeInsets.only(left: 30),),
                              Expanded(child: Text(user.signature!=null?user.signature:"",
                                  style: TextStyle(color: Colors.black45, fontSize: contentfontsize), textDirection: TextDirection.rtl,
                                  overflow: TextOverflow.ellipsis),)
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),//设置个人简介//设置个人简介
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          showInterestSel();
                        },
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("喜欢", style: TextStyle(fontSize: fontsize)),
                              Expanded(child: Text(user.interest!=null && user.interest!="" ? "  " +
                                  CommonUtil.getInterest(user.interest!):"  ",
                                style: TextStyle(color: Colors.black45, fontSize: contentfontsize),
                                overflow: TextOverflow.ellipsis, textDirection: TextDirection.rtl,))
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),//喜欢什么
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          showPlayRecorderView();
                        },
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("语音", style: TextStyle(fontSize: fontsize)),
                              Text(user.voice!=null && user.voice != "" ? "已录音":"未录音", style: TextStyle(color: Colors.black45, fontSize: contentfontsize),)
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),//录音

                  ],
                ),
              ),
            );
          }
    ),);
  }

  void showDefaultYearPicker(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    if(user.birthday!= null && user.birthday!.isNotEmpty){
      selectedDate = DateTime.parse(user.birthday!);
    }
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate, // 初始日期
      firstDate: DateTime(1900), //
      lastDate: DateTime(2100),
      locale: Locale('zh'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      }
    ).then((DateTime? val){
      if(Global.profile.user!.birthday!=val.toString().substring(0, 10)){
        _bloc.add(UpdateUserBirthdayPressed(user: user, birthday: val.toString().substring(0, 10)));
      }
    }).catchError((err) {
      //print(err);
    });

    if (date == null) {
      return;
    }

    setState(() {
      selectedDate = date;
    });
  }

  void showDemoActionSheet({required BuildContext context, required Widget child}) {
    File? imageFile;
    File? croppedFile;
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((value) async {
      if (value != null) {
        if(value == "Camera"){
          XFile? image = await _picker.pickImage(source: ImageSource.camera);
          imageFile = File(image!.path);
        }else if(value == "Gallery"){
          XFile? image;
          if(Platform.isIOS ) {
            image = await _picker.pickImage(source: ImageSource.gallery);
            if(image != null) {
              imageFile = File(image.path);
            }
          }

          if(Platform.isAndroid){
            List<AssetEntity>? resultList = await AssetPicker.pickAssets(
              context,
              maxAssets: 1,
              requestType: RequestType.image,
            );

            if(resultList != null && resultList.length > 0){
              imageFile = await (await resultList[0].file)!;
            }
          }
        }
        else{
          return;
        }
      }
      if(imageFile != null){
        croppedFile = await ImageCropper.cropImage(
            maxWidth: 750,
            maxHeight: 750,
            compressQuality: 19,
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
          String serverossimg = "";
          //转成png格式
          final Directory _directory = await getTemporaryDirectory();
          final Directory _imageDirectory =
              await new Directory('${_directory.path}/profilepicture/images/')
              .create(recursive: true);
          String _path = _imageDirectory.path;
          Uint8List imageData = await croppedFile!.readAsBytes();
          String md5name = user.uid.toString();
          File imageFile = new File('${_path}originalImage_$md5name.png')
            ..writeAsBytesSync(imageData);

          //上传图片到oss
          SecurityToken? securityToken = await _aliyunService.getUserProfileSecurityToken(user.token!,  user.uid);
          if(securityToken != null) {
            serverossimg = await _aliyunService.uploadImage(
                securityToken, imageFile.path, '${md5name}.png', user.uid);
            ossimagpath = securityToken.host + '/' + serverossimg;
          }
          if(ossimagpath.isNotEmpty){
            _bloc.add(UpdateImagePressed(user: user, imgpath: ossimagpath, serverimgpath: serverossimg));
          }
        }
      }
    });
  }

  Future<void> showInterestSel() async {
    interest = [];
    user = Global.profile.user!;
    if(user.interest != null && user.interest != ""){
      user.interest!.split(',').forEach((element) {
        interest.add(element);
      });
    }
    showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) =>
            StatefulBuilder( // 嵌套一个StatefulBuilder 部件
                builder: (context, setState) => InterestSel(this.interest)
            )).then((value)  {
              if(value != null ){
                setState(() {
                  user.interest = value;
                });
              }
    });
  }

  Future<void> showPlayRecorderView() async {
    showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) =>
            StatefulBuilder( // 嵌套一个StatefulBuilder 部件
                builder: (context, setState) => PlayRecorder()
            )).then((value)  async {
      if(value != null && value != ""){
        UserService userService = new UserService();
        bool ret = await userService.updateVoice(Global.profile.user!.token!, Global.profile.user!.uid
            , value, (String statusCode, String msg){
              ShowMessage.showToast(msg);
            });
        if(ret) {
          Global.profile.user!.voice = value;
          Global.saveProfile();
        }
        setState(() {

        });
      }
    });
  }
}


//性别选择
class GenderChooseDialog extends Dialog {
  GenderChooseDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.all(12.0),
        child: new Material(
            type: MaterialType.transparency,
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                      decoration: ShapeDecoration(
                          color: Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ))),
                      margin: const EdgeInsets.all(12.0),
                      child: new Column(children: <Widget>[
                        new Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 10.0),
                            child: Center(
                                child: new Text('性别选择',
                                    style: new TextStyle(
                                      fontSize: 20.0, color: Colors.black
                                    )))),
                        MyDivider(),
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _genderChooseItemMan(context),
                              _genderChooseItemGirl(context),
                            ]),
                        MyDivider(),
                        new Padding(
                            padding: const EdgeInsets.fromLTRB(
                                5.0, 5.0, 5.0, 10.0),
                            child: Center(
                                child: new Text('',
                                    style: new TextStyle(
                                        fontSize: 20.0, color: Colors.black
                                    )))),

                      ]))
                ])));
  }

  Widget _genderChooseItemMan(BuildContext context) {
    return GestureDetector(
        onTap: (){
          Navigator.of(context).pop('1');
        },
        child: Column(children: <Widget>[
          Container(
            width: 70,
            height: 70,
            child: Center(
              child: Icon(IconFont.icon_nan,size: 50, color:  Colors.blue,) )
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
              child: Text('男',style: TextStyle(
                  color:  Colors.blue,
                  fontSize: 20.0))),
        ]));
  }

  Widget _genderChooseItemGirl(BuildContext context) {
    return GestureDetector(
        onTap: (){
          Navigator.of(context).pop('0');
        },
        child: Column(children: <Widget>[
          Container(
            width: 70,
            height: 70,
            child: Center(
              child: Icon(IconFont.icon_nv, size: 50,
                color:  Colors.pinkAccent,),)
              ,),
          Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
              child: Text('女',style: TextStyle(
                  color:  Colors.pinkAccent,
                  fontSize: 20.0))),
        ]));
  }

  Widget _genderChooseItemWeiZhi(BuildContext context) {
    return GestureDetector(
        onTap: (){
          Navigator.of(context).pop('2');
        },
        child: Column(children: <Widget>[
          Container(
            width: 70,
            height: 70,
            child: Center(
              child: Icon(IconFont.icon_tianqi_weizhi, size: 50,
                color:  Colors.grey,),),),
          Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
              child: Text('保密',style: TextStyle(
                  color:  Colors.grey,
                  fontSize: 20.0))),
        ]));
  }
}

