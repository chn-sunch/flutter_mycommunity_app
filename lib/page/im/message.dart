import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:audio_session/audio_session.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../model/aliyun/securitytoken.dart';
import '../../model/im/grouprelation.dart';
import '../../model/im/timelinesync.dart';
import '../../model/activity.dart';
import '../../model/grouppurchase/goodpice_model.dart';
import '../../model/user.dart';
import '../../model/im/redpacket.dart';
import '../../common/iconfont.dart';
import '../../util/showmessage_util.dart';
import '../../util/permission_util.dart';
import '../../util/common_util.dart';
import '../../util/imhelper_util.dart';
import '../../util/net_util.dart';
import '../../service/aliyun.dart';
import '../../service/activity.dart';
import '../../service/imservice.dart';
import '../../service/gpservice.dart';
import '../../bloc/im/im_bloc.dart';
import '../../widget/my_divider.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/spinkitwave.dart';
import '../../widget/photo/soundcircleprocess.dart';
import '../../widget/captcha/block_puzzle_captcha.dart';
import '../../page/im/specialtextspan.dart';

import '../../global.dart';
import 'widget/togglebutton.dart';
import 'widget/w_popup_menu.dart';

enum Initialized {
  notInitialized,
  initializationInProgress,
  fullyInitialized,
  fullyInitializedWithUI,
}

class MyMessage extends StatefulWidget {
  Object? arguments;
  late GroupRelation groupRelation;
  String sharedcontent = "";
  String localsharedcontent = "";

  MyMessage({this.arguments}){
    groupRelation = (arguments as Map)["GroupRelation"];
    if( (arguments as Map)["sharedcontent"] != null)
      sharedcontent = (arguments as Map)["sharedcontent"];

    if( (arguments as Map)["localsharedcontent"] != null){
      localsharedcontent = (arguments as Map)["localsharedcontent"];
    }
  }

  @override
  _MyMessageState createState() => _MyMessageState();
}

class _MyMessageState extends State<MyMessage> with TickerProviderStateMixin {
  List<AssetEntity> _images = [];
  SecurityToken? _securityToken;
  AliyunService _aliyunService = new AliyunService();
  ActivityService _activityService =  ActivityService();
  ImService _imService = ImService();
  final List<String> _leftactions = [
    '复制',
    '删除',
    '举报',
  ];
  final List<String> _rightactions = [
    '复制',
    '删除',
    '撤回',
  ];
  final TextEditingController _textEditingController = TextEditingController();
  StreamSubscription? _playerSubscription;
  final ImHelper _imHelper = new ImHelper();
  Timer? _recordtimer;
  late GroupRelation _groupRelation;
  final ImagePicker _picker = ImagePicker();
  late ImBloc _imBloc;
  final FocusNode _focusNode = FocusNode();
  bool get showCustomKeyBoard => _activeEmojiGird || _activeMoreGrid || _activeSayingGrid;
  bool _activeEmojiGird = false;
  bool _activeMoreGrid = false;
  bool _activeSayingGrid = false;
  bool _sendEnter = true;//避免重复发送多条消息
  double _keyboardHeight = 0.0;
  double _initkeyboardHeight = 0;
  double _scrollThreshold = 200.0;
  double _isPercent = 0;
  int _soundTime = 60;//录音时长60秒；
  int _currentTime = 0;//当前录音时间；
  int _recorderTime = 0;//最后录音时间
  int _showTime =0 ;//显示录音时间
  int _timeLineSyncplay = 0;//0是录音播放  1是群消息播放
  bool _recordercomplete = false;//是否录制完成，//是否在录音中，注意：不要用recorderModule中的isrecordering等判断状态，因为所有event都在一个按钮上无法判断实时状态
  String _recordFilepath = "";
  ScrollController _scrollController = ScrollController(initialScrollOffset: 0);
  List<TimeLineSync> timeLineSyncs = [];
  late AudioSession _audioSession;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  FlutterSoundPlayer _player = FlutterSoundPlayer();

  Directory? _tempDir;
  // late AudioPlayer _player;
  double _pageWidth_2 = 0;
  double _pageWidth = 0;
  double _pagestatus = 0;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int _relationStatus = 1;//1正常 2拉黑
  bool _btnActivityLocked = true;//活动开始、取消开始重复点击判断
  GoodPiceModel? _goodprice;
  Widget _activityinfo = Column(
    children: [
      Container(
        // color: Colors.red,
        height: 50,
        alignment: Alignment.center,
        child: Text('加载中...'),
      ),
      MyDivider()
    ],
  );
  String _msgcontent = "";//消息内容
  String _localmsgcontent = "";//本地消息内容
  String _localpath = "";//本地url
  int _contenttype = 0;//消息内容类型 文本 图片
  StreamSubscription<Map<String, Object>>? _locationListener;
  AMapFlutterLocation _locationPlugin = new AMapFlutterLocation();


  _MyMessageState(){

  }

  Future<void> _initializePlayExample() async {
    //录音按钮播放倒计时
    await _player.openPlayer().then((value) {
      setState(() {
      });
    });
    await _player.setSubscriptionDuration(Duration(seconds: 1));


    _playerSubscription = _player.onProgress!.listen((e) {
      if(_timeLineSyncplay == 0) {
        //录音播放才显示时间
        setState(() {
          if (_showTime - 1 <= 0) {
            _showTime = 0;
          }
          else if (e.position.inSeconds > 1) {
            _showTime = _showTime - 1;
          }
          else
            _showTime = _showTime - e.position.inSeconds;
        });
      }
    });
  }

  Future<void> _initializeRecorderExample() async {
    await _recorder.openRecorder();
    _tempDir = await getTemporaryDirectory();
  }

