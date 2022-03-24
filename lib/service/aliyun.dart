

import 'package:dio/dio.dart';
import 'package:http_parser/src/media_type.dart';

import '../model/aliyun/securitytoken.dart';
import '../util/net_util.dart';
import '../util/showmessage_util.dart';

class AliyunService {

  //用户照片
  Future<SecurityToken?> getUserProfileSecurityToken(String token,  int uid) async {
    SecurityToken? securityToken;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid
    });
    await NetUtil.getInstance().post(formData, "/user/getUserProfileSecurityToken", (Map<String, dynamic> data) {
      securityToken = SecurityToken(data["data"]["ossAccessKeyId"], data["data"]["policy"], data["data"]["signature"], data["data"]["dir"], data["data"]["host"], data["data"]["expire"]);
    }, errorResponse);
    return securityToken;
  }
  //活动图片，评价图片等，长期缓存的图片
  Future<SecurityToken?> getActivitySecurityToken(String token,  int uid) async {
    SecurityToken? securityToken;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid
    });
    await NetUtil.getInstance().post(formData, "/Community/getActivitySecurityToken", (Map<String, dynamic> data) {
      securityToken = SecurityToken(data["data"]["ossAccessKeyId"], data["data"]["policy"], data["data"]["signature"], data["data"]["dir"], data["data"]["host"], data["data"]["expire"]);
    }, errorResponse);
    return securityToken;
  }
  //bug照片
  Future<SecurityToken?> getBugSecurityToken(String token, int uid) async {
    SecurityToken? securityToken;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid
    });
    await NetUtil.getInstance().post(formData, "/user/getBugSecurityToken", (Map<String, dynamic> data) {
      securityToken = SecurityToken(data["data"]["ossAccessKeyId"], data["data"]["policy"], data["data"]["signature"], data["data"]["dir"], data["data"]["host"], data["data"]["expire"]);
    }, errorResponse);
    return securityToken;
  }
  //moment照片
  Future<SecurityToken?> getMomentSecurityToken(String token, int uid) async {
    SecurityToken? securityToken;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid
    });
    await NetUtil.getInstance().post(formData, "/user/getMomentSecurityToken", (Map<String, dynamic> data) {
      securityToken = SecurityToken(data["data"]["ossAccessKeyId"], data["data"]["policy"], data["data"]["signature"], data["data"]["dir"], data["data"]["host"], data["data"]["expire"]);
    }, errorResponse);
    return securityToken;
  }


  //IM声音
  Future<SecurityToken?> getSoundSecurityToken(String token, int uid) async {
    SecurityToken? securityToken;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid
    });
    await NetUtil.getInstance().post(formData, "/IM/getSoundSecurityToken", (Map<String, dynamic> data) {
      securityToken = SecurityToken(data["data"]["ossAccessKeyId"], data["data"]["policy"], data["data"]["signature"], data["data"]["dir"], data["data"]["host"], data["data"]["expire"]);
    }, errorResponse);
    return securityToken;
  }


  Future<String> uploadImage(SecurityToken securityToken, String filePath, String filename, int uid) async {
    String returl = "";
    String imgkey = '${securityToken.dir}${uid}/${filename}';
    FormData formData = await new FormData.fromMap({
      'key': imgkey, //"可以填写文件夹名（对应于oss服务中的文件夹）/" + fileName
      'policy': securityToken.policy,
      'OSSAccessKeyId':securityToken.ossAccessKeyId,//Bucket 拥有者的AccessKeyId。
      'success_action_status': '200',//让服务端返回200，不然，默认会返回204
      'signature': securityToken.signature,
      'file':  await MultipartFile.fromFile(filePath, filename: filename, contentType: new  MediaType("image", "png"))//必须放在参数最后
    });
    await NetUtil.aliyunOSSpost(formData, securityToken.host, (String data){
      returl = imgkey;
    }, errorResponse);
    return returl;
  }

  Future<String> uploadSound(SecurityToken securityToken, String filePath, String filename, int uid) async {
    String retUrl = "";
    String soundkey = '${securityToken.dir}${uid}/${filename}';
    String soundUrl = securityToken.host + '/' + soundkey;
    FormData formData = await new FormData.fromMap({
      'key': soundkey, //"可以填写文件夹名（对应于oss服务中的文件夹）/" + fileName
      'policy': securityToken.policy,
      'OSSAccessKeyId':securityToken.ossAccessKeyId,//Bucket 拥有者的AccessKeyId。
      'success_action_status': '200',//让服务端返回200，不然，默认会返回204
      'signature': securityToken.signature,
      //audio/mpeg MPEG4
      'file':  await MultipartFile.fromFile(filePath, filename: filename, contentType: new  MediaType("audio", "mpeg4"))//必须放在参数最后
    });
    await NetUtil.aliyunOSSpost(formData, securityToken.host, (String data){
      retUrl = soundUrl;
    }, errorResponse);
    return retUrl;
  }


  Future<Map?> getImageInfo(String url) async {
    Map? map;
    await NetUtil.getInstance().get(url,(data){
      map = {"width":data["ImageWidth"], "height":data["ImageHeight"]};
    });

    return map;
  }

  errorResponse(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}