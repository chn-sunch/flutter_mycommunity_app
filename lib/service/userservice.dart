import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:tobias/tobias.dart' as tobias;

import '../model/user.dart';
import '../model/dynamic.dart';
import '../model/im/grouprelation.dart';
import '../model/im/timelinesync.dart';
import '../model/order.dart';
import '../util/imhelper_util.dart';
import '../util/net_util.dart';
import '../util/showmessage_util.dart';
import '../global.dart';

class UserService {
  ImHelper imHelper = new ImHelper();

  //登录
  Future<User?> login(String mobile, String password, String captchaVerification, Function errorCallBack) async {
    User? user = null;
    FormData formData = FormData.fromMap({
      "mobile": mobile,
      "password": generateMd5(password),
      "captchaVerification": captchaVerification
    });
    await NetUtil.getInstance().post(formData, "/user/login", (data){
      if(data["data"] != null && data["data"] != "") {
        try {
          if (data["data"]["user"] == null){
            //启动验证
          }
          else if (data["data"]["user"].toString() != "") {
            user = User.fromJson(data["data"]["user"]);
            user!.token = data["data"]["token"].toString();
          }
        }
        catch(e){
          user = null;
          errorCallBack("-8001", '服务器忙请稍后再试');
        }
      }
    }, errorCallBack);

    return user;
  }

  //发送验证码
  Future<bool> sendVCode(String mobile) async {
    bool vsendstatus = false;
    await NetUtil.getInstance().get("/user/sendVCode", (Map<String, dynamic> data) {
      vsendstatus = true;
    }, params: {"mobile": mobile}, errorCallBack: errorResponse);
    return vsendstatus;
  }

  //发送验证码
  Future<bool> sendVCodeByUid(int uid, String token) async {
    bool vsendstatus = false;
    await NetUtil.getInstance().get("/user/sendVCodeByUid", (Map<String, dynamic> data) {
      vsendstatus = true;
    }, params: {"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return vsendstatus;
  }

  //手机验证登录
  Future<User?> loginMobile(String mobile, String vcode, String country, Function errorCallBack) async {
    User? user = null;
    FormData formData = FormData.fromMap({
      "mobile": mobile,
      "vcode": vcode,
      "country": country
    });
    await NetUtil.getInstance().post(formData, "/user/loginmobile", (data){
      if (data["data"]["user"].toString() != "") {
        user = User.fromJson(data["data"]["user"]);
        user!.token = data["data"]["token"].toString();
      }
    }, errorCallBack);
    return user;
  }

  //微信登录
  Future<User?> loginweixin(String code, Function errorCallBack) async {
    User? user = null;
    FormData formData = FormData.fromMap({
      "code": code
    });
    await NetUtil.getInstance().post(formData, "/user/loginweixin", (data){
      if (data["data"]["user"].toString() != "") {
        user = User.fromJson(data["data"]["user"]);
        user!.token = data["data"]["token"].toString();
      }
    }, errorCallBack);
    return user;
  }
  //ios登录
  Future<User?> loginIos(String identityToken, String iosuserid, Function errorCallBack) async {
    User? user = null;
    FormData formData = FormData.fromMap({
      "identityToken": identityToken,
      "iosuserid": iosuserid
    });
    await NetUtil.getInstance().post(formData, "/user/loginios", (data){
      if (data["data"]["user"].toString() != "") {
        user = User.fromJson(data["data"]["user"]);
        user!.token = data["data"]["token"].toString();
      }
    }, errorCallBack);
    return user;
  }

  //支付宝登录注册
  Future<User?> updateLoginali(String authurl, Function errorCallBack) async {
    User? user = null;
    String auth_code = "";
    if(authurl != null && authurl.isNotEmpty) {
      Map ret = await tobias.aliPayAuth(authurl);
      if(ret != null) {
        if(ret["result"] != null) {
          String responsestr = ret["result"].toString();
          List<String> parms = responsestr.split('&');
          for(int i = 0; i < parms.length; i++){
            if(parms[i].indexOf("auth_code") >= 0) {
              auth_code = parms[i].split('=')[1];
              FormData formData = FormData.fromMap({
                "auth_code": auth_code
              });

              await NetUtil.getInstance().post(formData, "/AliPay/loginali", (Map<String, dynamic> data) {
                if (data["data"]["user"].toString() != "") {
                  user = User.fromJson(data["data"]["user"]);
                  user!.token = data["data"]["token"].toString();
                }
              }, errorCallBack);
            }
          }
        }
      }
    }

    return user;
  }

  //绑定支付宝账号
  Future<User?> updateAliPay(int uid, String token, String authurl, bool confirm, Function errorCallBack) async {
    User? user = null;
    String auth_code = "";
    if(authurl != null && authurl.isNotEmpty) {
      Map ret = await tobias.aliPayAuth(authurl);
      if(ret != null) {
        if(ret["result"] != null) {
          String responsestr = ret["result"].toString();
          List<String> parms = responsestr.split('&');
          for(int i = 0; i < parms.length; i++){
            if(parms[i].indexOf("auth_code") >= 0) {
              auth_code = parms[i].split('=')[1];
              FormData formData = FormData.fromMap({
                "uid": uid,
                "token": token,
                "auth_code": auth_code,
                "confirm": confirm
              });

              await NetUtil.getInstance().post(formData, "/AliPay/updateali", (Map<String, dynamic> data) {
                if (data["data"] != "") {
                  user = User.fromJson(data["data"]);
                }
              }, errorCallBack);
            }
          }
        }
      }
    }

    return user;
  }

  //绑定微信账号
  Future<User?> updateWeixin(int uid, String token, String code, bool confirm, Function errorCallBack) async {
    User? user = null;

    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "code": code,
      "confirm": confirm
    });

    await NetUtil.getInstance().post(formData, "/user/updateweixin", (Map<String, dynamic> data) {
      if (data["data"] != "") {
        user = User.fromJson(data["data"]);
      }
    }, errorCallBack);

    return user;
  }

