import 'dart:async';
import 'package:flutter_app/service/userservice.dart';
import 'package:flutter_app/util/token_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../service/activity.dart';
import '../../service/gpservice.dart';
import '../../model/user.dart';
import '../../util/networkmanager_util.dart';
import '../../global.dart';
import 'user_repository.dart';
import 'event/authentication_event.dart';
import 'state/authentication_state.dart';
export 'event/authentication_event.dart';
export 'state/authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  String errorNetCode = "-9999";
  String errorNet = "网络异常，请再试一下";

  String error = "";
  String errorstatusCode = "";
  final UserRepository userRepository = new UserRepository();
  final ActivityService activityService = ActivityService();
  final UserService _userService = UserService();

  AuthenticationBloc():super(AuthenticationUninitialized());

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event,
      ) async* {
    //主动刷新
    if(event is Refresh){
      yield AuthenticationAuthenticated();
      return;
    }

    if(event is Refresh1){
      yield AuthenticationAuthenticated();
      return;
    }

    if (event is LoggedState) {
      final bool hasToUser = await userRepository.hasToUser();

      if (hasToUser) {
        yield AuthenticationAuthenticated();
      } else {
        yield LoginOuted();
      }
    }
    ///信息更新
    if (event is LoggedIn) {
      userRepository.persistToken(event.user);
      yield AuthenticationAuthenticated();
    }
    ///注销登录
    if (event is LoggedOut) {
      yield LoginOuted();
    }
    ///登录按钮
    if(event is LoginButtonPressed) {
      // yield LoginLoading();
      try {
        User? user = await userRepository.loginToUser(
            mobile: event.props[0].toString(),
            password: event.props[1].toString(),
            vcode: event.props[2].toString(),
            type: event.props[3] as int,
            country: event.country,
            captchaVerification: event.captchaVerification,
            errorCallBack: errorCallBack
        );
        if(user != null) {
          await LoginSuccess(user);
          yield AuthenticationAuthenticated();
        }
        else{
          ///验证未通过
          yield AuthenticationUnauthenticated(error: error, errorstatusCode: errorstatusCode);
        }

      } catch (error) {
        ///验证未通过
        yield AuthenticationUnauthenticated(error: errorNet, errorstatusCode: errorstatusCode);
      }
    }
    ///支付宝登录
    if(event is LoginAli){
      String authurl = await _userService.getAliUserAuth();
      User? user = await _userService.updateLoginali(authurl, errorCallBack);
      if(user != null){
        await LoginSuccess(user);
        yield AuthenticationAuthenticated();
      }
    }
    ///微信登录
    if(event is LoginWeiXin){
      User? user = await _userService.loginweixin(event.auth_code, errorCallBack);
      if(user != null){
        await LoginSuccess(user);
        yield AuthenticationAuthenticated();
      }
    }
    ///ios登录
    if(event is LoginIos){
      User? user = await _userService.loginIos(event.identityToken, event.iosuserid,  errorCallBack);
      if(user != null){
        await LoginSuccess(user);
        yield AuthenticationAuthenticated();
      }
    }

    ///更新照片
    if(event is UpdateImagePressed){
      try {
        bool ret = await userRepository.updateImage(event.user, event.serverimgpath, errorCallBack);
        if(ret) {
          await userRepository.updateUserPicture(event.user, event.imgpath);
          yield AuthenticationAuthenticated(isUserImage: true);
        }
        else{
          ///验证未通过
          yield AuthenticationUnauthenticated(error: error, errorstatusCode: errorstatusCode);
        }

      } catch (error) {
        ///验证未通过
        yield AuthenticationUnauthenticated(error: errorNet, errorstatusCode: errorNetCode);
      }
    }
    ///更新昵称
    if(event is UpdateUserNamePressed){
      try {
        bool ret = await userRepository.updateUserName(event.user, event.username, errorCallBack);
        if(ret) {
          event.user.username = event.username;
          userRepository.persistToken(event.user);
          yield AuthenticationAuthenticated();
        }
        else{
          ///验证未通过
          yield AuthenticationUnauthenticated(error: error, errorstatusCode: errorstatusCode);
        }

      } catch (error) {
        ///验证未通过
        yield AuthenticationUnauthenticated(error: errorNet, errorstatusCode: errorNetCode);
      }
    }
    ///更新个人简介
    if(event is UpdateUserSignaturePressed){
      try {
        bool ret = await userRepository.UpdateUserSignaturePressed(event.user, event.signature, errorCallBack);
        if(ret) {
          event.user.signature = event.signature;
          userRepository.persistToken(event.user);
          yield AuthenticationAuthenticated();
        }
        else{
          ///验证未通过
          yield AuthenticationUnauthenticated(error: error, errorstatusCode: errorstatusCode);
        }

      } catch (error) {
        ///验证未通过
        yield AuthenticationUnauthenticated(error: errorNet, errorstatusCode: errorNetCode);
      }
    }
    ///更新位置
    if(event is UpdateUserLocationPressed){
      try {
        bool ret = await userRepository.updateLocation(event.user, event.province, event.city,  errorCallBack);
        if(ret) {
          event.user.province = event.province;
          event.user.city = event.city;
          userRepository.persistToken(event.user);
          yield AuthenticationAuthenticated();
        }
        else{
          ///验证未通过
          yield AuthenticationUnauthenticated(error: error, errorstatusCode: errorstatusCode);
        }

      } catch (error) {
        ///验证未通过
        yield AuthenticationUnauthenticated(error: errorNet, errorstatusCode: errorNetCode);
      }
    }
    ///更新密码
    if(event is UpdateUserPasswordPressed){
      try {
        bool ret = await userRepository.UpdateUserPasswordPressed(event.user, event.password,  errorCallBack);
        if(ret) {
          yield AuthenticationAuthenticated();
        }
        else{
          ///验证未通过
          yield AuthenticationUnauthenticated(error: error, errorstatusCode: errorstatusCode);
        }

      } catch (error) {
        ///验证未通过
        yield AuthenticationUnauthenticated(error: errorNet, errorstatusCode: errorNetCode);
      }
    }
    ///更新性别
    if(event is UpdateUserSexPressed){
      try {
        bool ret = await userRepository.UpdateUserSexPressed(event.user, event.sex,  errorCallBack);
        if(ret) {
          event.user.sex = event.sex;
          userRepository.persistToken(event.user);
          yield AuthenticationAuthenticated();
        }
        else{
          ///验证未通过
          yield AuthenticationUnauthenticated(error: error, errorstatusCode: errorstatusCode);
        }

      } catch (error) {
        ///验证未通过
        yield AuthenticationUnauthenticated(error: errorNet, errorstatusCode: errorNetCode);
      }
    }
    ///更新生日
    if(event is UpdateUserBirthdayPressed){
      try {
        bool ret = await userRepository.UpdateUserBirthdayPressed(event.user, event.birthday,  errorCallBack);
        if(ret) {
          event.user.birthday = event.birthday;
          userRepository.persistToken(event.user);
          yield AuthenticationAuthenticated();
        }
        else{
          ///验证未通过
          yield AuthenticationUnauthenticated(error: error, errorstatusCode: errorstatusCode);
        }

      } catch (error) {
        ///验证未通过
        yield AuthenticationUnauthenticated(error: errorNet, errorstatusCode: errorNetCode);
      }
    }
    ///更新定位
    if(event is UpdateLocation){
      yield UpdateLocationed(locationName: event.locationName, locationCode: event.locationCode);
    }
    //初始化用户信息更新
    if(event is initUpdate){
      yield AuthenticationAuthenticated();
    }
  }

  @override
  void onTransition(Transition<AuthenticationEvent, AuthenticationState> transition) {
    //print(transition);
    super.onTransition(transition);
  }

  Future<void> LoginSuccess(User user) async {
    // UserRepository userRepository = new UserRepository();
    // userRepository.persistToken(user);
    //本地无数据就从服务器下载
    userRepository.persistToken(user);

    TokenUtil tokenUtil = new TokenUtil();
    await tokenUtil.getDeviceToken();

    GPService gpService = GPService();
    // UmengCommonSdk.onEvent('bool', {'name':'jack', 'age':18, 'male':true});

    if(user.likeact! > 0) {
      activityService.getUserLike(user.uid, user.token!); //点赞的活动
    }
    if(user.likebug > 0) {
      activityService.getUserLikeBug(user.uid, user.token!); //点赞的活动
    }

    if(user.likemoment > 0) {
      activityService.getUserLikeMoment(user.uid, user.token!); //点赞的活动
    }

    if(user.likesuggest > 0) {
      activityService.getUserLikeSuggest(user.uid, user.token!); //点赞的活动
    }
    if(user.collectionact! > 0) {
      activityService.getUserCollection(user.uid, user.token!); //收藏的活动
    }
    if(user.likecomment > 0 || user.likeevaluate! > 0) {
      activityService.getUserComnnentLike(
          user.uid, user.token!, user.likecomment,
          user.likeevaluate!); //获取用户留言和评论的点赞情况comment和evaluate
    }
    if(user.likegoodpricecomment  > 0) {
      activityService.getUserGoodPriceComnnentLike(
          user.uid, user.token!, user.likegoodpricecomment); //获取用户留言和评论的点赞情况goodprice
    }
    if(user.likebugcomment > 0 || user.likesuggestcomment > 0 || user.likemomentcomment > 0) {
      activityService.getUserBugAndSuggestAndMomentComnnentLike(
          user.uid, user.token!, user.likebugcomment,
          user.likesuggestcomment,user.likemomentcomment); //获取用户留言和评论的点赞情况comment和evaluate
    }

    if(user.collectionproduct! > 0) {
      gpService.getUserGoodPriceCollection(
          user.uid, user.token!); //获取用户收藏的优惠商品
    }
    if(user.notinteresteduids != null && user.notinteresteduids!.isNotEmpty){

    }
    //获取用户的好友
//          CommunityService communityService = CommunityService();
//          await communityService.getMyCommunityListByUser(0, user.uid);
    //我的关注
    if(user.following! > 0) {
      userRepository.getfollow(user, errorCallBack);
    }
    //我的不感兴趣,不需要重新获取数据
    if(user.notinteresteduids != null && user.notinteresteduids!.isNotEmpty) {
      await userRepository.updateNotInteresteduids(user, errorCallBack);
    }
    //我的好价不感兴趣,不需要重新获取数据
    if(user.goodpricenotinteresteduids != null && user.goodpricenotinteresteduids!.isNotEmpty) {
      await userRepository.updateGoodPriceNotInteresteduids(user, errorCallBack);
    }
    //我的黑名单,不需要重新获取数据
    if(user.blacklist != null && user.blacklist!.isNotEmpty) {
      await userRepository.updateBlacklist(user, errorCallBack);
    }


    NetworkManager.init(user, Global.mainContext!);

  }

  errorCallBack(String statusCode, String msg) {
    error = msg;
    errorstatusCode = statusCode;
  }
}


