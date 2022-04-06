import 'package:flutter/material.dart';

//去掉equatable 返回状态就rebuild
abstract class AuthenticationState  {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}
///验证初始状态
class AuthenticationUninitialized extends AuthenticationState {}
///验证通过
class AuthenticationAuthenticated extends AuthenticationState {
  bool isUserImage;
  AuthenticationAuthenticated({this.isUserImage = false});
}

///验证未通过 1.账号密码登录验证  2.信息更新等失败后的状态
class AuthenticationUnauthenticated extends AuthenticationState {

  String? error;
  String? errorstatusCode;
  AuthenticationUnauthenticated({@required this.error, @required this.errorstatusCode});

  @override
  List<Object> get props => [error??"", errorstatusCode??""];

  @override
  String toString() => 'AuthenticationUnauthenticated { statusCode: $errorstatusCode ,error: $error }';
}
//首页定位
class UpdateLocationed extends AuthenticationState{
  String? locationName;
  String? locationCode;

  UpdateLocationed({@required this.locationName, @required this.locationCode});

  @override
  List<Object> get props => [locationName??"", locationCode??""];

  @override
  String toString() => 'UpdateLocationed { locationName: $locationName ,locationCode: $locationCode }';
}
///登录中
class LoginLoading extends AuthenticationState{}
///未登录
class LoginOuted extends AuthenticationState{}

///验证失败