  //绑定ios账号
  Future<User?> updateIos(int uid, String token, String identityToken, bool confirm, String iosuserid, Function errorCallBack) async {
    User? user = null;

    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "identityToken": identityToken,
      "confirm": confirm,
      "iosuserid": iosuserid
    });

    await NetUtil.getInstance().post(formData, "/user/updateios", (Map<String, dynamic> data) {
      if (data["data"] != "") {
        user = User.fromJson(data["data"]);
      }
    }, errorCallBack);

    return user;
  }

  //获取支付宝用户授权请求
  Future<String> getAliUserAuth() async {
    String authurl = "";
    FormData formData = FormData.fromMap({

    });
    await NetUtil.getInstance().post(formData, "/AliPay/userauth", (Map<String, dynamic> data) {
      authurl = data["data"];
    }, (code,msg){
      ShowMessage.showToast(msg);
    });

    return authurl;
  }

  //上传设备信息
  Future<bool> updatePushToken(int uid, String token, String brand, String pushtoken,  Function errorCallBack) async {
    bool ret = false;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "brand": brand,
      "pushtoken": pushtoken
    });
    await NetUtil.getInstance().post(formData, "/user/updatePushToken", (data){
      ret = true;
    }, errorCallBack);
    return ret;
  }
  //手机验证码
  Future<bool> verifyVCode(int uid, String token, String vcode, Function errorCallBack) async {
    bool ret = false;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "vcode": vcode
    });
    await NetUtil.getInstance().post(formData, "/user/verifyVCode", (data){
      ret = true;
    }, errorCallBack);
    return ret;
  }

  //手机验证码
  Future<User?> updateMobile(int uid, String token, String vcode, String mobile, String country, bool confirm, Function errorCallBack) async {
    User? user = null;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "vcode": vcode,
      "mobile": mobile,
      "country": country,
      "confirm": confirm
    });
    await NetUtil.getInstance().post(formData, "/user/updateMobile", (data){
      user = User.fromJson(data["data"]);
    }, errorCallBack);
    return user;
  }

