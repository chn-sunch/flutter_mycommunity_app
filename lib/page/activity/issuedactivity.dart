import 'dart:async';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../model/user.dart';
import '../../model/activity.dart';
import '../../model/aliyun/securitytoken.dart';
import '../../common/iconfont.dart';
import '../../util/common_util.dart';
import '../../util/showmessage_util.dart';
import '../../util/permission_util.dart';
import '../../service/activity.dart';
import '../../service/aliyun.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/captcha/block_puzzle_captcha.dart';
import '../../widget/loadingprogress.dart';
import '../../global.dart';

class IssuedActivity extends StatefulWidget {
  double mincost = 0.00;
  double maxcost = 0.00;

  String provinceCode = "allCode";
  String city = "allCode";
  String address = "";
  String addresstitle = "";
  double lat = 0;
  double lng = 0;
  double cost = 0;
  String content = "";
  String actimagespath = "";
  String goodpriceid = "";
  Object? arguments;

  IssuedActivity({required this.arguments}){
    if(arguments != null){
      mincost = (arguments as Map)["mincost"];
      maxcost = (arguments as Map)["maxcost"];

      provinceCode = (arguments as Map)["provinceCode"];
      city = (arguments as Map)["city"];
      address = (arguments as Map)["address"];
      addresstitle = (arguments as Map)["addresstitle"];
      lat = (arguments as Map)["lat"];
      lng = (arguments as Map)["lng"];
      content = (arguments as Map)["content"];
      goodpriceid = (arguments as Map)["goodpriceid"];
      actimagespath = (arguments as Map)["pic"];

    }
  }

  @override
  _IssuedActivityState createState() => _IssuedActivityState();
}

class _IssuedActivityState extends State<IssuedActivity> {
  TextEditingController _textContentController = new TextEditingController();

  late User _user;
  AliyunService _aliyunService = new AliyunService();

  bool _isButtonEnable = true;
  List<AssetEntity> _images = [];
  int _imageMax = 4;//????????????4??????
  String _provinceCode = "allCode";//??????????????????????????????
  String _city = "allCode";
  int _startyear = 0;
  int _endyear = 0;
  int _coverimgIndex= 0;
  bool _loading = false;
  bool _ispublic = true;//????????????
  String _address = "";//????????????
  String _addresstitle = "";//????????????
  double _lat = 0;//????????????
  double _lng = 0;//????????????
  int oldImageCount = 0;//??????????????????
  ActivityService _activityService = new ActivityService();
  SecurityToken? _securityToken;
  List<String> _imagesUrl = [];
  List<String> _imagesWH = [];//??????????????????
  FocusNode _contentfocusNode = FocusNode();
  List<String> _oldImagesUrl = [];
  int _paytype = 0;
  StreamSubscription<Map<String, Object>>? _locationListener;
  AMapFlutterLocation _locationPlugin = new AMapFlutterLocation();
  late Map<String, Object> _locationResult;

  @override
  void dispose() {
    // TODO: implement dispose
    _textContentController.dispose();
    // _textNameController.dispose();
    _contentfocusNode.dispose();
    if (null != _locationListener) {
      _locationListener!.cancel();
    }

    ///????????????
    if (null != _locationPlugin) {
      _locationPlugin.destroy();
    }
    super.dispose();
  }

  /// ??????????????????
  /// ????????????????????????true??? ????????????false
  Future<bool> requestLocationPermission() async {
    //?????????????????????
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //????????????
      return true;
    } else {
      //??????????????????????????????
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  requestPermission() async {
    // ????????????
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission) {
      print("????????????????????????");
    } else {
      print("???????????????????????????");
    }
  }

