import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/util/common_util.dart';

import '../../model/user.dart';
import '../../service/userservice.dart';
import '../../util/imhelper_util.dart';
import '../../util/token_util.dart';
import '../../global.dart';

class UserRepository {

  User? user;
  UserService _userService =  new UserService();
  ImHelper imHelper = ImHelper();
  ///登录并返回1.密码 2.验证码
  Future<User?> loginToUser({String mobile = "", String password = "", String vcode = "", int type = 1, String captchaVerification = "", String country = "", Function? errorCallBack}) async {
    if(type == 1) {
      user = await _userService.login(mobile, password, captchaVerification, errorCallBack!);
    }
    else{
      user = await _userService.loginMobile(mobile, vcode, country, errorCallBack!);
    }

    return user;
  }
  ///更新图片
  Future<bool> updateImage(User user, String imgpath, Function errorCallBack){
    return _userService.updateImageByUrl(user.token!, user.uid, imgpath, errorCallBack);
  }
  ///更新昵称
  Future<bool> updateUserName(User user, String username, Function errorCallBack){
    return _userService.updateUserName(user.token!, user.uid, username, errorCallBack);
  }
  ///更新所在城市
  Future<bool> updateLocation(User user, String province, String city, Function errorCallBack){
    return _userService.updateLocation(user.token!, user.uid, province, city, errorCallBack);
  }
  ///更新密码
  Future<bool> UpdateUserPasswordPressed(User user, String password, Function errorCallBack){
    return _userService.updatePassword(user.token!, user.uid, password,  errorCallBack);
  }
  ///更新兴趣
  Future<bool> UpdateUserInterest(User user, String interest, Function errorCallBack){
    return _userService.updateInterest(user.token!, user.uid, interest,  errorCallBack);
  }
  ///更新录音
  Future<bool> UpdateUserVoice(User user, String voice, Function errorCallBack){
    return _userService.updateVoice(user.token!, user.uid, voice,  errorCallBack);
  }
  ///更新性别
  Future<bool> UpdateUserSexPressed(User user, String sex, Function errorCallBack){
    return _userService.updateSex(user.token!, user.uid, sex,  errorCallBack);
  }
  ///更新生日
  Future<bool> UpdateUserBirthdayPressed(User user, String birthday, Function errorCallBack){
    return _userService.updateBirthday(user.token!, user.uid, birthday,  errorCallBack);
  }
  ///更新个人简介
  Future<bool> UpdateUserSignaturePressed(User user, String signature, Function errorCallBack){
    return _userService.updateSignature(user.token!, user.uid, signature,  errorCallBack);
  }
  //更新关注
  Future<void> getfollow(User user, Function errorCallBack) async {
    List<int> ret = await imHelper.selMyFollowState(user.uid);
    if(ret.length <= 0){
      List<int> follows = await _userService.getFollow(user.uid);
      if(follows != null) {
        for (int i = 0; i < follows.length; i++) {
          imHelper.delFollowState(follows[i], user.uid);
          imHelper.saveFollowState(follows[i], user.uid);
        }
      }
    }
  }
  //更新对他不感兴趣
  Future<void> updateNotInteresteduids(User user, Function errorCallBack) async {
    List<int> ret = await imHelper.getNotInteresteduids(user.uid);
    if(ret.length <= 0){
      List<String> notInteresteduids = user.notinteresteduids!.split(",");
      if(notInteresteduids != null && notInteresteduids.length > 0) {
        for (int i = 0; i < notInteresteduids.length; i++) {
          imHelper.saveNotInteresteduids(user.uid, int.parse(notInteresteduids[i].toString()));
        }
      }
    }
  }

  //更新对他不感兴趣
  Future<void> updateGoodPriceNotInteresteduids(User user, Function errorCallBack) async {
    List<int> ret = await imHelper.getGoodPriceNotInteresteduids(user.uid);
    if(ret.length <= 0){
      List<String> goodpricenotinteresteduids = user.goodpricenotinteresteduids!.split(",");
      if(goodpricenotinteresteduids != null && goodpricenotinteresteduids.length > 0) {
        for (int i = 0; i < goodpricenotinteresteduids.length; i++) {
          imHelper.saveGoodPriceNotInteresteduids(user.uid, int.parse(goodpricenotinteresteduids[i].toString()));
        }
      }
    }
  }


  //更新我的黑名单
  Future<void> updateBlacklist(User user, Function errorCallBack) async {
    List<int> ret = await imHelper.getBlacklistUid(user.uid);
    if(ret.length <= 0){
      List<String> blacklist = user.blacklist!.split(",");
      if(blacklist != null && blacklist.length > 0) {
        for (int i = 0; i < blacklist.length; i++) {
          imHelper.saveBlacklistUid(user.uid, int.parse(blacklist[i].toString()));
        }
      }
    }
  }

  //更新

  ///注销
  Future<bool> deleteToken(User user, Function errorCallBack) async {
    bool ret = await _userService.deltoken(user.token!, user.uid, errorCallBack);
    if(ret) {
      Global.profile.user = null;
      // Global.profile.locationName = "全国";
      // Global.profile.locationCode = "allCode";
      // Global.profile.locationGoodPriceCode = "allCode";
      // Global.profile.locationGoodPriceName = "全国";
      // Global.profile.locationCode = "350100";
      // Global.profile.locationName = "福州";
      // Global.profile.locationGoodPriceCode = "350100";
      // Global.profile.locationGoodPriceName = "福州";

      Global.profile.defProfilePicture = AssetImage(Global.headimg);
      //await Global.profile.setProfilepicture();
      Global.saveProfile();
    }
    return ret;
  }
  ///更新本地文件
  void persistToken(User user) {
    if(user != null) {
      ///更新用户到全局变量
      Global.profile.user = user;

      if(user.profilepicture != null && user.profilepicture!.isNotEmpty)
        Global.profile.defProfilePicture = new NetworkImage(user.profilepicture!);
      if(user.profilepicture == null)
        user.profilepicture = Global.profile.profilePicture;

      // ImageCache imageCache = new ImageCache();
      // imageCache.evict(user.profilepicture);
      ///保存用户到本地文件
      Global.saveProfile();
    }
  }

  //更新用户头像
  Future<void> updateUserPicture(User user, String profilepicture) async {
    //删除图片缓存刷新引用
    ImageCache? imageCache = await PaintingBinding.instance!.imageCache;
    await imageCache!.evict( NetworkImage(user.profilepicture!));
    user.profilepicture = profilepicture;
    Global.saveProfile();
    user.profilepicture = profilepicture + "?${Random().nextInt(111111111)}";
    Global.profile.defProfilePicture = await new NetworkImage(user.profilepicture!);

    // imageCache.clearLiveImages();
    // imageCache.clear();
    // DefaultCacheManager defaultCacheManager =  new DefaultCacheManager();
    // await defaultCacheManager.removeFile(user.profilepicture);
    //  ImageCache imageCache = new ImageCache();
    //  imageCache.evict(user.profilepicture);
    // print(imageCache.clearLiveImages());
    // print(imageCache.clearLiveImages().toString());
    //

  }


  ///是否已经登录
  bool hasToUser() {
    if(Global.profile.user != null)
      return true;
    else
      return false;
  }

  String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

  successResponse(Map<String, dynamic> data) {
    if (data["data"]["token"].toString() != "") {
      user = User.fromJson(json.decode(
          CommonUtil.GetJsonString(data["data"]["token"].toString())));
      user!.token = data["data"]["token"].toString();
    }
  }


}