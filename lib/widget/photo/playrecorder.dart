import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../../global.dart';
import '../../common/iconfont.dart';
import '../../model/aliyun/securitytoken.dart';
import '../../model/im/timelinesync.dart';
import '../../service/aliyun.dart';
import '../../util/showmessage_util.dart';

import 'soundcircleprocess.dart';

class PlayRecorder extends StatefulWidget {
  @override
  _PlayRecorderState createState() => _PlayRecorderState();
}

class _PlayRecorderState extends State<PlayRecorder> {
  bool _recordercomplete = false;//是否录制完成，//是否在录音中，注意：不要用recorderModule中的isrecordering等判断状态，因为所有event都在一个按钮上无法判断实时状态
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  StreamSubscription? _playerSubscription;

  late AudioSession _audioSession;
  String _recordFilepath = "";
  Timer? _recordtimer;
  double _isPercent = 0;
  int _tem = 0;//播放的临时变量
  int _soundTime = 60;//录音时长60秒；
  int _showTime =0 ;//显示录音时间
  int _currentTime = 0;//已录音时间；
  Directory? tempDir;


  Future<void> startRecorder() async {
    try {
      _audioSession.setActive(true);
      String uuid = Uuid().v1().toString().replaceAll('-', '');
      _recordFilepath = '${tempDir!.path}/${uuid}.mp4';

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
          stopRecorder();
        }
        _currentTime++;
        _showTime = _currentTime;
        setState(() {

        });
      });
    } catch (err) {
      print('startRecorder error: $err');
      setState(() {
        stopRecorder();
      });
    }
  }

  Future<void> stopRecorder() async {
    try {
      await _recorder.stopRecorder().then((value) {
        setState(() {
          //var url = value;
          _recordercomplete = true;
        });
      });
      _audioSession.setActive(false);
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
      // await flutterSoundModule.setVolume(1.0);
    } catch (err) {
      print('error: $err');
    }
  }

  Future<void> stopPlayer() async {
    try {
      await _player.stopPlayer().then((value) {
        setState(() {
          _showTime = _currentTime;
        });
      });
    } catch (err) {
      print('error: $err');
    }
  }

  Future<void> init() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage
    ].request();


    if (statuses[Permission.microphone] != PermissionStatus.granted || statuses[Permission.storage] != PermissionStatus.granted) {
      ShowMessage.showToast("需要麦克风语音存储权限");
      await openAppSettings();
      Navigator.pop(context);
    }

    if (statuses[Permission.microphone]  == PermissionStatus.granted) {
      AudioSession.instance.then((audioSession) async {
        await audioSession.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.media,
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

  Future<void> _initializeRecorderExample() async {
    await _recorder.openRecorder();
    tempDir = await getTemporaryDirectory();
  }

  Future<void> _initializePlayExample() async {
    //录音按钮播放倒计时
    await _player.openPlayer().then((value) {
      setState(() {
      });
    });
    await _player.setSubscriptionDuration(Duration(seconds: 1));

    _playerSubscription = _player.onProgress!.listen((e) {
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
    });
  }

  @override
  initState() {
    init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _recorder.closeRecorder();
    _player.closePlayer();


    if (_playerSubscription != null) {
      _playerSubscription!.cancel();
      _playerSubscription = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSayGrid();
  }

  Widget buildSayGrid(){
    return Container(
      height: 260,
      child: Row(
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
                    child: _recordercomplete ? (_player.isPlaying ? SpinKitWave(color: Colors.cyan, type: SpinKitWaveType.center, size: 30,): Container(
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
              String ret = await updateSend();
              if(ret != "") {
                if(mounted)
                  Navigator.pop(context, ret);
              }
            },
          ):SizedBox.shrink()
        ],
      ),
    );
  }

  Future<void> recoderDel() async {
    await stopPlayer();
    setState(() {
      _recordercomplete = false;
      _currentTime = 0;
      _showTime = 0;
    });
  }

  Future<String> updateSend() async {
    String ret = "";
    AliyunService _aliyunService = new AliyunService();
    SecurityToken? securityToken = await _aliyunService.getSoundSecurityToken(Global.profile.user!.token!, Global.profile.user!.uid);
    if (securityToken != null) {
      //这边把类型加入
      String soundUrl = await _aliyunService.uploadSound(
          securityToken, _recordFilepath,
          md5.convert(_recordFilepath.codeUnits).toString() + ".mp4",
          Global.profile.user!.uid);
      if (soundUrl != null) {
        return soundUrl + "," + _currentTime.toString();
      }
    }

    return ret;
  }
}
