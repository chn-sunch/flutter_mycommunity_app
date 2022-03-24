import 'package:dio/dio.dart';
import '../model/appinfo.dart';
import '../util/net_util.dart';
import '../util/showmessage_util.dart';

class CommonJSONService{
  ///活动标签
  Future<void> getActivityTypes(Function call) async {
    await NetUtil.getInstance().get("/Activity/getActivityTypeList", call, errorCallBack: errorResponse);
  }
  ///活动标签
  Future<void> getActivityTypesByName(Function call, String typename) async {
    FormData formData = FormData.fromMap({
      "typename": typename
    });
    await NetUtil.getInstance().post( formData,"/Activity/getActivityTypeListByTypeName",  call, errorResponse);
  }

  ///默认系统配置
  Future<void> getAppProfileConfig(Function call) async {
    await NetUtil.getInstance().get("/SysConfig/getConfigParameter",
         call, params: {"parameterkey": "userimgconfig"}, errorCallBack: errorResponse);
  }

  ///购买渠道参数
  Future<void> getPurchaseChannelsConfig(Function call) async {
    await NetUtil.getInstance().get("/SysConfig/getConfigParameter",
        call, params: {"parameterkey": "purchasechannels"}, errorCallBack: errorResponse);
  }

  ///消息举报内容分类
  Future<void> getMessagReportsConfig(Function call) async {
    await NetUtil.getInstance().get("/SysConfig/getConfigParameter",
        call, params: {"parameterkey": "messagreport"}, errorCallBack: errorResponse);
  }
  ///帮助中心内容
  Future<void> getSysHelpConfig(Function call) async {
    await NetUtil.getInstance().get("/SysConfig/getConfigParameter",
        call, params: {"parameterkey": "syshelp"}, errorCallBack: errorResponse);
  }
  ///获取当前版本号
  Future<AppInfo?> getSysVersionConfig() async {
    AppInfo? appInfo = null;
    await NetUtil.getInstance().get("/SysConfig/getAppversion",
            (Map<String, dynamic> data) {
          if (data["data"] != null) {
            appInfo = AppInfo.fromJson(data["data"]);
          }
        }, errorCallBack: errorResponse);

    return appInfo;
  }
  ///获取当前版本号及更新内容
  Future<void> getSysVersionAndContentConfig(Function call) async {
    await NetUtil.getInstance().get("/SysConfig/getConfigParameter",
        call, params: {"parameterkey": "appversionupdate"}, errorCallBack: errorResponse);
  }
  ///手机国家代码+86
  Future<void> getPhoneCode(Function call) async {
    await NetUtil.getInstance().get("/SysConfig/getFileContent",
        call, params: {"parameterkey": "phonecode"}, errorCallBack: errorResponse);  }

  ///获取登录用户协议
  Future<void> getHtmlContent(Function call, String parameterkey) async {
    await NetUtil.getInstance().get("/SysConfig/getFileContent",
        call, params: {"parameterkey": parameterkey}, errorCallBack: errorResponse);  }

  ///获取系统通知
  Future<void> getSysNotice(Function call) async {
    await NetUtil.getInstance().get("/SysConfig/getFileContent", call, params: {"parameterkey": "sysNotice"}, errorCallBack: errorResponse);
  }

  ///获取系统客服id, 分类
  Future<int> getSysCustomer(int categoryid, int uid, String token) async {
    int customeruid = 0;

    await NetUtil.getInstance().get("/SysConfig/getSysCustomer",(Map<String, dynamic> data){
      if (data["data"] != null) {
        customeruid = int.parse(data["data"]);
    }}, params: {"categoryid": categoryid.toString(), "uid": uid.toString(), "token": token}, errorCallBack: errorResponse);

    return customeruid;
  }

  ///高德定位搜索https://restapi.amap.com/v5/place/text?parameters
  Future<void> getAmapPoi(String location, String types, String region, bool citylimit, int page_size, int page_num, Function call) async {
    // await NetUtil.getInstance(baseUrl: "https://restapi.amap.com").wget("/v5/place/around", call,
    //     params: {"key": "39825835e128f68a89a8635dbcb9c2d2", "location": location, "types": types, "region": region, "citylimit": citylimit.toString(),
    //       "page_size": page_size.toString(), "page_num": page_num.toString()}
    //     , errorCallBack: errorResponse);

    await NetUtil.getInstance(baseUrl: "https://restapi.amap.com").wget("/v5/place/around", call,
        params: {"key": "39825835e128f68a89a8635dbcb9c2d2", "location": location, "types": types,
          "page_size": page_size.toString(), "page_num": page_num.toString()}
        , errorCallBack: errorResponse);
  }

  Future<void> getAmapWordKey(String keywords, String types, String region, bool citylimit, int page_size, int page_num, Function call) async {
    await NetUtil.getInstance(baseUrl: "https://restapi.amap.com").wget("/v5/place/text", call,
        params: {"key": "39825835e128f68a89a8635dbcb9c2d2", "keywords": keywords, "types": types, "region": region, "citylimit": citylimit.toString(),
          "page_size": page_size.toString(), "page_num": page_num.toString()}
        , errorCallBack: errorResponse);
  }

  errorResponse(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}