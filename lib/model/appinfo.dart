import 'dart:convert';

//使用Dart Data Class Generator插件进行创建
//使用命令: Generate from JSON
class AppInfo {
  final bool? iosUpdate;
  final bool? androidUpdate;
  final int? versionCode;
  final String? versionName;
  final String? updateLog;
  final String? apkUrl;
  final int? apkSize;

  AppInfo({
    this.iosUpdate,
    this.androidUpdate,
    this.versionCode,
    this.versionName,
    this.updateLog,
    this.apkUrl,
    this.apkSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'hasUpdate': iosUpdate,
      'isIgnorable': androidUpdate,
      'versionCode': versionCode,
      'versionName': versionName,
      'updateLog': updateLog,
      'apkUrl': apkUrl,
      'apkSize': apkSize,
    };
  }

  static AppInfo fromMap(Map<String, dynamic> map) {

    return AppInfo(
      iosUpdate: map['iosUpdate'],
      androidUpdate: map['androidUpdate'],
      versionCode: map['versionCode']?.toInt(),
      versionName: map['versionName'],
      updateLog: map['updateLog'],
      apkUrl: map['apkUrl'],
      apkSize: map['apkSize']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  static AppInfo fromJson(Map<String, dynamic> data) => fromMap(data);

  @override
  String toString() {
    return 'AppInfo iosUpdate: $iosUpdate, androidUpdate: $androidUpdate, versionCode: $versionCode, versionName: $versionName, updateLog: $updateLog, apkUrl: $apkUrl, apkSize: $apkSize';
  }
}