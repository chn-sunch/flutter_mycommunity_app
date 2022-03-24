import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_app/service/aliyun.dart';
import '../../global.dart';
import '../../common/json/interest_json.dart';
import '../../common/json/city_json.dart';
import '../../model/aliyun/securitytoken.dart';

import 'dart:convert' as convert;

class  CommonUtil{
  static final num ONE_MINUTE = 60000;
  static final num ONE_HOUR = 3600000;
  static final num ONE_DAY = 86400000;
  static final num ONE_WEEK = 604800000;

  static final String ONE_SECOND_AGO = "秒前";
  static final String ONE_MINUTE_AGO = "分钟前";
  static final String ONE_HOUR_AGO = "小时前";
  static final String ONE_DAY_AGO = "天前";
  static final String ONE_MONTH_AGO = "月前";
  static final String ONE_YEAR_AGO = "年前";
  static double EARTH_RADIUS = 6378.137;// 单位千米
  //根据年龄计算年龄段，80后，80后
  static String getAgeGroup(String birthday){
    double year = double.parse(birthday.substring(0, 4).toString());
    return (((year/10)%10)).toString().split('.')[0].toString() + '0后';
  }
  static String getAgeGroupByYear(int year){
    return year.toString().substring(year.toString().length - 2, year.toString().length);
  }
  //根据出生日期计算星座
  static String getConstellation(String birthday) {
    int monthday = int.parse(birthday.substring(5, 7).toString()) * 100;
    monthday = monthday + int.parse(birthday.substring(8, 10).toString());
    int month = (monthday / 100).toInt();
    int day = monthday % 100;
    String constellation = "";
    switch (month) {
      case 1:
        constellation = day < 21 ? "摩羯座" : "水瓶座";
        break;
      case 2:
        constellation = day < 20 ? "水瓶座" : "双鱼座";
        break;
      case 3:
        constellation = day < 21 ? "双鱼座" : "白羊座";
        break;
      case 4:
        constellation = day < 21 ? "白羊座" : "金牛座";
        break;
      case 5:
        constellation = day < 22 ? "金牛座" : "双子座";
        break;
      case 6:
        constellation = day < 22 ? "双子座" : "巨蟹座";
        break;
      case 7:
        constellation = day < 23 ? "巨蟹座" : "狮子座";
        break;
      case 8:
        constellation = day < 24 ? "狮子座" : "处女座";
        break;
      case 9:
        constellation = day < 24 ? "处女座" : "天秤座";
        break;
      case 10:
        constellation = day < 24 ? "天秤座" : "天蝎座";
        break;
      case 11:
        constellation = day < 23 ? "天蝎座" : "射手座";
        break;
      case 12:
        constellation = day < 22 ? "射手座" : "摩羯座";
        break;
    }
    return constellation;
  }

  //获取城市名称
  static String getInterest(String interests){
    List<String> interestlist = interests.split(",");
    String interestNames = "";

    interestlist.forEach((element) {
      if(interestData[element] != null)
        interestNames += interestData[element]! + ",";
    });
    if(interestNames != "")
      interestNames = interestNames.substring(0, interestNames.length - 1);
    return interestNames;
  }
  //获取城市名称
  static String getCityName(province, city){
    Map<String, dynamic> mycity = citiesData[province];
    return  mycity[city]["name"];
  }

  //获取省份和城市
  static String getProvinceCityName(province, city){
    Map<String, dynamic> mycity = citiesData[province];
    return  provincesData[province]! + mycity[city]["name"];
  }
  //获取城市名称，高德地图的adCode
  static String getCityNameByGaoDe(String adcode){
    adcode = adcode.substring(0, 4) + "00";
    return  adcode;
  }

  //计算数字超过万显示X万
  static String getNum(int num){
    String ret = num.toString();
    if(num >= 10000){
      double count = num/10000;
      ret = count.toStringAsFixed(1) + '万';
    }

    return ret;
  }

  //显示时间yyyy-mm-dd hh:mm:ss
  static String getTime(){
    DateTime today = DateTime.now();
    return today.toString().substring(0, 19);
    //return '${today.year}-${today.month}-${today.day} ${today.hour}:${today.minute}:${today.second}';
  }
  //显示指定时间
  static String getCustomTime(DateTime today ){
    return today.toString().substring(0, 19);
    //return '${today.year}-${today.month}-${today.day} ${today.hour}:${today.minute}:${today.second}';
  }
  //10进制转16进制
  static String intToHex(int n){
    String ret = "";
    List<String> s = [];
    List<String> r;
    int hex = 16;
    List<String> b = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
    while(n != 0){
      s.add(b[n%16]);
      n = n~/hex;
    }
    r = s.reversed.toList();
    if (r.length<2) {
      r.insert(0, "0");
    }
    r.forEach((v){ret += v;});
    return ret;
  }
  //计算两个坐标的直线距离
  static double getRadian(double degree) {
    return degree * math.pi / 180.0;
  }
  //返回m
  static double getDistance(double lat1, double lng1, double lat2, double lng2) {
    double radLat1 = getRadian(lat1);
    double radLat2 = getRadian(lat2);
    double a = radLat1 - radLat2;// 两点纬度差
    double b = getRadian(lng1) - getRadian(lng2);// 两点的经度差
    double s = 2 * math.asin(math.sqrt(math.pow(math.sin(a / 2), 2) + math.cos(radLat1)
        * math.cos(radLat2) * math.pow(math.sin(b / 2), 2)));
    s = s * EARTH_RADIUS;
    return s * 1000;
  }

