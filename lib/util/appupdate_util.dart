

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_app/util/showmessage_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class AppupdateUtil {

  static ReceivePort _port = ReceivePort();
  static int _downloaderrowcount = 0;//下载失败尝试次数
  static _TaskInfo _downloadinfo = new _TaskInfo();

  static launcherApp (String appurl) async {
    if (Platform.isAndroid) {
      //直接下载更新
      if(_downloaderrowcount == 0) {
        await FlutterDownloader.initialize(
          //表示是否在控制台显示调试信息
          debug: true,
        );
      }

      if (await _checkPermissionStorage()) {
        bool isSuccess = IsolateNameServer.registerPortWithName(
            _port.sendPort, 'flutter_mycommunity_app');
        if (!isSuccess) {
          if(_downloaderrowcount > 2){
            ShowMessage.showToast("下载更新包失败");
            return;
          }
          _downloaderrowcount++;
          _unbindBackgroundIsolate();
          launcherApp(appurl);
          return;
        }

        if(_downloaderrowcount == 0) {
          _port.listen((dynamic data) {
            print('UI Isolate Callback: $data');
            String taskId = data[0];
            DownloadTaskStatus status = data[1];
            int progress = data[2];

            if (_downloadinfo.taskId == taskId) {
              if (status == DownloadTaskStatus.undefined) {
                _startDownload(appurl);
              }
              else if (status == DownloadTaskStatus.complete) {
                print(" DownloadTaskStatus.complete");
                _delete(taskId);
              }
              else if (status == DownloadTaskStatus.paused) {
                _resumeDownload(taskId);
              }
              else if (status == DownloadTaskStatus.failed) {
                _retryDownload(taskId);
              }
            }


            print("status: $status");
            print("progress: $progress");
          });
        }
        FlutterDownloader.registerCallback(downloadCallback);


        final tasks = await FlutterDownloader.loadTasks();
        _downloadinfo.name = "android_apk";
        _downloadinfo.link = appurl;

        if(tasks != null && tasks.length > 0) {
          tasks.forEach((task) async {
            if (_downloadinfo.link == task.url) {
              await FlutterDownloader.remove(
                  taskId: task.taskId, shouldDeleteContent: true);
              _unbindBackgroundIsolate();
              _downloaderrowcount++;
              launcherApp(appurl);
            }
          });
        }
        else{
          _startDownload(appurl);
        }
      }
    } else if (Platform.isIOS) {
      //ios跳转appstore更新
      if (await canLaunch(appurl)) {
        await launch(appurl);
      } else {
        ShowMessage.showToast(
          "安装文件不存在，请去苹果商店更新",
        );
      }
    }
  }

  static Future<bool> _checkPermissionStorage() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  static Future _startDownload(String link) async {
    _downloadinfo.taskId = await FlutterDownloader.enqueue(
      url: link,
      savedDir: await _findLocalPath(),
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  static Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    String localPath = directory!.path + '/Download';
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return localPath;
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort? send = IsolateNameServer.lookupPortByName('flutter_mycommunity_app');
    if(send != null)
      send.send([id, status, progress]);
  }

  static void _delete(taskId) async {
    print("delete ----------------------------------------------------------");
    Timer(Duration(seconds: 3), () async {
      await FlutterDownloader.open(taskId: taskId);
      //await OpenFile.open(path);
      await FlutterDownloader.remove(
          taskId: taskId, shouldDeleteContent: false);
    });

    print("delete11 ----------------------------------------------------------");
  }

  static void _resumeDownload(String taskId) async {
    String? newTaskId = await FlutterDownloader.resume(taskId: taskId);
    _downloadinfo.taskId = newTaskId;
  }

  static void _retryDownload(String taskId) async {

    String? newTaskId = await FlutterDownloader.retry(taskId: taskId);
    _downloadinfo.taskId = newTaskId;
  }

  static void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('flutter_mycommunity_app');
  }

  static void dispose(){
    if(_downloadinfo.taskId != null && _downloadinfo.taskId != "") {
      FlutterDownloader.remove(
          taskId: _downloadinfo.taskId!, shouldDeleteContent: true);
      _unbindBackgroundIsolate();
    }
  }

}

class _TaskInfo {
  String? name;
  String? link;

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