  @override
  void initState(){
    _user = Global.profile.user!;
    super.initState();

    if(widget.provinceCode != null) {
      _provinceCode = widget.provinceCode;
    }
    if(widget.city != null) {
      _city = widget.city;
    }
    if(widget.address != null) {
      _address = widget.address;
    }
    if(widget.addresstitle != null) {
      _addresstitle = widget.addresstitle;
    }
    if(widget.lat != null) {
      _lat = widget.lat;
    }
    if(widget.lng != null) {
      _lng = widget.lng;
    }


    if(widget.actimagespath != null && widget.actimagespath.isNotEmpty){
      List<String> oldImages = widget.actimagespath.split(',');
      oldImageCount = oldImages.length;
      oldImages.forEach((element) {
        Uri u = Uri.parse(element);
        String tem = u.path.substring(1, u.path.length);
        _imagesUrl.add(tem);
        _imagesWH.add("300, 300");//????????????????????????
        _oldImagesUrl.add(element);
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    _user = Global.profile.user!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios),iconSize: 20, color: Colors.black, onPressed: (){Navigator.pop(context);},),
        title: Text('', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: new MyLoadingProgress(loading: _loading, isNetError: false, child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          // item ???????????????
          children: <Widget>[
            buildActivityinfo(),
            SizedBox(height: 6,),
            buildGridView(),
            SizedBox(height: 9,),
            buildLocation(),
            // buildAge(),
            buildIsPubilc(),
          ],
        ),
      ), msg: '?????????',),
      bottomNavigationBar: buildIssuedButton(context),
    );
  }
  //????????????
  Container buildLocation(){
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: () async {
          _contentfocusNode.unfocus();
          if(_locationListener != null){
            _startLocation();
          }

          if(_locationListener == null){
            bool locationStatus = await PermissionUtil.requestLocationPermisson();
            if (locationStatus) {
              _locationListener = _locationPlugin.onLocationChanged().listen((Map<String, Object> result) {
                setState(() {
                  _locationResult = result;
                  if (_locationResult != null) {
                    if(result["longitude"] != "" && result["adCode"] != "") {
                      Global.profile.lat = double.parse(result["latitude"].toString());
                      Global.profile.lng = double.parse(result["longitude"].toString());

                      Global.profile.locationCode = CommonUtil.getCityNameByGaoDe(result["adCode"].toString());
                      Global.profile.locationName = result["city"].toString();

                      if (Global.profile.locationGoodPriceCode == null || Global.profile.locationGoodPriceCode == "") {
                        Global.profile.locationGoodPriceCode = CommonUtil.getCityNameByGaoDe(result["adCode"].toString());
                        Global.profile.locationGoodPriceName = result["city"].toString();
                      }

                      Global.saveProfile();

                      Navigator.pushNamed(context, '/MapLocationPicker', arguments: {"lat" : Global.profile.lat,
                        "lng": Global.profile.lng, "citycode": Global.profile.locationCode, "isMapImage": false}).then((dynamic value){
                        if(value != null) {
                          setState(() {
                            _addresstitle = value["title"];
                            _address = value["address"];
                            _city = CommonUtil.getCityNameByGaoDe(value["adCode"]);
                            _provinceCode = value["provinceCode"];
                            _lat = value["latitude"];
                            _lng = value["longitude"];
                          });
                        }
                      });
                    }
                  }
                });
              });

              _startLocation();
            }
          }
        },
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("??????", style: TextStyle(color: Colors.black87, fontSize: 14),),
              SizedBox(width: 15,),
              Expanded(
                child: Text((_addresstitle!=null && _addresstitle.isNotEmpty)?_addresstitle:'????????????????????????',
                  style: TextStyle(color: Colors.black45, fontSize: 14),
                  overflow: TextOverflow.ellipsis, textDirection: TextDirection.rtl,),
              )
            ],
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_right),
      ),
    );
  }

  void _setLocationOption() {
    if (null != _locationPlugin) {
      AMapLocationOption locationOption = new AMapLocationOption();

      ///??????????????????
      locationOption.onceLocation = true;

      ///?????????????????????????????????
      locationOption.needAddress = true;

      ///??????????????????????????????
      locationOption.geoLanguage = GeoLanguage.DEFAULT;

      locationOption.desiredLocationAccuracyAuthorizationMode =
          AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

      locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

      ///??????Android??????????????????????????????
      locationOption.locationInterval = 2000;

      ///??????Android??????????????????<br>
      ///????????????<br>
      ///<li>[AMapLocationMode.Battery_Saving]</li>
      ///<li>[AMapLocationMode.Device_Sensors]</li>
      ///<li>[AMapLocationMode.Hight_Accuracy]</li>
      locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

      ///??????iOS??????????????????????????????<br>
      locationOption.distanceFilter = -1;

      ///??????iOS????????????????????????
      /// ????????????<br>
      /// <li>[DesiredAccuracy.Best] ????????????</li>
      /// <li>[DesiredAccuracy.BestForNavigation] ????????????????????????????????? </li>
      /// <li>[DesiredAccuracy.NearestTenMeters] 10??? </li>
      /// <li>[DesiredAccuracy.Kilometer] 1000???</li>
      /// <li>[DesiredAccuracy.ThreeKilometers] 3000???</li>
      locationOption.desiredAccuracy = DesiredAccuracy.HundredMeters;

      ///??????iOS?????????????????????????????????
      locationOption.pausesLocationUpdatesAutomatically = false;

      ///????????????????????????????????????
      _locationPlugin.setLocationOption(locationOption);
    }
  }

  ///????????????
  void _startLocation() {
    if (null != _locationPlugin) {
      ///????????????????????????????????????
      _setLocationOption();
      _locationPlugin.startLocation();
    }
  }

  ListTile buildAge(){
    return ListTile(
      onTap: (){
        DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime(1960),
            maxTime: DateTime(DateTime.now().year),
            theme: DatePickerTheme(
                headerColor: Global.profile.backColor,
                itemStyle: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
                doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
            onChanged: (date) {

            },
            onConfirm: (date) {
              if(date[0] >  date[1]){
                ShowMessage.showToast("???????????????????????????????????????");
              }
              else{
                setState(() {
                  _startyear = date[0];
                  _endyear = date[1];
                });
              }

            },
            onCancel: (){
              setState(() {
                _startyear = 0;
              });
            },
            currentTime: DateTime.now(), locale: LocaleType.zh);
      },
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("??????", style: TextStyle(color:  Colors.black87, fontSize: 15)),
            Text(_startyear == 0 ? "??????": "${_startyear.toString().substring(2,4)}-${_endyear.toString().substring(2,4)}???", style: TextStyle(color: Colors.black54, fontSize: 15))
          ],
        ),
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
  //????????????
  Widget buildIsPubilc(){
    return  ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("??????", style: TextStyle(color:  Colors.black87, fontSize: 15),),
          Checkbox(
            checkColor: Global.profile.backColor,
            activeColor: Global.profile.backColor,
            fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              const Set<MaterialState> interactiveStates = <MaterialState>{
                MaterialState.pressed,
                MaterialState.hovered,
                MaterialState.focused,
              };

              // ????????????
              return Colors.white;
            }),
            value: this._ispublic,
            onChanged: null,
          )
        ],
      ),
      onTap: (){
        setState(() {
          this._ispublic = !this._ispublic;

        });
      },
    );
  }

  //??????????????????
  TextField buildActivityinfo(){
    return TextField(
        focusNode: _contentfocusNode,
        controller: _textContentController,
        maxLength: 500,//?????????????????????????????????TextField????????????????????????????????????????????????
        maxLines: 15,//????????????
        autocorrect: true,//??????????????????
        autofocus: false,//??????????????????
        textAlign: TextAlign.left,//??????????????????
        style: TextStyle(color: Colors.black87, fontSize: 14, ),//?????????????????????
        onChanged: (text) {//?????????????????????
        },

        decoration: InputDecoration(
          counterText:"",
          hintText: "??????????????????????????????????????????????????????????????????",
          hintStyle: TextStyle(color: Colors.black45, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 10,  bottom: 0, right: 10),
        )
    );
  }
  //imageGridview
  Widget buildGridView() {
    List<Widget> lists = List.generate(_images.length + oldImageCount == _imageMax ? _images.length  + oldImageCount: _images.length + 1 + oldImageCount,
            (index) {
          if(index == (_images.length + oldImageCount) && index < _imageMax){
            return Container(
              child: Center(
                child: IconButton(
                  alignment: Alignment.center,
                  icon: Icon(IconFont.icon_tianjiajiahaowubiankuang, size: 30, color: Colors.grey,),
                  onPressed: (){
                    _contentfocusNode.unfocus();
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
          else if(index < (_images.length + oldImageCount)){
            Widget tem = SizedBox.shrink();
            if(index < oldImageCount){
              tem = ClipRRectOhterHeadImageContainer(imageUrl: _oldImagesUrl[index], width: 300,height: 300,);
            }
            else{
              tem = ClipRRect(
                child: ExtendedImage(
                  image: AssetEntityImageProvider(
                      _images[index-oldImageCount],
                  ),
                  width: 300,
                  height: 300,
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              );
            }
            return Stack(
              children: <Widget>[
                tem,
                Positioned(
                  right: 0.08,
                  top: 0.08,
                  child: new GestureDetector(
                    onTap: (){
                      if(index >= oldImageCount){
                        _images.removeAt(index - oldImageCount);
                      }
                      else if(oldImageCount > 0){
                        oldImageCount = oldImageCount-1;
                        _oldImagesUrl.remove(index);
                      }
                      _imagesUrl.removeAt(index);
                      _imagesWH.removeAt(index);

                      if(index == _coverimgIndex)
                        _coverimgIndex=0;
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
    );
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: GridView.count(
          shrinkWrap: true, // ?????????
          physics: NeverScrollableScrollPhysics(),// ??????
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 4,
          children: lists),
    );
  }
  //????????????
  Container buildIssuedButton(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        height: 40,
        child: FlatButton(
            color: Global.profile.backColor,
            child: Text(
              '????????????',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(9))
            ),

            onPressed: () async{
              try{
                if(_isButtonEnable) {

                  if (_textContentController.text == "") {
                    ShowMessage.showToast("?????????????????????????????????");
                    return;
                  }

                  setState(() {
                    _loading = true;
                  });
                  _isButtonEnable = false;
                  Activity? activity = await _activityService.createActivity(
                    _user.token!, _provinceCode,
                    _city,
                    _user.uid,
                    _textContentController.text,
                    _imagesUrl,
                    _imagesUrl.length == 0 ? "":_imagesUrl[_coverimgIndex],
                    _imagesUrl.length == 0 ? "":_imagesWH[_coverimgIndex],
                    _startyear,
                    _endyear,
                    _ispublic,
                    _address,
                    _addresstitle,
                    _lat,
                    _lng,
                    widget.goodpriceid,
                    "", _paytype, (String statusCode, String msg){
                      if(statusCode == "-1008"){
                        loadingBlockPuzzle(context);
                      }
                      else if(int.parse(statusCode) < 0){
                        ShowMessage.showToast(msg);
                      }
                    }
                  );
                  if (activity != null) {
                    Navigator.popAndPushNamed(context, '/ActivityInfo',arguments: {"actid": activity.actid});
                  }
                  _loading = false;
                  _isButtonEnable = true;
                }
              }
              catch(e)
              {
                _isButtonEnable = true;
                ShowMessage.showToast("?????????????????????????????????!");}
                setState(() {
                  _loading = false;
                });
            }),
      );
  }
  //?????????????????????
  Future<void> loadAssets() async {
    List<AssetEntity>? resultList;

    try {
      resultList = await AssetPicker.pickAssets(
        context,
        maxAssets: _imageMax - oldImageCount,
        selectedAssets: _images,
        requestType: RequestType.image,
      );

    } on Exception catch (e) {
      print(e.toString());
    }
    if (resultList != null && resultList.length != 0) {
      //?????????????????????oss 1.??????oss??????token???1000s?????????
      _securityToken = await _aliyunService.getActivitySecurityToken(_user.token!, _user.uid);
      if (_securityToken != null) {
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

  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true, int? commentid, int? touid, User? touser}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v) async {
            Activity? activity = await _activityService.createActivity(
                _user.token!, _provinceCode,
                _city,
                _user.uid,
                _textContentController.text,
                _imagesUrl,
                _imagesUrl.length == 0 ? "":_imagesUrl[_coverimgIndex],
                _imagesUrl.length == 0 ? "":_imagesWH[_coverimgIndex],
                _startyear,
                _endyear,
                _ispublic,
                _address,
                _addresstitle,
                _lat,
                _lng,
                widget.goodpriceid,
                v, _paytype, (String statusCode, String msg){}
            );
            if (activity != null) {
              Navigator.popAndPushNamed(this.context, '/ActivityInfo',arguments: {"actid": activity.actid});
            }
          },
          onFail: (){

          },
        );
      },
    );
  }
}
