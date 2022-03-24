
import 'package:dio/dio.dart';
import 'showmessage_util.dart';
import '../global.dart';


class NetUtil {
  Dio? _dio;
  static NetUtil _instance = NetUtil._internal();
  factory NetUtil() => _instance;
  ///通用全局单例，第一次使用时初始化
  NetUtil._internal() {
    if (null == _dio) {
      _dio = new Dio(
          new BaseOptions(baseUrl:  Global.serviceurl, connectTimeout: 5000, receiveTimeout: 3000));
    }
  }

  static NetUtil getInstance({String? baseUrl}) {
    if (baseUrl == null) {
      return _instance._normal();
    } else {
      return _instance._baseUrl(baseUrl);
    }
  }

  //一般请求，默认域名
  NetUtil _normal() {
    if (_dio != null) {
      if (_dio!.options.baseUrl != Global.serviceurl) {
        _dio!.options.baseUrl = Global.serviceurl;
      }
    }
    return this;
  }

  NetUtil _baseUrl(String baseUrl) {
    if (_dio != null) {
      _dio!.options.baseUrl = baseUrl;
    }
    return this;
  }


  Future<void> download(String url, String filepath, Function errorCallBack, Function callBack) async {
    Response responce = await _dio!.download(url, filepath);
    if(responce.statusCode == 200){
      callBack();
    }
    else{
      errorCallBack();
    }
  }

  ///get请求
  Future<void> get(String url, Function callBack,
      {Map<String, String>? params, Function? errorCallBack}) async {
    Response response;
    try {
      response = await _dio!.get(url, queryParameters: params);
    } on DioError catch (e) {
      return resultError(e);
    }

    if(response.statusCode == 200) {
      if (response.data["status"] != null) {
        if (response.data["status"] < 0) {
          if (errorCallBack != null) {
            errorCallBack(response.data["status"].toString(), response.data["msg"].toString());
          }
          return;
        }
        else {
          if (callBack != null) {
            ///print("<net> response data:" + response.data["data"].runtimeType == "_InternalLinkedHashMap<int, String>");
            callBack(response.data);
          }
        }
      }
      else{
        callBack(response.data);
      }
    }
  }

  post(FormData formData, String api, Function callBack, Function errorCallBack, {bool isloginOut = false}) async {
    Response response;
    try {
      response = await _dio!.post(api, data: formData);
    } on DioError catch (e) {
      return resultError(e);
    }

    if (response.data["status"] < 0) {
      ///token过期
      if(response.data["status"] == -9006) {
        if(!isloginOut) {
          _handError(errorCallBack, response);
          Global.navigatorKey.currentState!.pushNamed('/Login');
        }
      }
      else {
        if (errorCallBack != null) {
          //print("<net> response data:" + response.data["data"].runtimeType == "_InternalLinkedHashMap<int, String>");
          _handError(errorCallBack, response);
        }
      }
    }
    else {
      if (callBack != null) {
        //print("<net> response data:" + response.data["data"].runtimeType == "_InternalLinkedHashMap<int, String>");
        callBack(response.data);
      }
    }
  }

  ///外网的网络请求
  Future<void> wget(String url, Function callBack,
      {Map<String, String>? params, Function? errorCallBack}) async {
    Response response;
    try {
      response = await _dio!.get(url, queryParameters: params);
    } on DioError catch (e) {
      return resultError(e);
    }

    if(response.statusCode == 200) {
      if(response.data["status"] == "1")
        callBack(response.data["pois"]);
    }
  }


  static Future<void> aliyunOSSpost(FormData formData ,  String url, Function callBack, Function errorCallBack) async {
    Response response;
    BaseOptions options = new BaseOptions();
    options.responseType = ResponseType.plain;
    options.contentType = "application/x-png";
    response = await Dio(options).post(url, data: formData);

    if (response.statusCode != 200) {
      errorCallBack(response.statusCode, response.statusMessage);
    }
    else {
      if (callBack != null) {
        //print("<net> response data:" + response.data["data"].runtimeType == "_InternalLinkedHashMap<int, String>");
        callBack(response.data);
      }
    }
  }

  //处理异常
  static void _handError(Function errorCallback, Response response) {
    if (errorCallback != null) {
      errorCallback(response.data["status"].toString(), response.data["msg"].toString());
    }
    //print("<net> errorMsg :" + response.data["msg"]);
  }

  resultError(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        ShowMessage.showToast("请求取消!");
        break;
      case DioErrorType.connectTimeout:
        ShowMessage.showToast("连接超时!");

        break;
      case DioErrorType.sendTimeout:
        ShowMessage.showToast("请求超时!");

        break;
      case DioErrorType.receiveTimeout:
        ShowMessage.showToast("响应超时!");
        break;

      default:
        if (error.message.contains("Network is unreachable")) {
          ShowMessage.showToast("网络不给力，请再试一下!");
        } else {
          ShowMessage.showToast("网络不给力，请再试一下!");
        }
    }
  }
}
