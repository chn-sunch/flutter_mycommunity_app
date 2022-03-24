import 'dart:io';

import 'package:dio/dio.dart';
import 'dart:collection';

import '../../global.dart';

///http请求
class HttpManager {
  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";
  static Map<String, String> optionParams = {
    "mirrorToken": "",
    "content-Type": CONTENT_TYPE_JSON
  };
  //请求base url
  //static String baseUrl = "http://10.108.11.46:8080/api";
  //static String baseUrl = "https://captcha.anji-plus.com/captcha-api";

  ///发起网络请求
  ///[ url] 请求url
  ///[ param] 请求参数
  ///[ header] 外加头
  ///[ isNeedToken] 是否需要token
  ///[ optionMetod] 请求类型 post、get
  ///[ noTip] 是否需要返回错误信息 默认不需要
  ///[ needSign] 是否需要Sign校验  默认需要
  ///[ needError] 是否需要错误提示
  static requestData(url, param, Map<String, String> header,
      {bool isNeedToken = true,
        String optionMetod = "post",
        noTip = false,
        needSign = true,
        needError = true}) async {
    ///初始化请求类
    Dio dio = new Dio();

    ///头部
    Map<String, String> headers = new HashMap();
    if (header != null) {
      headers.addAll(header);
    }

    //请求协议 post 、get
    Options option = new Options(method: optionMetod);

    ///设置头部
    if (option != null) {
      option.headers = headers;
    }

    option.sendTimeout = 15000;

    //获取token
    var mirrorToken = "";


    var params = param;
//    if (needSign) {
//      //获取加密的请求参数
//      params = await SignConfig.signData(param, mirrorToken);
//    }

    Response? response;
    //print("$baseUrl$url");
    //print(params);

    try {
      ///开始请求
      response = await dio.request("${Global.serviceurl}$url", data: params, options: option);
    } on DioError catch (e) {

      ///请求失败处理
      if (needError) {
        return e;
      }
    }


    try {
      var responseJson = response!.data;
      print(responseJson);

      if (response.statusCode == 200) {
        ///请求链接成功
        return responseJson;
      }
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

}