  static Widget getTextDistance(double? lat1, double? lng1, double? lat2, double? lng2){
    if(lat1 == null || lng1 == null || lat2 == null || lng2 == null){
      return SizedBox.shrink();
    }
    double dist = getDistance(lat1, lng1, lat2, lng2);
    if(dist > 100000){
      return SizedBox.shrink();
    }
    else{
      return Text('${(dist/1000).toStringAsFixed(2)}km', style: TextStyle(color: Colors.black54, fontSize: 11), overflow: TextOverflow.ellipsis,);
    }
  }

  //显示时间差分钟
  static int handleMinDate(String oldTime) {
    String nowTime = new DateTime.now().toString().split('.')[0];

    int nowyear = int.parse(nowTime.split(" ")[0].split('-')[0]);
    int nowmonth = int.parse(nowTime.split(" ")[0].split('-')[1]);
    int nowday = int.parse(nowTime.split(" ")[0].split('-')[2]);
    int nowhour = int.parse(nowTime.split(" ")[1].split(':')[0]);
    int nowmin = int.parse(nowTime.split(" ")[1].split(':')[1]);

    int oldyear = int.parse(oldTime.split(" ")[0].split('-')[0]);
    int oldmonth = int.parse(oldTime.split(" ")[0].split('-')[1]);
    int oldday = int.parse(oldTime.split(" ")[0].split('-')[2]);
    int oldhour = int.parse(oldTime.split(" ")[1].split(':')[0]);
    int oldmin = int.parse(oldTime.split(" ")[1].split(':')[1]);

    var now = new DateTime(nowyear, nowmonth, nowday, nowhour, nowmin);
    var old = new DateTime(oldyear, oldmonth, oldday, oldhour, oldmin);
    var difference = now.difference(old);

    return (difference.inMinutes);
    // if(difference.inDays > 1) {
    //   return (difference.inDays).toString() + '天前';
    // } else if(difference.inDays == 1) {
    //   return '昨天'.toString();
    // } else if(difference.inHours >= 1 && difference.inHours < 24) {
    //   return (difference.inHours).toString() + '小时前';
    // } else if(difference.inMinutes > 5 && difference.inMinutes < 60) {
    //   return (difference.inMinutes).toString() + '分钟前';
    // } else if(difference.inMinutes <= 5) {
    //   return '刚刚';
    // }
  }

