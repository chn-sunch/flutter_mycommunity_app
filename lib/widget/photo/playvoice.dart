import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../util/showmessage_util.dart';
import '../../util/net_util.dart';
import '../../common/iconfont.dart';
import '../spinkitwave.dart';

class PlayVoice extends StatefulWidget {
  String voice;
  String voiceurl = "";
  int time = 0;
  int temtime = 0;
  PlayVoice(this.voice){
    if(voice != null && voice != ""){
      this.voiceurl = voice.split(",")[0];
      this.time = int.parse(voice.split(",")[1]);
      temtime = this.time;
    }
  }

  @override
  _PlayVoiceState createState() => _PlayVoiceState();
}

class _PlayVoiceState extends State<PlayVoice> {
  bool _isplaying = false;
  AudioPlayer _player = AudioPlayer();

  @override
  initState()  {
    // TODO: implement initState
    super.initState();
    _player.onAudioPositionChanged.listen((Duration  p){
      if(_isplaying) {
        if (widget.time != p.inSeconds) {
          setState(() {
            widget.temtime = widget.time -p.inSeconds;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 30,
        width: 110,
        padding: EdgeInsets.only(left: 6),
        child: Row(
          children: [
            Icon(_isplaying ? IconFont.icon_bofangzanting : IconFont.icon_bofangzanting1, color: Colors.white,),
            SizedBox(width: 10,),
            _isplaying ? MySpinKitWave(color: Colors.white, type: MySpinKitWaveType.center, size: 19, itemCount: 5,)
                : MySpinKitWaveStop(color: Colors.white, type: MySpinKitWaveType.center,  size: 19, itemCount: 5,),
            SizedBox(width: 10,),
            Text('${widget.temtime}s', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),)
          ],
        ),
        decoration: BoxDecoration(
          color: Colors.cyan,
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
      ),
      onTap: (){
        setState(() {
          _isplaying = !_isplaying;
          if(_isplaying){
            startPlayer(widget.voiceurl);
          }
          else{
            stopPlayer();
          }
        });
      },
    );
  }

  Future<void> fileSave(String voice) async {
    String url = voice.split(',')[0];
    String name = url.split('/')[url.split('/').length-1];
    Directory directory = await getTemporaryDirectory();
    Directory soundsDirectory = await new Directory('${directory.path}/im/sounds/').create(recursive: true);
    String localPath = soundsDirectory.path;
    localPath = localPath + name;
    File soundFile = File(localPath);

    if(await soundFile.exists()){
      _isplaying = true;
    }
    await NetUtil.getInstance().download(url, localPath,  (){
      ShowMessage.showToast('文件不存在');
    },() async {
      await _player.play(localPath, isLocal: true);
    });
  }

  Future<void> startPlayer(String filepath) async {
    try {
      widget.temtime = widget.time;
      _isplaying = true;
      _player.onPlayerCompletion.listen((event) {
        setState(() {
          _isplaying = false;
          widget.temtime = widget.time;
        });
      });
      // Check whether the user wants to use the audio player features
      await _player.play(filepath, isLocal: true);
      // await flutterSoundModule.setVolume(1.0);
    } catch (err) {
      print('error: $err');
    }
  }

  Future<void> stopPlayer() async {
    try {
      _isplaying = false;
      await _player.stop();
      widget.temtime = widget.time;
      setState(() {

      });
    } catch (err) {
      print('error: $err');
    }
  }

}