  Future<void> init() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
    ].request();


    if (statuses[Permission.microphone] != PermissionStatus.granted) {
      ShowMessage.showToast("需要麦克风权限");
      await openAppSettings();
      Navigator.pop(context);
    }

    if (statuses[Permission.microphone]  == PermissionStatus.granted) {
      AudioSession.instance.then((audioSession) async {
        await audioSession.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
          androidWillPauseWhenDucked: true,
        ));
        _audioSession = audioSession;
      });
      await _initializeRecorderExample();
      await _initializePlayExample();
    }

  }

  void _setLocationOption() {
    if (null != _locationPlugin) {
      AMapLocationOption locationOption = new AMapLocationOption();

      ///是否单次定位
      locationOption.onceLocation = true;

      ///是否需要返回逆地理信息
      locationOption.needAddress = true;

      ///逆地理信息的语言类型
      locationOption.geoLanguage = GeoLanguage.DEFAULT;

      locationOption.desiredLocationAccuracyAuthorizationMode =
          AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

      locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

      ///设置Android端连续定位的定位间隔
      locationOption.locationInterval = 2000;

      ///设置Android端的定位模式<br>
      ///可选值：<br>
      ///<li>[AMapLocationMode.Battery_Saving]</li>
      ///<li>[AMapLocationMode.Device_Sensors]</li>
      ///<li>[AMapLocationMode.Hight_Accuracy]</li>
      locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

      ///设置iOS端的定位最小更新距离<br>
      locationOption.distanceFilter = -1;

      ///设置iOS端期望的定位精度
      /// 可选值：<br>
      /// <li>[DesiredAccuracy.Best] 最高精度</li>
      /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
      /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
      /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
      /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
      locationOption.desiredAccuracy = DesiredAccuracy.HundredMeters;

      ///设置iOS端是否允许系统暂停定位
      locationOption.pausesLocationUpdatesAutomatically = false;

      ///将定位参数设置给定位插件
      _locationPlugin.setLocationOption(locationOption);
    }
  }

  ///开始定位
  void _startLocation() {
    if (null != _locationPlugin) {
      ///开始定位之前设置定位参数
      _setLocationOption();
      _locationPlugin.startLocation();
    }
  }

  Future<bool> _initlocation() async {
    bool ret = await PermissionUtil.requestLocationPermisson();

    if (ret){
      if(_locationListener == null) {
        _locationListener = _locationPlugin.onLocationChanged().listen((
            Map<String, Object> result) {
          Map<String, Object>? _locationResult = result;
          if (_locationResult != null) {
            if (result["longitude"] != "" && result["adCode"] != "") {
              Navigator.pushNamed(context, '/MapLocationPicker', arguments: {
                "lat": double.parse(result["latitude"].toString()),
                "lng": double.parse(result["longitude"].toString()),
                "citycode":  CommonUtil.getCityNameByGaoDe(result["adCode"].toString()),
                "isMapImage": true
              }).then((dynamic value) {
                if (value != null) {
                  if (value["image"] == null) {
                    ShowMessage.showToast("获取地图失败,请重试");
                    FocusScope.of(context).requestFocus(FocusNode());
                    return;
                  }
                  locationImage(
                      value["image"], value["address"], value["title"],
                      value["latitude"].toString(),
                      value["longitude"].toString());
                }
                setState(() {
                  FocusScope.of(context).requestFocus(FocusNode());
                });
              });
            }
          }
        });
      }
    }

    return false;
  }

  Future<void> startRecorder() async {
    try {
      await _audioSession.setActive(true);
      String uuid = Uuid().v1().toString().replaceAll('-', '');
      _recordFilepath = '${_tempDir!.path}/${uuid}.mp4';
      _recorder.startRecorder(toFile: _recordFilepath, codec: Codec.aacMP4, audioSource: AudioSource.microphone,).then((value) {
        setState(() {});
      });
      setState(() {
        _isPercent = 1;
      });
      const tick = const Duration(milliseconds: 1000);
      _recordtimer = new Timer.periodic(tick, (Timer t) async {
        if (_recorder.isStopped) {
          t.cancel();
        }
        if(_currentTime == _soundTime){
          t.cancel();
          if(_recorder.isRecording) {
            stopRecorder();
          }
        }
        _currentTime++;
        _showTime = _currentTime;
        setState(() {

        });
      });
    } catch (err) {
      print('startRecorder error: $err');
      setState(() {
        if(_recorder.isRecording) {
          stopRecorder();
        }
      });
    }
  }

  Future<void> stopRecorder() async {
    try {
      await _recorder.stopRecorder().then((value) {
        setState(() {
          //var url = value;
          _recorderTime = _currentTime;
          _recordercomplete = true;
        });
      });
      await _audioSession.setActive(false);
      if(_recordtimer != null)
        _recordtimer!.cancel();

      setState(() {
        _isPercent = 0;
      });

      if(Global.isInDebugMode)
        print(_recordFilepath);
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  Future<void> startPlayer(String filepath, {TimeLineSync? timeLineSync}) async {
    try {
      if(timeLineSync != null){
        _timeLineSyncplay = 1;
        timeLineSync.isplay = true;
        setState(() {
        });
      }
      else{
        _timeLineSyncplay = 0;
      }


      if(_player.isStopped && _recorder.isStopped){
        _player.startPlayer(fromURI: filepath, whenFinished: (){
          setState(() {
            if(timeLineSync != null) {
              timeLineSync.isplay = false;
            }
            _showTime = _currentTime;
          });
        });
      }
    } catch (err) {
      print('error: $err');
    }
  }

  Future<void> stopPlayer() async {
    try {
      timeLineSyncs.getRange(0, timeLineSyncs.length).forEach((element) {
        element.isplay = false;
      });
      await _player.stopPlayer().then((value) {
        setState(() {
          _showTime = _currentTime;
        });
      });

    } catch (err) {
      print('error: $err');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _groupRelation= widget.groupRelation;
    if(_groupRelation.status != null)
      _relationStatus = _groupRelation.status!;

    _initGoodPrice();

    init();
    //初始化群成员
    _getKeyBoardHeight();
    _scrollController.addListener(_onScroll);
    _imBloc = BlocProvider.of<ImBloc>(context);

    _getImMsgInit();

    if(widget.sharedcontent != null && widget.sharedcontent.isNotEmpty) {
      _sendShared();
    }

    _initMember();
  }

  _getImMsgInit() async {
    timeLineSyncs = await _imHelper.getTimeLineSync(Global.profile.user!.uid, 0, 30, _groupRelation.timeline_id );
    if(timeLineSyncs.length == 0 || timeLineSyncs.length == 1){
      if((_groupRelation.relationtype == 0 || _groupRelation.relationtype == 3)) {
        //付费拼玩活动插入一条安全活动规范
        _imHelper.saveInitMessage(_groupRelation.timeline_id);
      }
    }
    setState(() {

    });
  }

  _getImMsgFetch() async {
    List<TimeLineSync> tem = await _imHelper.getTimeLineSync(Global.profile.user!.uid, timeLineSyncs.length,
        timeLineSyncs.length+30, _groupRelation.timeline_id );
    if(tem.length > 0){
      setState(() {
        timeLineSyncs = timeLineSyncs + tem;
      });
    }
  }

  Future<void> _initGoodPrice() async{
    if(_groupRelation.relationtype == 3) {
      GPService gpservice = new GPService();
      _goodprice = await gpservice.getGoodPriceInfo(_groupRelation.goodpriceid);
      if (_goodprice != null) {
        setState(() {

        });
      }
    }
  }

  Future<void> sendMessage(String content, int type, String localmsg, String localpath, String captchaVerification) async {
    this._msgcontent = content;
    this._contenttype = type;
    this._localmsgcontent = localmsg;
    this._localpath = localpath;
    User user = Global.profile.user!;
    List<TimeLineSync> temLine = [];
    String time = "";

    ShowMessage.showToast(this._msgcontent);

    String serviceData = await _imService.postSendMessage(_groupRelation.timeline_id, Global.profile.user!.token!,
        Global.profile.user!.uid, this._msgcontent, this._contenttype, _groupRelation.relationtype!,  captchaVerification,  errorCallBack);

    if(serviceData != null && serviceData != "") {
      time = serviceData.split(",")[0];
      String sourceid = serviceData.split(",")[1];
      temLine.add(TimeLineSync(_groupRelation.timeline_id, 0, user.uid, time,user, this._localmsgcontent, this._contenttype, localpath, sourceid));
    }
    if(time != null && time != ""){
      temLine[0].send_time = time;
      if(await _imHelper.saveSelfMessage(temLine[0]) > 0){
        timeLineSyncs = temLine + timeLineSyncs;
      }

      setState(() {

      });
    }
  }

  _sendShared() async {
    bool isQuit = await _isQuitActivity();
    if(!isQuit){
      await sendMessage(widget.sharedcontent, 5, widget.localsharedcontent, "", "");
    }
  }

  _sendMsg() async {
    await sendMessage(_textEditingController.text, 0, _textEditingController.text, "", "");
    setState(() {
      _textEditingController.text = "";
    });
  }

  _sendSound() async {
    String msg = "";
    _recordercomplete = false;
    SecurityToken? securityToken = await _aliyunService.getSoundSecurityToken(Global.profile.user!.token!, Global.profile.user!.uid);
    if(securityToken != null){
      String soundUrl = await _aliyunService.uploadSound(
          securityToken, _recordFilepath, md5.convert(_recordFilepath.codeUnits).toString() + ".mp4", Global.profile.user!.uid);
      if(soundUrl != null){
        msg = "|sound: ${_recorderTime}#${soundUrl}|";
        String localmsg = "|sound: ${_recorderTime}#${securityToken.host + "/" + soundUrl}|";//本地保存的url
        _recorderTime = 0;
        await sendMessage(msg, 3, localmsg, _recordFilepath, "");
      }
    }
  }

  _sendImg(String localurl, String imgwh, String imgFile) async {
    String imgurl = imgFile;
    String msg = "|img: ${imgurl}#${imgwh}|";
    String localmsg = "|img: ${localurl}#${imgwh}|";
    await sendMessage(msg, 2, localmsg, imgurl, "");
  }

  _sendLocal(String imgFile, String imgwh, String address, String title, String longitude, String latitude, String localurl) async {
    String imgurl = imgFile;
    String msg = "|location: ${imgurl}#${imgwh}#address:${address}#title:${title}#latitude:${latitude}#longitude:${longitude}|";
    String localmsg = "|location: ${localurl}#${imgwh}#address:${address}#title:${title}#latitude:${latitude}#longitude:${longitude}|";
    await sendMessage(msg, 4, localmsg, imgurl, "");
  }

  _sendRedPacket(String msg) async {
    String sendtime = DateTime.now().toString().substring(0,19);

    List<TimeLineSync> temLine = [];
    temLine.add(TimeLineSync(_groupRelation.timeline_id, 0, Global.profile.user!.uid,
        sendtime, Global.profile.user!, msg, 0, '', ""));

    if(await _imHelper.saveSelfMessage(temLine[0]) > 0){
      timeLineSyncs = temLine + timeLineSyncs;

      setState(() {

      });
    }
  }

  _sendDrawRedPacket(String content, String msg) async {
    String sendtime = DateTime.now().toString().substring(0,19);

    List<TimeLineSync> temLine = [];
    temLine.add(TimeLineSync(_groupRelation.timeline_id, 0, 0,
        sendtime, Global.profile.user!, msg, 0, '', ""));
    await _imHelper.updateReceiveRedPacket(content, _groupRelation.timeline_id);

    for(TimeLineSync t in timeLineSyncs){
      if(t.content == content){
        t.isopen = 1;
      }
    }

    if(await _imHelper.saveSelfMessage(temLine[0]) > 0){
      timeLineSyncs = temLine + timeLineSyncs;

      setState(() {

      });
    }
  }

  _blockUser(int status) async {
    bool ret = false;
    if(status == 2) {
      ret = await _imService.updateBlockUser(_groupRelation.timeline_id, Global.profile.user!.token!, Global.profile.user!.uid, _groupRelation.relationtype!,
          errorCallBack);
    }
    else{
      ret = await _imService.updateCancelBlockUser(_groupRelation.timeline_id, Global.profile.user!.token!, Global.profile.user!.uid, _groupRelation.relationtype!, errorCallBack);
    }
    if(ret){
      await _imHelper.updateRelationStatus(_groupRelation.timeline_id, status);
      //更新用户关系表记录聊天状态
      User user = Global.profile.user!;
      String sendtime = DateTime.now().toString().substring(0,19);
      List<TimeLineSync> temLine = [];
      //模拟系统提示
      if(status == 2) {
        temLine.add(TimeLineSync(_groupRelation.timeline_id, 0, 0, sendtime, user,
            _groupRelation.relationtype == 2 ? "你已将对方加入黑名单" : "你已屏蔽群消息", 0, '', ''));
      }
      else{
        temLine.add(TimeLineSync(_groupRelation.timeline_id, 0, 0, sendtime, user,
            _groupRelation.relationtype == 2 ? "已取消黑名单" : "你已取消屏蔽群消息", 0, '', ''));
      }
      if(await _imHelper.saveSelfMessage(temLine[0]) > 0){
        timeLineSyncs = temLine + timeLineSyncs;
      }
    }
    else{
      return;
    }
    _relationStatus = status;
    setState(() {

    });
  }

  _getGroupMember() async {
    if(_groupRelation.relationtype == 0 || _groupRelation.relationtype == 3){
      Activity? activity = await _activityService.getActivityMember(_groupRelation.timeline_id,errorCallBack);
      if(activity != null ){
        if(activity.members != null && activity.members!.length > 0){
          _imHelper.saveGroupMemberRelation(activity.members!, _groupRelation.timeline_id);
        }
      }
    }

    if(_groupRelation.relationtype == 1){
      List<User>? users = await _imService.getCommunityMemberList(_groupRelation.timeline_id, 0);
      if(users != null && users.length > 0) {
        _imHelper.saveGroupMemberRelation(users, _groupRelation.timeline_id);
      }
    }

    _imHelper.updateGroupRelation(_groupRelation.memberupdatetime!, _groupRelation.timeline_id);
  }

  _initMember() async {
    if(_groupRelation.memberupdatetime != null && _groupRelation.memberupdatetime!.isNotEmpty ){
      var newUpdatetime = DateTime.parse(_groupRelation.memberupdatetime!);
      var lastupdatetime = DateTime.parse(_groupRelation.oldmemberupdatetime!);

      if(newUpdatetime.isAfter(lastupdatetime)){
        await _getGroupMember();
      }

      List<User>? users = await _imHelper.getGroupMemberRelation(_groupRelation.timeline_id);

      if(users == null || users.length <= 0 ){
        await _getGroupMember();
      }
    }
  }

  _delImMsg(TimeLineSync timeLineSync) async {
    await _imHelper.delMessage(timeLineSync);
    timeLineSyncs.remove(timeLineSync);
    setState(() {

    });
  }

  _recallImMsg(TimeLineSync timeLineSync, int relationtype ) async {
    bool ret = await _imService.recallMessage(timeLineSync.timeline_id!, Global.profile.user!.token!,
        Global.profile.user!.uid, Global.profile.user!.username, timeLineSync.source_id!, relationtype, errorCallBack);
    if(ret) {
      if (await _imHelper.recallMessage(timeLineSync.source_id!) > 0) {
        timeLineSync.content = "你撤回了一条消息";
        timeLineSync.sender = 0;
      }

      setState(() {

      });
    }
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= _scrollThreshold) {
      _getImMsgFetch();
    }
  }



  @override
  void dispose() {
    if (null != _locationListener) {
      _locationListener!.cancel();
    }
    ///销毁定位
    if (null != _locationPlugin) {
      _locationPlugin.destroy();
    }

    if(_recordtimer != null)
      _recordtimer!.cancel();

    _player.closePlayer();
    _recorder.closeRecorder();
    if (_playerSubscription != null) {
      _playerSubscription!.cancel();
      _playerSubscription = null;
    }
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _getKeyBoardHeight() async{
     SharedPreferences prefs = await _prefs;
     _initkeyboardHeight = (prefs.getDouble('kbheight') ?? 230);
  }

  Future<void> saveKeyBoardHeight(double height) async{
    SharedPreferences prefs = await _prefs;
    prefs.setDouble("kbheight", height).then((bool success) {
      //print(height) ;
    });
  }

  @override
  Widget build(BuildContext context) {
    _pageWidth_2 = MediaQuery.of(context).size.width / 2 -8;
    _pageWidth = MediaQuery.of(context).size.width - 20;
    _pagestatus = MediaQuery.of(context).padding.top;
    if(MediaQuery.of(context).viewInsets.bottom>0) {
      _keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if(_initkeyboardHeight != MediaQuery.of(context).viewInsets.bottom){
        _initkeyboardHeight = MediaQuery
            .of(context)
            .viewInsets
            .bottom;
        saveKeyBoardHeight(_initkeyboardHeight);
      }
    }
    else{
      //_keyboardHeight = showCustomKeyBoard ? _initkeyboardHeight : 0;
      _keyboardHeight = showCustomKeyBoard ? 230 : 0;
    }

    if(_goodprice != null  ){
      _activityinfo = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // color: Colors.red,
                      height: 59,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          _goodprice!.pic != null && _goodprice!.pic != "" ? ClipRRectOhterHeadImageContainer(
                            imageUrl: _goodprice!.pic, width: 59,height: 59,cir: 10,
                          ) : SizedBox.shrink(),
                        ],
                      ),
                    ),
                    _goodprice!.pic != null && _goodprice!.pic != "" ? SizedBox(width: 9,): SizedBox.shrink(),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("￥", style: TextStyle(color: Colors.black87, fontSize: 14),),
                              Text(_goodprice!.mincost.toString(), style: TextStyle(color: Colors.black87, fontSize: 14,fontWeight: FontWeight.bold),),
                              _goodprice!.maxcost > 0 ? Text('-', style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),):SizedBox.shrink(),
                              _goodprice!.maxcost > 0 ? Text(_goodprice!.maxcost.toString(), style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),):SizedBox.shrink(),
                            ],
                          ),
                          Text('${_goodprice!.title}', style: TextStyle(color: Colors.black45, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis, ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/GoodPriceInfo',
                      arguments: {
                        "goodprice": _goodprice
                      }).then((
                      value) {
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              )),
              FlatButton(
                  color: Global.profile.backColor,
                  child: Text(
                    '立即购买',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  textColor: Global.profile.fontColor,
                  shape: RoundedRectangleBorder(
                      side: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(9))
                  ),

                  onPressed: () async{
                    Navigator.pushNamed(context, '/CreateOrder', arguments: {
                      "goodprice": _goodprice,
                      "actid": _groupRelation.timeline_id
                    });
                  }
              )
            ],
          ),
          SizedBox(height: 10,),
          MyDivider()
        ],
      );
    }

    if(_groupRelation.relationtype != 3){
      _activityinfo = SizedBox.shrink();
    }

    return WillPopScope(
      onWillPop: ()async{
        if(!showCustomKeyBoard){
          return true;
        }
        _activeEmojiGird = false;
        _activeMoreGrid = false;
        _activeSayingGrid = false;
        setState(() {

        });
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          bottom: _groupRelation.relationtype != 3 ? null : PreferredSize(
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: _activityinfo,
            ),
            preferredSize: Size.fromHeight(50),
          ),
          backgroundColor: Colors.grey.shade100,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20 ),
            onPressed: (){
              Navigator.pop(context,"return");
            },
          ),
          actions: <Widget>[
            _groupRelation.relationtype != 2 ? IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.black,size: 18,),
              onPressed: (){
                String navurl = "/GroupMember";
                Map argMap = {"timeline_id": _groupRelation.timeline_id, "status": _relationStatus,
                  "reporttype": _groupRelation.relationtype};
                if(_groupRelation.relationtype == 1){
                  navurl = "/MemberList";
                  argMap = {"cid": _groupRelation.timeline_id, "status": _relationStatus, "reporttype": _groupRelation.relationtype};
                }
                SystemChannels.textInput
                    .invokeMethod<void>('TextInput.hide')
                    .whenComplete(() {
                  Future<void>.delayed(const Duration(milliseconds: 200))
                      .whenComplete(() {
                  });
                });
                Navigator.pushNamed(context, navurl, arguments: argMap).then((value){
                  if(value != null){
                    if(value == 2){
                      _blockUser(2);
                    }
                    else{
                      _blockUser(1);
                    }
                  }
                  setState(() {
                    _activeEmojiGird = false;
                    _activeMoreGrid = false;
                    _activeSayingGrid = false;
                    SystemChannels.textInput
                        .invokeMethod<void>('TextInput.hide')
                        .whenComplete(() {
                      Future<void>.delayed(const Duration(milliseconds: 200))
                          .whenComplete(() {});
                    });
                  });

                }
                );
              },
            ) :
            PopupMenuButton<String>(
              onSelected: (String result) {
                if(result == "去主页"){
                  String touid = _groupRelation.timeline_id.replaceAll(Global.profile.user!.uid.toString(), "");
                  Navigator.pushNamed(context, '/OtherProfile', arguments: {"uid": int.parse(touid)});
                  return;
                  // Navigator.pushNamed(context, '/ReportOtherIm', arguments: {"timeline_id": widget.groupRelation.timeline_id,
                  //   "reporttype":  widget.groupRelation.relationtype});
                }
                if(_relationStatus == 1){
                  _blockUser(2);
                }
                else if(_relationStatus == 2){
                  _blockUser(1);
                }
              },

              icon: Icon(Icons.more_horiz, color: Colors.black,size: 18,),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: "拉黑",
                  child: _relationStatus == 1 ? Text("拉黑") :  Text("取消拉黑"),
                ),
                PopupMenuItem<String>(
                  value: "去主页",
                  child: Text('去主页'),
                ),
              ],
            ),
          ],
          title: _groupRelation.group_name1 != null ? Text(_groupRelation.group_name1!.length > 10? _groupRelation.group_name1!.substring(0,10) : _groupRelation.group_name1!,
              style: TextStyle(color:  Colors.black87, fontSize: 16)): Text(''),
          centerTitle: true,
        ),
        body: BlocBuilder<ImBloc, ImState>(
          buildWhen: (context, state) {
            if(state is NewMessageState) {
              bool ret = false;
              for(GroupRelation tem in state.groupRelations){
                if(tem.timeline_id == _groupRelation.timeline_id){
                  _imBloc.add(Already(Global.profile.user!, _groupRelation.timeline_id));
                  if(state.msgMessage.length > 0) {
                    timeLineSyncs = state.msgMessage;
                    ret = true;
                  }
                }
              }
              return ret;
            }
            else
              return false;
          },
          builder: (context, state){
            List<Widget> list = [];
            timeLineSyncs != null ? list = buildMsgContent(timeLineSyncs): list.add(SizedBox.shrink());
            return InkWell(
              focusColor: Colors.grey.shade100,
              highlightColor: Colors.grey.shade100,
              radius: 0.0,
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView(
                          controller: _scrollController,
                          reverse: true,
                          children: list,
                          shrinkWrap: true,
                        ),
//                        child: ExtendedListView(
//                          controller: _scrollController,
//                          reverse: true,
//                          children: list,
//                          extendedListDelegate: ExtendedListDelegate(closeToTrailing: true),
//                        ),
                      )
                  ),
                  buildMsgSendBtn(),
                  AnimatedSize(
                      vsync: this,
                      curve: Curves.ease,
                      duration: Duration(milliseconds: 200),
                      child: Container(
                        height: MediaQuery.of(context).viewInsets.bottom>0?MediaQuery.of(context).viewInsets.bottom:_keyboardHeight,
                        child: buildCustomKeyBoard(),
                      )
                  ),
                ],
              ),
              onTap: (){
                setState(() {
                  _activeMoreGrid = false;
                  _activeSayingGrid = false;
                  _activeEmojiGird = false;
                  _focusNode.unfocus();
                });
                //update(change);
                //FocusScope.of(context).requestFocus(FocusNode());
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> buildMsgContent(List<TimeLineSync> timeLineSyncs){
    List<Widget> rows = [];
    for(int i=0; i < timeLineSyncs.length ; i++){
      //系统通知,两次消息间隔超过10分钟就在消息上方显示发送时间

      if(timeLineSyncs[i].sender == 0){
        rows.add(buildSysMsg(timeLineSyncs[i]));
        if(timeLineSyncs[i].content!.indexOf("@安全活动规范@") < 0) {
          rows.add(buildMsgTime(timeLineSyncs[i]));
        }
      }
      else if( timeLineSyncs[i].sender == Global.profile.user!.uid ) {
        if(((i+1 < timeLineSyncs.length && DateTime.parse(timeLineSyncs[i].send_time!).difference(
            DateTime.parse(timeLineSyncs[i+1].send_time!)).inMinutes.abs() > 5)  || i == timeLineSyncs.length - 1)) {
          rows.add(buildMyContent(timeLineSyncs[i]));
          rows.add(buildMsgTime(timeLineSyncs[i]));
        }
        else
          rows.add(buildMyContent(timeLineSyncs[i]));
      }
      else{
        if(((i+1 < timeLineSyncs.length &&DateTime.parse(timeLineSyncs[i].send_time!).difference(
        DateTime.parse(timeLineSyncs[i+1].send_time!)).inMinutes.abs() > 5)  || i == timeLineSyncs.length - 1 )){
          rows.add(buildHerContent(timeLineSyncs[i]));
          rows.add(buildMsgTime(timeLineSyncs[i]));
        }
        else
          rows.add(buildHerContent(timeLineSyncs[i]));
      }
    }
    return rows;
  }

  Widget buildSysMsg(TimeLineSync timeLineSync){
    if(timeLineSync.content!.indexOf("@安全活动规范@") >= 0){
      return Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(child: InkWell(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('安全活动规范', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),  ),
                      SizedBox(height: 5,),
                      Text('为了确保您的资金安全，请遵守出来玩吧交易规范，一定要在平台内完成支付。', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      SizedBox(height: 5,),
                      MyDivider(),
                      SizedBox(height: 5,),
                      Text('了解出来玩吧交易规范', style: TextStyle(color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/HtmlContent', arguments: {"parameterkey": "activityagree", "title": "安全活动规范"});
                },
              )
              ),
            ]
        ),
      );
    }
    else if(timeLineSync.content!.indexOf("|sysactivitynotice:") >= 0){
      String temNotice = timeLineSync.content!.replaceAll("|sysactivitynotice:", '');
      return Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(child: InkWell(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('活动通知', style: TextStyle(color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.bold),  ),
                      SizedBox(height: 5,),
                      Text(temNotice, style: TextStyle(color: Colors.black87, fontSize: 13)),
                      SizedBox(height: 5,),
                    ],
                  ),
                ),
                onTap: (){
                },
              )
              ),
            ]
        ),
      );
    }
    else if(timeLineSync.content!.indexOf("@|你领取了") >= 0){
      String temNotice = timeLineSync.content!.replaceAll("@|", '');
      temNotice = temNotice.replaceAll("红包", '');
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 259,
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconFont.icon_hongbao, color: Colors.red, size: 19,),
                  SizedBox(width: 10,),
                  Text(temNotice, style: TextStyle(color: Colors.black87, fontSize: 14),  ),
                  Text('红包', style: TextStyle(fontSize: 14, color: Colors.red),),
                ],
              ),
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(9.0)),
              ),
            )
          ]
      );
    }
    else {
      return Container(
        margin: EdgeInsets.only(bottom: 10, left: 30, right: 30),
        alignment: Alignment.center,
        child: Text(
          timeLineSync.content!, style: TextStyle(color: Colors.black45, fontSize: 13),),
      );
    }
  }

  Widget buildMsgTime(TimeLineSync timeLineSync){
    DateTime send_time = DateTime.parse(timeLineSync.send_time!);
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 5),
      alignment: Alignment.center,
      child: Text('${send_time.month}月${send_time.day}日 '
          '${send_time.hour}:${send_time.minute<10?('0'+send_time.minute.toString()):send_time.minute}', style:
      TextStyle(color: Colors.black45, fontSize: 13),),
    );
  }

  Widget buildMyContent(TimeLineSync timeLineSync){
    //组件有问题要在外面处理，里面也处理了一次
    double contentwidth = 0.0;
    Widget widContent = SizedBox.shrink();
    bool isImg = false;
    if(timeLineSync.contenttype == ContentType.Type_Sound.index){
      String key = timeLineSync.content!.replaceAll('|sound: ', '').replaceAll('|', '');
      List<String> soundinfo = key.split('#');
      contentwidth = double.parse(soundinfo[0]);
      widContent = Container(
        width: contentwidth*2 + 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ExtendedText(timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,    maxLines: 50,
                  specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false,)), !timeLineSync.isplay! ? Icon(
                IconFont.icon_saying,
                color: Colors.white,
              ):MySpinKitWave(color: Colors.white, type: MySpinKitWaveType.center, size: 24, itemCount: 5,)
            ]
        ),
      );
    }
    else if(timeLineSync.contenttype == ContentType.Type_Image.index){
      //组件有问题要在外面处理，里面也处理了一次
      String key = timeLineSync.content!.replaceAll('|img: ', '').replaceAll('|', '');
      List<String> imginfo = key.split('#');
      String imgurl = imginfo[0];
      isImg = true;

      widContent = Container(
        width: _pageWidth-20,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: (){
                  Navigator.pushNamed(context, '/PhotoViewImageHead', arguments: {"image":  imgurl});
                },
                child: ExtendedText(
                    timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 50,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false, pagewidth: _pageWidth_2)),
              )
            ]
        ),
      );
    }
    else if(timeLineSync.contenttype == ContentType.Type_Location.index){
      isImg = true;
      //不要写在组件里组件有bug
      List<String> locatoninfo = timeLineSync.content!.replaceAll('|location: ', '').replaceAll('|', '').split('#');
      String lat = locatoninfo[4].split(':')[1].toString();
      String lng = locatoninfo[5].split(':')[1].toString();
      String title = locatoninfo[3].split(":")[1];
      String address = locatoninfo[2].split(":")[1];


      widContent = Container(
        width: _pageWidth - 20.0,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: (){
                  Navigator.pushNamed(context, '/MapLocationShowNav', arguments: {"lat" : lat, "lng": lng, "title": title, "address": address});
                },
                child: ExtendedText(
                    timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,    maxLines: 50,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false, pagewidth: _pageWidth_2)),
              )
            ]
        ),
      );
    }
    else if(timeLineSync.contenttype == ContentType.Type_shared.index){
      isImg = true;

      List<String> sharedinfo = timeLineSync.content!.replaceAll('|shared: ', '').replaceAll('|', '').split('#');
      String sharedtype = sharedinfo[0];//分享类型 0 活动 1商品
      String contentid = sharedinfo[1];
      String content = sharedinfo[2];
      String image = sharedinfo[3];

      widContent = Container(
        width: _pageWidth - 20,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: (){
                  if(sharedtype == "0"){
                    Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": contentid});
                  }
                  if(sharedtype == "1"){
                    _gotoGoodPrice(contentid);
                  }
                  if(sharedtype == "2"){
                    Navigator.pushNamed(context, '/MomentInfo', arguments: {"momentid": contentid});
                  }
                },
                child: ExtendedText(
                    timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,    maxLines: 50,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false, pagewidth: _pageWidth_2)),
              )
            ]
        ),
      );
    }
    else if(timeLineSync.content != null && timeLineSync.content!.indexOf("|sendredpacket:") >= 0){
      isImg = true;

      String redpacketinfo = timeLineSync.content!.replaceAll('|sendredpacket:', '').replaceAll('|', '').trim();
      String redpacketid = redpacketinfo.split("#")[1];

      widContent = Container(
        width: _pageWidth - 20,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: () async {
                  if(redpacketid != null) {
                    RedPacketModel? redpacket = await _imService.getRedPacket(
                        Global.profile.user!.uid, Global.profile.user!.token!,
                        redpacketid, (code, msg) {
                      ShowMessage.showToast(msg);
                    });

                    if (redpacket == null) return;
                    //弹出红包三种状态  1已经领取  2红包过期 3还没有领
                    if (redpacket.touid != null && redpacket.touid > 0) {
                      //1已经领取
                      _imHelper.updateReceiveRedPacket(timeLineSync.content!, timeLineSync.timeline_id!);
                      Navigator.pushNamed(context, '/RedPacketList',
                          arguments: {
                            "redPacketModel": redpacket,
                            "receiveMoney": redpacket.tofund
                          });
                    }
                    else if (redpacket.uid == Global.profile.user!.uid && redpacket.redpacketnum == redpacket.currentnum){
                      //红包已经被领完
                      _imHelper.updateReceiveRedPacket(timeLineSync.content!, timeLineSync.timeline_id!);
                      Navigator.pushNamed(context, '/RedPacketList',
                          arguments: {
                            "redPacketModel": redpacket,
                            "receiveMoney": 0.0
                          });
                    }
                    else if (redpacket.isexpire) {
                      //已经过期
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              alignment: Alignment.center,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: new BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(9.0)),
                                ),
                                width: 290,
                                height: 410,
                                child: ListView(
                                  children: buildRedInfo(
                                      redpacket, timeLineSync.content!,
                                      timeLineSync.timeline_id!),
                                ),
                              )
                          );
                        },
                      );
                    }
                    else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              alignment: Alignment.center,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: new BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(9.0)),
                                ),
                                width: 290,
                                height: 410,
                                child: ListView(
                                  children: buildRedInfo(
                                      redpacket, timeLineSync.content!,
                                      timeLineSync.timeline_id!),
                                ),
                              )
                          );
                        },
                      );
                    }
                  }
                },
                child: ExtendedText(
                    timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,    maxLines: 50,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false, pagewidth: _pageWidth_2,  isopen: timeLineSync.isopen == 0 ? false: true)),
              )

            ]
        ),
      );
    }
    else{
      widContent = WPopupMenu(
        menuWidth: 190,
        menuHeight: 39,
        actions: _rightactions,
        onValueChanged: (int value) {
          if(value == 0){
            //复制
            Clipboard.setData(ClipboardData(text: timeLineSync.content));
            ShowMessage.showToast('复制成功');
          }
          if(value == 1){
            //删除
            _delImMsg(timeLineSync);
          }
          if(value == 2){
            //撤回
            int diffmin = CommonUtil.handleMinDate(timeLineSync.send_time!);
            if(diffmin <= 2) {
              _recallImMsg(timeLineSync, widget.groupRelation.relationtype!);
            }
            else{
              ShowMessage.showToast("两分钟以内的消息才能撤回");
            }
          }
        },
        leftorright: 1,
        backgroundColor: Colors.black,
        child: ExtendedText(
            timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,    maxLines: 50,
            specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false )),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: SizedBox.shrink(),
        ),
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.only(bottom: 10, right: 10),
            alignment: Alignment.centerRight,
            child: InkWell(
              child: Container(
                  decoration: new BoxDecoration(
                    color: isImg ? null : Colors.cyan,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), bottomRight: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
                  ),
                  child:Padding(
                    padding: isImg ? EdgeInsets.only(left: 10, right: 10) : EdgeInsets.all(10),
                    child: widContent
                  )
              ),
              onTap: ()  async {
                  if(timeLineSync.isplay! ){
                    stopPlayer();
                  }
                  else {
                    await soundLoadAndPaly(timeLineSync);
                    setState(() {

                    });
                  }
              },
            ),
            decoration: new BoxDecoration(
              color: Colors.grey.shade100,
            ),
          ),
        )
      ],
    );
  }

  Widget buildHerContent(TimeLineSync timeLineSync){
    double contentwidth = 0.0;
    bool isImg = false;
    Widget widContent = SizedBox.shrink();
    if(timeLineSync.contenttype == ContentType.Type_Sound.index){
      String key = timeLineSync.content!.replaceAll('|sound: ', '').replaceAll('|', '');
      List<String> soundinfo = key.split('#');
      contentwidth = double.parse(soundinfo[0]);
      widContent=Container(
        width: contentwidth*2 + 75,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ExtendedText(timeLineSync.content!, style: TextStyle(color: Colors.black87), overflow: TextOverflow.ellipsis,    maxLines: 50,
                  specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false,)),
              !timeLineSync.isplay! ? Icon(
                IconFont.icon_saying,
                color: Colors.black87,
              ):MySpinKitWave(color: Colors.black87, type: MySpinKitWaveType.center, size: 24, itemCount: 5,)
            ]
        ),
      );
    }
    else if(timeLineSync.contenttype == ContentType.Type_Image.index){
      //组件有问题要在外面处理，里面也处理了一次

      String key = timeLineSync.content!.replaceAll('|img: ', '').replaceAll('|', '');
      List<String> imginfo = key.split('#');
      String imgurl = imginfo[0];
      isImg = true;

      widContent = Container(
        width: _pageWidth - 20,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: (){
                  Navigator.pushNamed(context, '/PhotoViewImageHead', arguments: {"image":  imgurl});
                },
                child: ExtendedText(
                    timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 50,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false, pagewidth: _pageWidth_2)),
              )
            ]
        ),
      );
    }
    else if(timeLineSync.contenttype == ContentType.Type_Location.index){

      isImg = true;
      //不要写在组件里组件有bug
      List<String> locatoninfo = timeLineSync.content!.replaceAll('|location: ', '').replaceAll('|', '').split('#');
      String lat = locatoninfo[4].split(':')[1].toString();
      String lng = locatoninfo[5].split(':')[1].toString();
      String title = locatoninfo[3].split(":")[1];
      String address = locatoninfo[2].split(":")[1];


      widContent = Container(
        width: _pageWidth - 20.0,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: (){
                  Navigator.pushNamed(context, '/MapLocationShowNav', arguments: {"lat" : lat, "lng": lng, "title": title, "address": address});
                },
                child: ExtendedText(
                    timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,    maxLines: 50,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false, pagewidth: _pageWidth_2)),
              )
            ]
        ),
      );
    }
    else if(timeLineSync.contenttype == ContentType.Type_shared.index){
      isImg = true;

      List<String> sharedinfo = timeLineSync.content!.replaceAll('|shared: ', '').replaceAll('|', '').split('#');
      String sharedtype = sharedinfo[0];//分享类型 0 活动 1商品
      String contentid = sharedinfo[1];
      String content = sharedinfo[2];
      String image = sharedinfo[3];

      widContent = Container(
        width: _pageWidth - 20,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: (){
                  if(sharedtype == "0"){
                    Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": contentid});
                  }
                  if(sharedtype == "1"){
                    _gotoGoodPrice(contentid);
                  }
                  if(sharedtype == "2"){
                    Navigator.pushNamed(context, '/MomentInfo', arguments: {"momentid": contentid});
                  }
                },
                child: ExtendedText(
                    timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,    maxLines: 50,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false, pagewidth: _pageWidth_2)),
              )
            ]
        ),
      );
    }
    else if(timeLineSync.content!.indexOf("|sendredpacket:") >= 0){
      isImg = true;
      String redpacketinfo = timeLineSync.content!.replaceAll('|sendredpacket:', '').replaceAll('|', '').trim();
      String redpacketid = redpacketinfo.split("#")[1];

      widContent = Container(
        width: _pageWidth - 20,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: () async {
                  if(redpacketid != null){
                    RedPacketModel? redpacket = await _imService.getRedPacket(Global.profile.user!.uid, Global.profile.user!.token!,
                        redpacketid, (code,msg){
                          ShowMessage.showToast(msg);
                        } );

                    if(redpacket == null) return;
                    //弹出红包三种状态  1已经领取  2红包过期 3还没有领
                    if(redpacket.touid != null && redpacket.touid > 0){
                      //1已经领取
                      _imHelper.updateReceiveRedPacket(timeLineSync.content!, timeLineSync.timeline_id!);

                      Navigator.pushNamed(context, '/RedPacketList', arguments: {"redPacketModel": redpacket, "receiveMoney": redpacket.tofund});
                    }
                    else if(redpacket.isexpire){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              alignment: Alignment.center,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: new BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(9.0)),
                                ),
                                width: 290,
                                height: 410,
                                child: ListView(
                                  children: buildRedInfo(
                                      redpacket, timeLineSync.content!,
                                      timeLineSync.timeline_id!),
                                ),
                              )
                          );
                        },
                      );
                    }
                    else if(redpacket.redpacketnum == redpacket.currentnum){
                      //已经被领完
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              alignment: Alignment.center,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: new BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                ),
                                width: 290,
                                height: 410,
                                child: ListView(
                                  children: buildRedInfo(redpacket, timeLineSync.content!, timeLineSync.timeline_id!),
                                ),
                              )
                          );
                        },
                      );
                    }
                    else{
                      //还没有领
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                              alignment: Alignment.center,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: new BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                ),
                                width: 290,
                                height: 410,
                                child: ListView(
                                  children: buildRedInfo(redpacket, timeLineSync.content!, timeLineSync.timeline_id!),
                                ),
                              )
                          );
                        },
                      );
                    }
                  }
                },
                child: ExtendedText(
                    timeLineSync.content!, style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis,    maxLines: 50,
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false, pagewidth: _pageWidth_2, isopen: timeLineSync.isopen == 0 ? false: true)),
              )
            ]
        ),
      );
    }
    else{
      widContent = WPopupMenu(
        menuWidth: 190,
        menuHeight: 39,
        actions: _leftactions,
        leftorright: 0,
        backgroundColor: Colors.black,
          onValueChanged: (int value) {
            if(value == 0){
              //复制
              Clipboard.setData(ClipboardData(text: timeLineSync.content));
              ShowMessage.showToast('复制成功');
            }
            if(value == 1){
              _delImMsg(timeLineSync);
            }
            if(value == 2){
              //举报//0活动群，1社团群 //2私聊  //3活动群团购
              if(widget.groupRelation.relationtype == 0 || widget.groupRelation.relationtype == 3){
                Navigator.pushNamed(context, '/ReportAllMessage', arguments: {"sourcetype": 4, "actid": widget.groupRelation.timeline_id.toString(), "touid": timeLineSync.sender, "content": timeLineSync.content});
              }
              if(widget.groupRelation.relationtype == 1){
                Navigator.pushNamed(context, '/ReportAllMessage', arguments: {"sourcetype": 5, "actid": widget.groupRelation.timeline_id.toString(), "touid": timeLineSync.sender, "content": timeLineSync.content});
              }
              if(widget.groupRelation.relationtype == 2){
                Navigator.pushNamed(context, '/ReportAllMessage', arguments: {"sourcetype": 3, "actid": widget.groupRelation.timeline_id.toString(), "touid": timeLineSync.sender, "content": timeLineSync.content});
              }
            }
          },
        child: ExtendedText(timeLineSync.content!, style: TextStyle(color: Colors.black87), overflow: TextOverflow.ellipsis,    maxLines: 50,
          specialTextSpanBuilder: MySpecialTextSpanBuilder(
            showAtBackground: false,
          )));
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            key: UniqueKey(),
            width: 45,
            height: 45,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
            child: NoCacheCircleHeadImage(imageUrl: timeLineSync.serderpicture!, uid: timeLineSync.sender!),
          ),
          Expanded(
            flex: 8,
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              alignment: Alignment.centerLeft,
              decoration: new BoxDecoration(
                color: Colors.grey.shade100,
              ),
              child: InkWell(
                child: Container(
                  decoration: new BoxDecoration(
                    color: isImg ? null : Colors.white,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: widContent
                  )

                ),
                onTap: () async {
                  if(timeLineSync.isplay! ){
                    stopPlayer();
                  }
                  else {
                    await soundLoadAndPaly(timeLineSync);
                    setState(() {

                    });
                  }
                },
              )
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox.shrink(),
          ),
        ],
    );
  }

  Widget buildMsgSendBtn(){
    return Container(// !important
        color: Colors.grey.shade50,
        width: double.infinity,
        child: Row(
          crossAxisAlignment:   CrossAxisAlignment.center,
          children: <Widget>[
            ToggleButton(
              activeWidget: Icon(
                IconFont.icon_jianpan,
              ),
              unActiveWidget: Icon(IconFont.icon_jianpan),
              activeChanged: (bool active) {
                final Function change = () {
                  setState(() {
                    if (active) {
                      _activeMoreGrid = false;
                      _activeEmojiGird = false;
//                      FocusScope.of(context).requestFocus(_focusNode);
                    }
                    _activeSayingGrid = active;
                  });
                };
                update(change);
              },
              active: _activeSayingGrid,
            ),
            Expanded(
                child: Container(
                  height: 39,
                  padding: EdgeInsets.only(left: 5),
                  margin: EdgeInsets.only(bottom: 5, top: 5, left: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: new Border.all(color: Colors.black26, width: 0.1),
                        borderRadius: new BorderRadius.circular((5.0))
                    ),
                    child: ExtendedTextField(
                        onTap: (){
                          setState(() {
                            _activeSayingGrid = false;
                            _activeEmojiGird = false;
                            _activeMoreGrid =false;
                          });
                        },
                        style: TextStyle(fontSize: 14),
                        specialTextSpanBuilder: MySpecialTextSpanBuilder(
                          showAtBackground: false,
                        ),
                        maxLength: 255,
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        maxLines: null,
                        autofocus: false,
                        cursorColor: Colors.cyan,
                        onChanged: (val) {
                          if(val == '@' && _groupRelation.relationtype != 2){
                            selectMember();
                          }
                          setState(() {

                          });
                        },
                        decoration: InputDecoration(
                          labelStyle: TextStyle(fontSize: 14),
                          hintStyle: TextStyle(fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white,
                          counterText: '',
                          hintText: '输入新消息',
                        )
                    ),
                )
            ),
            ToggleButton(
              activeWidget: Icon(
                IconFont.icon_jianpan2,
              ),
              unActiveWidget: Icon(IconFont.icon_biaoqing),
              activeChanged: (bool active) {
                final Function change = () {
                  setState(() {
                    if (active) {
                      _activeMoreGrid = false;
                      _activeSayingGrid = false;
                      //FocusScope.of(context).requestFocus(_focusNode);
                    }
                    _activeEmojiGird = active;
                  });
                };
                update(change);
              },
              active: _activeEmojiGird,
            ),
            _textEditingController.text.isNotEmpty ? SizedBox.shrink() : ToggleButton(
              activeWidget: Icon(
                IconFont.icon_guanbi1,
              ),
              unActiveWidget: Icon(IconFont.icon_tianjiayuan),
              activeChanged: (bool active) {
                final Function change = () {
                  setState(() {
                    if (active) {
                      _activeEmojiGird = false;
                      _activeSayingGrid = false;
                      //FocusScope.of(context).requestFocus(_focusNode);
                    }
                    _activeMoreGrid = active;
                  });
                };
                update(change);
              },
              active: _activeMoreGrid,
            ),
            _textEditingController.text.isNotEmpty ? Container(
              margin: EdgeInsets.only(left: 5),
              width: 65,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(
                        Radius.circular(5))),
                child: Text('发送', style: TextStyle(color: Colors.white),),
                color: Colors.cyan,
                onPressed: () async {
                  bool isQuit = await _isQuitActivity();
                  if(isQuit){
                    return;
                  }
                  _sendMsg();
                },
              ),
            ) : SizedBox.shrink()
          ],
        )
    );
  }

  Widget buildCustomKeyBoard() {
    Widget gridbutton = SizedBox.shrink();
    if (_activeSayingGrid) {
      gridbutton = buildSayGrid();
    }
    else{
      if(_recorder.isRecording) {
        stopRecorder();
      }
    }

    if (!showCustomKeyBoard) {
      gridbutton = Container();
    }
    if (_activeEmojiGird) {
      gridbutton = buildEmojiGird();
    }

    if (_activeMoreGrid) {
      gridbutton = buildParGrid();
    }

    return Container(
      padding: EdgeInsets.only(top: 10),
      color: Colors.grey.shade100,
      child: gridbutton,
    );
  }
  //显示语音输入图标
  Widget buildSayGrid(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _recordercomplete ? InkWell(
          child: Container(
            height: 35,
            width: 40,
            child: Icon(Icons.delete, color: Colors.white),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
          onTap: () async {
            await recoderDel();
          },
        ):SizedBox.shrink(),
        Padding(
          padding: EdgeInsets.only(left: 20),
        ),
        CircularPercentIndicator(
          radius: 80.0,
          lineWidth: 10.0,
          animation: true,
          circularStrokeCap: CircularStrokeCap.round,
          animationDuration: 60000,
          percent: _isPercent,
          header: Text('${_showTime}S', style: TextStyle(color: Colors.black, fontSize: 18),),
          footer: Text(_recorder.isRecording ? "录音中" : (_recordercomplete ? "点击播放" : "点击录音") , style: TextStyle(color: Colors.black),),
          center: InkWell(
              highlightColor: Colors.transparent,
              child: Container(
                  child: _recordercomplete ? (_player.isPlaying && _timeLineSyncplay == 0 ? SpinKitWave(color: Colors.cyan, type: SpinKitWaveType.center, size: 30,) : Container(
                  margin: EdgeInsets.only(left: 5, bottom: 3),
                  alignment: Alignment.center,
                  child: Icon(
                    IconFont.icon_bofang,
                    size: 30,
                    color: Colors.cyan,
                  ))): ( _recorder.isRecording ? SoundCircleProcess() : Container(width: 55, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.cyan),)
                   //SpreadWidget(radius: 50,maxRadius: 100,child: Icon(IconFont.icon_luyin))
              )
            ),
              onTap: ()  async {
                //停止录音
                if (_recorder.isRecording) {
                  stopRecorder();
                }
                else if (_player.isPlaying) {
                  await stopPlayer();
                }
                else if (!_recordercomplete) {
                  startRecorder();
                }
                else{
                  _timeLineSyncplay = 0;
                  await startPlayer(_recordFilepath);
                }
              }
          ),
          backgroundColor: Colors.cyan.shade100,
          progressColor: Colors.cyan,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
        ),
        _recordercomplete ? InkWell(
          child: Container(
            height: 35,
            width: 40,
            child: Icon(Icons.check, color: Colors.white),
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
          onTap: ()  async {
            if(_sendEnter) {
              _sendEnter = false;
              bool isQuit = await _isQuitActivity();
              if (isQuit) {
                return;
              }
              await _sendSound();
              await recoderDel();
              _sendEnter = true;
            }
          },
        ):SizedBox.shrink()
      ],
    );
  }
  //显示表情图标
  Widget buildEmojiGird() {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, crossAxisSpacing: 20.0, mainAxisSpacing: 15.0),
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              child: Image.asset(EmojiUitl.instance.emojiMap['[${index + 1}]']!),
              //behavior: HitTestBehavior.translucent,
              onTap: () {
                insertText('[${index + 1}]');
                setState(() {

                });
              },
            );
          },
          itemCount: EmojiUitl.instance.emojiMap.length,
          padding: const EdgeInsets.all(5.0),
        ),
      ),
      onTap: (){
      },
    );
  }
  //显示相册、拍照、位置等
  Widget buildParGrid() {
    double ratio = 1.0;
    //ipad用
    if(((_pageWidth / 4 - 50) / 70) > 1.1){
      ratio = ((_pageWidth / 4 - 50) / 70);
    }
    return GridView(
      children: [
        GestureDetector(
          child: Column(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                child: Icon(IconFont.icon_xiangce2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:  BorderRadius.circular(10),
                )
              ),
              SizedBox(height: 10,),
              Align(
                child: Text('相册', style: TextStyle(color: Colors.black54, fontSize: 13),),
              ),
            ],
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            bool isQuit = await _isQuitActivity();
            if(isQuit){
              return;
            }
            loadAssets();
            //insertText(text);
          },
        ),
        GestureDetector(
          child: Column(
            children: <Widget>[
              Container(
                  width: 50,
                  height: 50,
                  child: Icon(IconFont.icon_paizhao1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:  BorderRadius.circular(10),
                  )
              ),
              SizedBox(height: 10,),
              Align(
                child: Text('拍摄', style: TextStyle(color: Colors.black54, fontSize: 13),),
              ),
            ],
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            bool isQuit = await _isQuitActivity();
            if(isQuit){
              return;
            }
            pickImage();
          },
        ),
        GestureDetector(
          child: Column(
            children: <Widget>[
              Container(
                  width: 50,
                  height: 50,
                  child: Icon(IconFont.icon_weizhi1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:  BorderRadius.circular(10),
                  )
              ),
              SizedBox(height: 10,),
              Align(
                child: Text('位置', style: TextStyle(color: Colors.black54, fontSize: 13),),
              ),
            ],
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            bool isQuit = await _isQuitActivity();
            if(isQuit){
              return;
            }
            //insertText(text);
             await _initlocation();
            _startLocation();
          },
        ),
        GestureDetector(
          child: Column(
            children: <Widget>[
              Container(
                  width: 50,
                  height: 50,
                  child: Icon(IconFont.icon_huodong2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:  BorderRadius.circular(10),
                  )
              ),
              SizedBox(height: 10,),
              Align(
                child: Text('活动', style: TextStyle(color: Colors.black54, fontSize: 13),),
              ),
            ],
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            //insertText(text);
            if(_groupRelation.relationtype  == 0 || _groupRelation.relationtype == 3) {
              Navigator.pushNamed(context, '/ActivityInfo',
                  arguments: {"actid": _groupRelation.timeline_id}).then((
                  value) {
                FocusScope.of(context).requestFocus(FocusNode());
              });
            }
            else{
              ShowMessage.showToast('这不是一个活动群');
            }
          },
        ),
        GestureDetector(
          child: Column(
            children: <Widget>[
              Container(
                  width: 50,
                  height: 50,
                  child: Icon(IconFont.icon_pintu_huabanfuben),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:  BorderRadius.circular(10),
                  )
              ),
              SizedBox(height: 10,),
              Align(
                child: Text('红包', style: TextStyle(color: Colors.black54, fontSize: 13),),
              ),
            ],
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            bool isQuit = await _isQuitActivity();
            if(isQuit){
              return;
            }
            Navigator.pushNamed(context, '/RedPacket', arguments: {"timeline_id": _groupRelation.timeline_id,
              "timeline_type": _groupRelation.relationtype}).then((value){
              if(value != null && value.toString().indexOf("|sendredpacket:") >= 0){
                _sendRedPacket(value.toString());
              }
            });
          },
        ),

      ],
      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: ratio,
        crossAxisCount: 4,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0),
      padding: const EdgeInsets.all(1.0),
    );
  }

  List<Widget> buildRedInfo(RedPacketModel redPacketModel, String content, String timeline_id){
    List<Widget> redInfo = [];
    redInfo.add(SizedBox.shrink());

    if(redPacketModel.profilepicture != null){
      redInfo.add(Container(
        margin: EdgeInsets.only(top: 30, bottom: 10),
        alignment: Alignment.center,
        child: NoCacheClipRRectOhterHeadImage(imageUrl: redPacketModel.profilepicture, uid: redPacketModel.uid, width: 50),
      ));
    }

    if(redPacketModel.username != null){
      redInfo.add(Container(
        alignment: Alignment.center,
        child: Text(redPacketModel.username, style: TextStyle(fontSize: 14, color: Colors.white,decoration: TextDecoration.none, fontWeight: FontWeight.w500),),
      ),);
    }

    if(redPacketModel.redpackettype != null){
      redInfo.add(Container(
        alignment: Alignment.center,
        child: Text(redPacketModel.redpackettype == 0 ? '拼手气红包': '普通红包', style: TextStyle(decoration: TextDecoration.none,  fontWeight: FontWeight.w500,
            fontSize: 12, color: Colors.grey.shade200),),
      ));
    }


    redInfo.add(Container(
      margin: EdgeInsets.only(top: 39, bottom: 30),
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Text(redPacketModel.content, style: TextStyle(decoration: TextDecoration.none,  fontWeight: FontWeight.w500,
          fontSize: 19, color: Colors.white),),
    ));

    if(redPacketModel.isexpire){
      redInfo.add(
          Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text('红包已超过24小时过期了',  style: TextStyle(decoration: TextDecoration.none,  fontWeight: FontWeight.w500,
                      fontSize: 16, color: Colors.white),),
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text('看看大家的手气',  style: TextStyle(decoration: TextDecoration.none,  fontWeight: FontWeight.w500,
                          fontSize: 13, color: Color(0xfff0e68c)),),
                    ),
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/RedPacketList', arguments: {
                        "redPacketModel": redPacketModel,
                        "receiveMoney": 0.0
                      });
                    },
                  ),
                ],
              )
          )
      );
      _imHelper.updateReceiveRedPacket(content, timeline_id);
    }
    else if(redPacketModel.currentnum != redPacketModel.redpacketnum) {
      redInfo.add(
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(top: 30),
              alignment: Alignment.center,
              child: Image(
                image: AssetImage("images/openredpacket.png",),
                fit: BoxFit.cover,
                width: 59,
                height: 59,
              ),
            ),
            onTap: () async {
              if(Global.profile.user!.aliuserid == ""){
                ShowMessage.showToast("请先设置支付宝账号,再来领哦");
                return;
              }
              ShowMessage.showCenterToast("开启中...");
              double receiveMoney = await _imService.receiveRedPacket(
                  Global.profile.user!.uid, Global.profile.user!.token!,
                  redPacketModel.redpacketid, (code, msg) {
                ShowMessage.cancel();
                ShowMessage.showToast(msg);
              });
              if (receiveMoney != null && receiveMoney > 0) {
                String temstr = "";
                if (redPacketModel.uid == Global.profile.user!.uid) {
                  temstr = "@|你领取了自己发的红包";
                }
                else {
                  temstr = "@|你领取了${redPacketModel.username}发的红包";
                }
                ShowMessage.cancel();
                //成功领取进入红包列表页面
                await _sendDrawRedPacket(content, temstr);

                Navigator.pop(context);
                Navigator.pushNamed(context, '/RedPacketList', arguments: {
                  "redPacketModel": redPacketModel,
                  "receiveMoney": receiveMoney
                }).then((value){
                  setState(() {

                  });
                });
                //print("领取成功");
              }
              else {
                Navigator.pop(context);
                _imHelper.updateReceiveRedPacket(content, timeline_id);
              }
            },
          )
      );
    }
    else{
      redInfo.add(
          Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text('红包已经被抢光啦',  style: TextStyle(decoration: TextDecoration.none,  fontWeight: FontWeight.w500,
                      fontSize: 16, color: Colors.white)),
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text('看看大家的手气',  style: TextStyle(decoration: TextDecoration.none,  fontWeight: FontWeight.w500,
                          fontSize: 13, color: Color(0xfff0e68c)),),
                    ),
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/RedPacketList', arguments: {
                        "redPacketModel": redPacketModel,
                        "receiveMoney": 0.0
                      });
                    },
                  ),
                ],
              )
          )
      );
      _imHelper.updateReceiveRedPacket(content, timeline_id);
    }
    return redInfo;
  }

  void insertText(String text) {
    final TextEditingValue value = _textEditingController.value;
    final int start = value.selection.baseOffset;
    int end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      _textEditingController.value = value.copyWith(
          text: newText,
          selection: value.selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      _textEditingController.value = TextEditingValue(
          text: text,
          selection:
          TextSelection.fromPosition(TextPosition(offset: text.length)));
    }
  }

  void update(Function change) {
    if (showCustomKeyBoard) {
      change();
      if(!showCustomKeyBoard)
        SystemChannels.textInput
            .invokeMethod<void>('TextInput.show')
            .whenComplete(() {
          Future<void>.delayed(const Duration(milliseconds: 200))
              .whenComplete(() {});
        });
    }
    else {
      SystemChannels.textInput
          .invokeMethod<void>('TextInput.hide')
          .whenComplete(() {
        Future<void>.delayed(const Duration(milliseconds: 200))
            .whenComplete(() {
          change();
        });
      });
    }
  }

  Future<void> recoderDel() async {
    await stopPlayer();
    setState(() {
      _recordercomplete = false;
      _currentTime = 0;
      _showTime = 0;
    });
  }

  Future<void> soundLoadAndPaly( TimeLineSync timeLineSync) async {
    File soundFile;
    if(Global.isInDebugMode)
      print(timeLineSync.contenttype);
    if(timeLineSync.contenttype == ContentType.Type_Sound.index){
      if(timeLineSync.localpath!.isNotEmpty && _recorder.isStopped ) {
        timeLineSync.isplay = true;
        soundFile = File(timeLineSync.localpath!);
        if(await soundFile.exists() ) {
          await stopPlayer();
          startPlayer(soundFile.path, timeLineSync: timeLineSync);
        }
        else{
          await fileSave(timeLineSync);
          soundFile = File(timeLineSync.localpath!);
          if(await soundFile.exists()) {
            await stopPlayer();
            startPlayer(soundFile.path, timeLineSync: timeLineSync);
          }
        }
      }
      else{
        if(_recorder.isStopped) {
          timeLineSync.isplay = true;
          await fileSave(timeLineSync);
          soundFile = File(timeLineSync.localpath!);
          if (await soundFile.exists()) {
            await stopPlayer();
            startPlayer(soundFile.path, timeLineSync: timeLineSync);
          }
        }
      }
    }
  }

  Future<void> fileSave(TimeLineSync timeLineSync) async {
    String url = timeLineSync.content!.replaceAll('|sound: ', '').replaceAll('|', '').split('#')[1];
    Directory directory = await getTemporaryDirectory();

    Directory soundsDirectory = await new Directory('${directory.path}/im/sounds/').create(recursive: true);
    String localPath = soundsDirectory.path;
    localPath = localPath + DateTime.now().millisecondsSinceEpoch.toString() + ".mp4";
    await NetUtil.getInstance().download(url, localPath,  (){
      ShowMessage.showToast('文件不存在');
    },() async {
      timeLineSync.localpath = localPath;
      await _imHelper.saveSoundFile(timeLineSync);
//      await audioPlayer.play(localPath, isLocal: true);
    });
  }
  
  Future<String> findLocalPath() async { //这里根据平台获取当前安装目录
    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  Future<void> loadAssets() async {
    User _user = Global.profile.user!;
    List<AssetEntity>? resultList;

    try {
      resultList = await AssetPicker.pickAssets(
        context,
        maxAssets: 4,
        selectedAssets: _images,
        requestType: RequestType.image,
      );
    } on Exception catch (e) {
      print(e.toString());
    }
    //添加图片并上传oss 1.申请oss临时token，1000s后过期
    if(resultList != null && resultList.length != 0) {
      _securityToken = await _aliyunService.getActivitySecurityToken(_user.token!, _user.uid);
      if (_securityToken != null) {
        for (int i = 0; i < resultList.length; i++) {
          int width = resultList[i].orientatedWidth;
          int height = resultList[i].orientatedWidth;

          String url = await CommonUtil.upLoadImage((await resultList[i].file)!, _securityToken!, _aliyunService);
          if (url != null && url.isNotEmpty) {
            _sendImg( _securityToken!.host + "/" + url, "${width},${height}", url);
          }
        }
        _images = [];

        if (!mounted) return;
        setState(() {
        });
      }
    }
  }

  Future<void> pickImage() async{
    User _user = Global.profile.user!;
    final pickedFile = await _picker.getImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );

    if(pickedFile != null) {
      _securityToken = await _aliyunService.getActivitySecurityToken(_user.token!, _user.uid);
      if (_securityToken != null) {
        Uint8List imageData =  await pickedFile.readAsBytes();
        String md5name = md5.convert(imageData).toString();
        final Directory _directory = await getTemporaryDirectory();
        final Directory _imageDirectory = await new Directory('${_directory.path}/activity/images/').create(recursive: true);
        String _path = _imageDirectory.path;
        File imageFile = new File('${_path}originalImage_$md5name.png')..writeAsBytesSync(imageData);
        Image image = Image.file(File(pickedFile.path));
        image.image.resolve(new ImageConfiguration()).addListener(
            new ImageStreamListener((ImageInfo info, bool _) async {
              String url = await _aliyunService.uploadImage(_securityToken!, imageFile.path, '${md5name}.png', _user.uid);
              if (url != null && url.isNotEmpty) {
                _sendImg(_securityToken!.host + "/" + url,  "${info.image.width},${info.image.height}", url);
              }
            })
        );
      }
    }
  }

  ///定位图片，位置名称
  Future<void> locationImage(Uint8List imgData, String address, String title, String latitude, String longitude) async{

    User _user = Global.profile.user!;
    _securityToken = await _aliyunService.getActivitySecurityToken(_user.token!, _user.uid);

    if (_securityToken != null) {
      String md5name = Uuid().v1().toString().replaceAll('-', '');
      final Directory _directory = await getTemporaryDirectory();
      final Directory _imageDirectory = await new Directory('${_directory.path}/activity/images/').create(recursive: true);
      String _path = _imageDirectory.path;

      File imageFile = new File('${_path}originalImage_$md5name.png')..writeAsBytesSync(imgData);
      Image image = Image.memory(imgData);
      image.image.resolve(new ImageConfiguration()).addListener(
          new ImageStreamListener((ImageInfo info, bool _) async {
            String url = await _aliyunService.uploadImage(_securityToken!, imageFile.path, '${md5name}.png', _user.uid);
            if (url != null && url.isNotEmpty) {
              _sendLocal(url, "${info.image.width},${info.image.height}",address, title, longitude, latitude, _securityToken!.host + "/" + url);
            }
          })
      );
    }
  }

  selectMember() async {
    List<User>? users = await _imHelper.getGroupMemberRelation(_groupRelation.timeline_id);
    if(users == null || users.length == 0){
      return;
    }
    ///编辑控制器
    TextEditingController _controller = TextEditingController();
    print(_pagestatus);
    ///是否显示删除按钮
    bool _hasDeleteIcon = false;
    List<User> newArr=users;
    showModalBottomSheet<String>(
        isScrollControlled: true,  //一：设为true，此时为全屏展示
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState){
              return Container(
                  padding: EdgeInsets.only(left: 5, right: 5, top: _pagestatus + 10, bottom: 10),
                  color: Colors.white,
                  child: InkWell(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.arrow_drop_down
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Text('选择提醒的人', style: TextStyle(fontSize: 16),),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 5, top: 10),
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.search,
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                            cursorColor: Colors.cyan,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              //输入框decoration属性
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 1.0),
                              //设置搜索图片
                              prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Icon(Icons.search, color: Colors.black45, size: 19,)
                              ),
                              prefixIconConstraints: BoxConstraints(
                                //设置搜索图片左对齐
                                minWidth: 30,
                                minHeight: 25,
                              ),
                              border: InputBorder.none,
                              //无边框
                              hintText: " 搜索",
                              hintStyle: new TextStyle(
                                  fontSize: 14, color: Colors.grey),
                              //设置清除按钮
                              suffixIcon: Container(
                                padding: EdgeInsetsDirectional.only(
                                  start: 2.0,
                                  end: _hasDeleteIcon ? 0.0 : 0,
                                ),
                                child: _hasDeleteIcon
                                    ? new InkWell(
                                  onTap: (() {
                                    setState(() {
                                      /// 保证在组件build的第一帧时才去触发取消清空内容
                                      _controller.clear();
                                      _hasDeleteIcon = false;
                                    });
                                  }),
                                  child: Icon(
                                    Icons.cancel,
                                    size: 18.0,
                                    color: Colors.grey,
                                  ),
                                )
                                    : new Text(''),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                _hasDeleteIcon = false;
                              } else {
                                _hasDeleteIcon = true;
                              }


                              newArr = users.where((input)=> (input.username.indexOf(value) >= 0 ? true:false)).toList();
                              setState(() {

                              });
                            },
                            onEditingComplete: () {

                            },
                            style: new TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                              children: buildMemberList(newArr)
                          ),
                        )
                      ],
                    ),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  )
              );
            },
          );
        }
    ).then((value)  {
      if(value != null){
        _textEditingController.text = _textEditingController.text + value + " ";
      }
    });

  }

  List<Widget> buildMemberList(List<User> members){
    List<Widget> widgets = [];

    widgets.add(SizedBox(height: 10,));
    members.forEach((element) {
      widgets.add(
          Padding(
            padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
            child: ListTile(
              onTap: () {
                Navigator.pop(context, element.username);
              },
              title: Padding(
                padding: EdgeInsets.only(top: 5,bottom: 3),
                child: Text(element.username, style: TextStyle(color: Colors.black87, fontSize: 14),),
              ),
              leading: NoCacheClipRRectOhterHeadImage(
                imageUrl: element.profilepicture == null ? Global.profile
                    .profilePicture! : element.profilepicture!, width: 50, uid: element.uid,),
            ),
          )
      );
      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: 70, right: 0, top: 0, bottom: 5),
          child: MyDivider(),
        )
      );
      widgets.add(SizedBox(height: 5,));
    });
    return widgets;
  }

  //goodprice分享
  Future<void> _gotoGoodPrice(String goodpriceid) async {
    GPService gpservice = new GPService();
    GoodPiceModel? goodprice = await gpservice.getGoodPriceInfo(goodpriceid);
    if (goodprice != null) {
      Navigator.pushNamed(
          context, '/GoodPriceInfo', arguments: {
        "goodprice": goodprice
      });
    }
  }
  //验证是否已经离开群聊
  Future<bool> _isQuitActivity() async {
    GroupRelation? temGroupRelation = await _imHelper.getGroupRelationByGroupid(Global.profile.user!.uid, _groupRelation.timeline_id);
    if(temGroupRelation != null && temGroupRelation.isnotservice == 1){
      ShowMessage.showToast("你已离开群聊，无法发送消息！如果你想重新加入请先删除群聊。");
      return true;
    }
    return false;
  }

  loadingBlockPuzzle(BuildContext context, {barrierDismissible = true}) {
    showDialog<Null>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return BlockPuzzleCaptchaPage(
          onSuccess: (v){
            sendMessage(this._msgcontent, this._contenttype, this._localmsgcontent, this._localpath, v);
          },
          onFail: (){

          },
        );
      },
    );
  }

  errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}