//手机验证码
  Future<bool> userexit(int uid, String token, Function errorCallBack) async {
    bool ret = false;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
    });
    await NetUtil.getInstance().post(formData, "/user/userexit", (data){
      ShowMessage.cancel();
      ret = true;
    }, errorCallBack);
    return ret;
  }

  //获取用户信息
  Future<User?> getUserInfo(int uid, Function errorCallBack) async {
    User? user = null;
    FormData formData = FormData.fromMap({
      "uid": uid
    });
    await NetUtil.getInstance().post(formData, "/user/getuserinfo", (Map<String, dynamic> data) {
      if(data["data"] != null) {
        user = User.fromJson(data["data"]);
        Global.profile.user!.following = user!.following;
        Global.profile.user!.followers = user!.followers;
        Global.saveProfile();
      }
    }, errorResponse);


    return user;
  }

  //更新头像byte
  Future<bool> updateImage(String token, int uid, File myimg) async {
    bool isupdateImage = false;

    FormData formData = FormData.fromMap({
      "imagefile": await MultipartFile.fromFile(myimg.path),
      "token": token,
      "uid": uid
    });
    await NetUtil.getInstance().post(formData, "/user/updateImage", (Map<String, dynamic> data) {
      isupdateImage = true;
    }, errorResponse);
    return isupdateImage;
  }

  //更新头像ossurl
  Future<bool> updateImageByUrl(String token, int uid, String imgpath, Function errorCallBack) async {
    bool isupdateImage = false;

    FormData formData = FormData.fromMap({
      //"path": await MultipartFile.fromFile(imgpath),
      "path": imgpath,
      "token": token,
      "uid": uid
    });
    await NetUtil.getInstance().post(formData, "/user/updateImage", (Map<String, dynamic> data) {
      isupdateImage = true;
    }, errorCallBack);
    return isupdateImage;
  }

  //更新性别
  Future<bool> updateSex(String token, int uid, String sex, Function errorCallBack) async {
    bool isUpdate = false;

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "sex": sex
    });
    await NetUtil.getInstance().post(formData, "/user/updateSex", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //关注话题
  Future<bool> updateSubject(String token, int uid, String subject, Function errorCallBack) async {
    bool isUpdate = false;

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "subject": subject
    });
    await NetUtil.getInstance().post(formData, "/user/updateSubject", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //更新生日
  Future<bool> updateBirthday(String token, int uid, String birthday, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "birthday": birthday
    });
    await NetUtil.getInstance().post(formData, "/user/updateBirthday", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //更新昵称
  Future<bool> updateUserName(String token, int uid, String username, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "username": username
    });
    await NetUtil.getInstance().post(formData, "/user/updateUserName", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //更新位置
  Future<bool> updateLocation(String token, int uid, String province, String city, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "province": province,
      "city": city
    });
    await NetUtil.getInstance().post(formData, "/user/updateLocation", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //更新个人简介
  Future<bool> updateSignature(String token, int uid, String signature, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "signature": signature,
    });
    await NetUtil.getInstance().post(formData, "/user/updateSignature", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //更新密碼
  Future<bool> updatePassword(String token, int uid, String password, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "password": generateMd5(password),
    });
    await NetUtil.getInstance().post(formData, "/user/updatePassWord", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //更新兴趣
  Future<bool> updateInterest(String token, int uid, String interest, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "interest": interest,
    });
    await NetUtil.getInstance().post(formData, "/user/updateInterest", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }


  //更新录音
  Future<bool> updateVoice(String token, int uid, String voice, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "voice": voice,
    });
    await NetUtil.getInstance().post(formData, "/user/updateVoice", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }
  //注销
  Future<bool> deltoken(String token, int uid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/user/deltoken", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack, isloginOut: true);



    return isUpdate;
  }
  //更新活动不感兴趣用户
  Future<bool> updateNotinteresteduids(String token, int uid, int notinteresteduids, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "notinteresteduids": notinteresteduids
    });
    await NetUtil.getInstance().post(formData, "/user/updateNotinteresteduids", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }
  //更新好价不感兴趣用户
  Future<bool> goodpricenotinteresteduids(String token, int uid, int goodpricenotinteresteduids, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "goodpricenotinteresteduids": goodpricenotinteresteduids
    });
    await NetUtil.getInstance().post(formData, "/user/goodpricenotinteresteduids", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }
  //更新黑名单
  Future<bool> updateBlacklist(String token, int uid, int blacklist, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "blacklist": blacklist
    });
    await NetUtil.getInstance().post(formData, "/user/updateBlacklist", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }
  //获取不感兴趣列表
  Future<List<int>> getFollow(int uid) async {
    bool ret = false;
    List<int> lists = [];
    FormData formData = FormData.fromMap({
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/user/getFollow", (Map<String, dynamic> data) {
      if(data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          lists.add(data["data"][i]);
        }
      }
    }, errorResponse, isloginOut: true);
    return lists;
  }
  //获取黑名单列表
  Future<String> isFollowed(int uid, int followed, Function errorCallBack) async{
    String createtime = "";
    FormData formData = FormData.fromMap({
      "uid": uid,
      "followed": followed,
    });
    await NetUtil.getInstance().post(formData, "/user/selFollwerUser", (Map<String, dynamic> data) {
      if(data["data"] != null)
        createtime = data["data"];
    }, errorCallBack, isloginOut: true);
    return createtime;
  }
  //关注
  Future<bool> Follow(String token, int uid, int followed, Function errorCallBack) async{
    bool ret = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "followed": followed,
    });
    await NetUtil.getInstance().post(formData, "/user/follwerCommunity", (Map<String, dynamic> data) {
    if(data["data"] != null)
      ret = true;
    }, errorCallBack, isloginOut: true);
    return ret;
  }
  //取消关注
  Future<bool> cancelFollow(String token, int uid, int followed, Function errorCallBack) async{
    bool ret = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "followed": followed,
    });
    await NetUtil.getInstance().post(formData, "/user/cleanfollwerCommunity", (Map<String, dynamic> data) {
      if(data["data"] != null)
        ret = true;
    }, errorCallBack, isloginOut: true);
    return ret;
  }
  //获取关注的社团
  Future<List<User>> getFollowUsers(int currentIndex, int uid, String token ) async {
    List<User> users = [];
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "currentIndex": currentIndex
    });
    await NetUtil.getInstance().post(formData, "/user/getFollowUsers", (Map<String, dynamic> data) {
      if(data["data"] != null){
        for(int i=0; i<data["data"].length; i++){
          users.add(User.fromJson(data["data"][i]));
        }
      }
    }, errorResponse);
    return users;
  }
  //获取我关注的社团，myhome页面中使用只返回5条记录
  Future<List<User>> getFollowUsersInCommunityALL(int currentIndex, int uid, String token ) async {
    List<User> users = [];
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "currentIndex": currentIndex
    });
    await NetUtil.getInstance().post(formData, "/user/getFollowUsersInCommunityALL", (Map<String, dynamic> data) {
      if(data["data"] != null){
        for(int i=0; i<data["data"].length; i++){
          users.add(User.fromJson(data["data"][i]));
        }
      }
    }, errorResponse);
    return users;
  }
  //获取关注的用户和社团
  Future<List<User>> getFollowUsersCommunity(int uid,int currentIndex) async {
    List<User> users = [];
    FormData formData = FormData.fromMap({
      "uid": uid,
      "currentIndex": currentIndex
    });
    await NetUtil.getInstance().post(formData, "/user/getFollowUsersCommunity", (Map<String, dynamic> data) {
      if(data["data"] != null){
        for(int i=0; i<data["data"].length; i++){
          User tem = User.fromJson(data["data"][i]);
          tem.isFollow = true;
          users.add(tem);
        }
      }
    }, errorResponse);
    return users;
  }
  //获取用户粉丝
  Future<List<User>> getFans(int uid, int currentIndex) async {
    bool ret = false;
    List<User> lists = [];
    FormData formData = FormData.fromMap({
      "uid": uid,
      "currentIndex": currentIndex
    });
    await NetUtil.getInstance().post(formData, "/user/getFansUsers", (Map<String, dynamic> data) {
      if(data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          lists.add(User.fromJson(data["data"][i]));
        }
      }
    }, errorResponse);
    return lists;
  }
  //获取个人动态
  Future<List<Dynamic>> getUserDynamic(int currentIndex, int uid) async {
    List<Dynamic> dynamics = [];
    FormData formData = FormData.fromMap({
      "currentIndex": currentIndex,
      "uid": uid.toString()
    });
    await NetUtil.getInstance().post(formData, "/user/selUserDynamic", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          dynamics.add(Dynamic.fromJson(data["data"][i]));
        }
      }}, errorResponse);
    return dynamics;
  }
  //获取私聊关系
  Future<GroupRelation?> getSingleConversation(String timeline_id, int uid, int touid, String token, Function errorCallBack) async{
    GroupRelation? groupRelation;
    FormData formData = FormData.fromMap({
      "token": token,
      "touid": touid,
      "uid": uid,
      "timeline_id": timeline_id
    });
    await NetUtil.getInstance().post(formData, "/user/getSingleConversation", (Map<String, dynamic> data) {
      groupRelation = GroupRelation.fromJson(data['data']);
    }, errorCallBack);
    return groupRelation;
  }
  //创建私聊关系
  Future<GroupRelation?> joinSingle(String timeline_id, int uid, int touid, String token,
  String captchaVerification, Function errorCallBack, {int isCustomer = 0}) async{
    GroupRelation? groupRelation;
    FormData formData = FormData.fromMap({
      "token": token,
      "touid": touid,
      "uid": uid,
      "timeline_id": timeline_id,
      "captchaVerification": captchaVerification,
      "isCustomer": isCustomer
    });
    await NetUtil.getInstance().post(formData, "/user/joinSingle", (Map<String, dynamic> data) {
      groupRelation = GroupRelation.fromJson(data['data']);
    }, errorCallBack);
    return groupRelation;
  }

  //联系客服
  Future<GroupRelation?> joinSingleCustomer(String timeline_id, int uid, int touid, String token,
      String captchaVerification, Function errorCallBack, {int isCustomer = 0}) async{
    GroupRelation? groupRelation;
    FormData formData = FormData.fromMap({
      "token": token,
      "touid": touid,
      "uid": uid,
      "timeline_id": timeline_id,
      "captchaVerification": captchaVerification,
      "isCustomer": 1
    });
    await NetUtil.getInstance().post(formData, "/user/joinSingle", (Map<String, dynamic> data) async {
      groupRelation = GroupRelation.fromJson(data['data'][0]);
      TimeLineSync timeLineSync = TimeLineSync.fromMapByServer(
          data["data"][1]);
      List<TimeLineSync> timeLineSyncs =  [];
      timeLineSyncs.add(timeLineSync);
      await imHelper.saveMessageCustomer(timeLineSyncs);
    }, errorCallBack);
    return groupRelation;
  }

  String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }


  errorResponse(String statusCode, String msg) {
    if(statusCode == "-9015"){
      //用户不存在
    }
    else
      ShowMessage.showToast(msg);
  }

  //获取用户
  Future<User?> getOtherUser(int otheruid) async {
    User? user ;
    FormData formData = FormData.fromMap({
      "uid": otheruid,
    });

    await NetUtil.getInstance().post(formData, "/user/getuserinfo", (Map<String, dynamic> data) {
      if(data["data"] != null) {
        user = User.fromJson(data["data"]);
      }
    }, errorResponse);

    return user;
  }

  //发送加好友请求
  Future<bool> updateMemberJoin(String token, int uid, int touid, String cid,
      String content, int jointype, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "touid": touid,
      "content": content,
    });
    await NetUtil.getInstance().post(
        formData, "/user/updateMemberJoin", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //分享好友
  Future<bool> updateSharedFriend(String token, int uid, String id, String content, String image,
      String touids, int sharedtype, Function errorCallBack) async {
    bool ret = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "contentid": id,
      "touids": touids,
      "sharedtype": sharedtype,
      "content": content,
      "image": image,
      "fromuid": Global.profile.user!.uid,
    });
    await NetUtil.getInstance().post(formData, "/user/updateSharedFriend", (
        Map<String, dynamic> data) {
      ret = true;
    }, errorCallBack);
    return ret;
  }

  //获取我的订单
  Future<List<Order>> getMyOrder(String token, int uid, Function errorCallBack) async {
    List<Order> orders = [];
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/grouppurchase/getMyPendingOrder", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          orders.add(Order.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    return orders;
  }

  //获取已完成付款的订单
  Future<List<Order>> getMyOrderFinish(String token, int uid, Function errorCallBack) async {
    List<Order> orders = [];
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/grouppurchase/getMyFinishOrder", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          orders.add(Order.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    return orders;
  }

  //获取已退款的订单
  Future<List<Order>> getMyRefundOrder(String token, int uid, Function errorCallBack) async {
    List<Order> orders = [];
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/grouppurchase/getMyRefundOrder", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          orders.add(Order.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    return orders;
  }

  //获取已确认的订单
  Future<List<Order>> getMyConfirmOrder(String token, int uid, Function errorCallBack) async {
    List<Order> orders = [];
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/grouppurchase/getMyConfirmOrder", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          orders.add(Order.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    return orders;
  }
}