  static Widget getWidgetDistance(double lat1, double lng1, double lat2, double lng2, String address){
    if(lat2 <= 0){
      return SizedBox.shrink();
    }
    double dist = getDistance(lat1, lng1, lat2, lng2);
    if(dist > 100){
      return SizedBox.shrink();
    }
    else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(address, overflow:TextOverflow.ellipsis,style: TextStyle(color: Colors.black54, fontSize: 13) ),
          ),
          lat1 != 0 && lat1 != 0 ? Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('${dist}km'
                ,style: TextStyle(color: Colors.black54, fontSize: 13), overflow: TextOverflow.ellipsis,),
            ),
          ): SizedBox.shrink()
        ],
      );
    }
  }

  ///value: 文本内容；fontSize : 文字的大小；fontWeight：文字权重；maxWidth：文本框的最大宽度；maxLines：文本支持最大多少行
  static double calculateTextHeight(
      String value, fontSize, FontWeight fontWeight, double maxWidth) {
    TextPainter painter = TextPainter(
      ///AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
        locale: Localizations.localeOf(Global.mainContext!),
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            )));
    painter.layout(maxWidth: maxWidth);
    ///文字的宽度:painter.width
    return painter.height;
  }

  static datetimeFormat(DateTime date) {
    num delta = DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
    if (delta < 1 * ONE_MINUTE) {
      num seconds = toSeconds(delta);
      return (seconds <= 0 ? 1 : seconds).toInt().toString() + ONE_SECOND_AGO;
    }
    else if (delta < 45 * ONE_MINUTE) {
      num minutes = toMinutes(delta);
      return (minutes <= 0 ? 1 : minutes).toInt().toString() + ONE_MINUTE_AGO;
    }
    else if (delta < 24 * ONE_HOUR) {
      num hours = toHours(delta);
      return (hours <= 0 ? 1 : hours).toInt().toString() + ONE_HOUR_AGO;
    }
    else if (delta < 48 * ONE_HOUR) {
       return "昨天";
    }
    else if (delta < 30 * ONE_DAY) {
        num days = toDays(delta);
        return (days <= 0 ? 1 : days).toInt().toString() + ONE_DAY_AGO;
    }
    else{
      return date.month.toString() + '月' + date.day.toString() + '日' ;
    }
    // else if (delta < 48 * ONE_HOUR) {
    //   return "昨天";
    // }
    // else if (delta < 30 * ONE_DAY) {
    //   num days = toDays(delta);
    //   return (days <= 0 ? 1 : days).toInt().toString() + ONE_DAY_AGO;
    // }
    // else if (delta < 12 * 4 * ONE_WEEK) {
    //   num months = toMonths(delta);
    //   return (months <= 0 ? 1 : months).toInt().toString() + ONE_MONTH_AGO;
    // } else {
    //   num years = toYears(delta);
    //   return (years <= 0 ? 1 : years).toInt().toString() + ONE_YEAR_AGO;
    // }
  }

  ///服务器发送的token把末尾的=号删除
  static String GetJsonString(String token){
    //token = token.split('.')[1].toString();
    int num = (4 - token.length % 4)%4;
    for (var i = 0; i < num; i++) {
      token += "=";
    }

    token.replaceAll('-', '+').replaceAll('_', '/');


    List<int> bytes = convert.base64.decode(token);


    return convert.utf8.decode(bytes).toString();
  }

  static datetimeMomentFormat(DateTime date) {
    num delta = DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
    if (delta < 1 * ONE_MINUTE) {
      num seconds = toSeconds(delta);
      return (seconds <= 0 ? 1 : seconds).toInt().toString() + ONE_SECOND_AGO;
    }
    else if (delta < 45 * ONE_MINUTE) {
      num minutes = toMinutes(delta);
      return (minutes <= 0 ? 1 : minutes).toInt().toString() + ONE_MINUTE_AGO;
    }
    else if (delta < 24 * ONE_HOUR) {
      num hours = toHours(delta);
      return (hours <= 0 ? 1 : hours).toInt().toString() + ONE_HOUR_AGO;
    }
    else{
      return date.month.toString() + '月' + date.day.toString() + '日' + ' ' + date.hour.toString() + ':' + date.minute.toString();
    }
    // else if (delta < 48 * ONE_HOUR) {
    //   return "昨天";
    // }
    // else if (delta < 30 * ONE_DAY) {
    //   num days = toDays(delta);
    //   return (days <= 0 ? 1 : days).toInt().toString() + ONE_DAY_AGO;
    // }
    // else if (delta < 12 * 4 * ONE_WEEK) {
    //   num months = toMonths(delta);
    //   return (months <= 0 ? 1 : months).toInt().toString() + ONE_MONTH_AGO;
    // } else {
    //   num years = toYears(delta);
    //   return (years <= 0 ? 1 : years).toInt().toString() + ONE_YEAR_AGO;
    // }
  }


  static num toSeconds(num date) {
    return date / 1000;
  }

  static num toMinutes(num date) {
    return toSeconds(date) / 60;
  }

  static num toHours(num date) {
    return toMinutes(date) / 60;
  }

  static num toDays(num date) {
    return toHours(date) / 24;
  }

  static num toMonths(num date) {
    return toDays(date) / 30;
  }

  static num toYears(num date) {
    return toMonths(date) / 365;
  }
  //图片压缩并上传阿里云oss 返回url
  static Future<String> upLoadImage(File file, SecurityToken securityToken, AliyunService aliyunService ) async {
    String ossurl = "";
    // Directory _directory = await getTemporaryDirectory();
    // Directory _imageDirectory = await new Directory('${_directory.path}/activity/images/').create(recursive: true);
    // File imageFile = new File('${_path}originalImage_$md5name.png')
    //   ..writeAsBytesSync(imageData);
    //          Image image = Image.file(imageFile, fit: BoxFit.cover, width: _pageWidth,);
    // ByteData byteData = (await resultList[i].getByteData(quality: 90));
    // if (byteData.lengthInBytes > 1024 * 1024) {
    //   width = (width / 2).floor();
    //   height = (height / 2).floor();
    // }
    Uint8List imageData = await (file).readAsBytes();
    String md5name = md5.convert(imageData).toString();
    ossurl = await aliyunService.uploadImage(securityToken, file.path, '${md5name}.png', Global.profile.user!.uid);
    return ossurl;
  }
}

class MoneyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // TODO: implement formatEditUpdate

    String newvalueText=newValue.text;

    if(newvalueText=="."){
      //第一个数为.
      newvalueText="0.";

    } else if(newvalueText.contains(".")){
      if(newvalueText.lastIndexOf(".")!=newvalueText.indexOf(".")){
        //输入了2个小数点
        newvalueText=  newvalueText.substring(0,newvalueText.lastIndexOf('.'));
      }else if(newvalueText.length-1-newvalueText.indexOf(".")>2){
        //输入了1个小数点 小数点后两位
        newvalueText=newvalueText.substring(0,newvalueText.indexOf(".")+3);
      }
    }

    return TextEditingValue(
      text: newvalueText,
      selection: new TextSelection.collapsed(offset: newvalueText.length),
    );
  }
}
