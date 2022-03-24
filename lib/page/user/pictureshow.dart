import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user/authentication_bloc.dart';
import '../../global.dart';

class ProfilePictureShow extends StatefulWidget {
  final Function? parentJumpMyProfile;

  const ProfilePictureShow({Key? key, this.parentJumpMyProfile}) : super(key: key);

  @override
  _ProfilePictureShowState createState() => _ProfilePictureShowState();
}

class _ProfilePictureShowState extends State<ProfilePictureShow> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
    buildWhen: (previousState, state) {
      if(state is AuthenticationAuthenticated || state is LoginOuted) {
        return true;
      }
      else
        return false;
    },
    builder: (context, state) {
        return InkWell(
        onTap: (){
          if(state is AuthenticationAuthenticated) {
            widget.parentJumpMyProfile!(4);
          }
          else
            if(Global.profile.user == null) {
              Navigator.pushNamed(context, '/Login').then((onValue) {
                // if (Global.profile.isLogGuided && Global.profile.user != null) {
                //   showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return MessageDialog(
                //           title: new Text(
                //             "提示",
                //             style: new TextStyle(
                //                 fontSize: 16.0,
                //                 color: Colors.black87
                //             ),
                //           ),
                //           message: new Text(
                //             "快发布活动和朋友们聚一聚吧",
                //             style: TextStyle(
                //                 fontSize: 14.0, color: Colors.black54),
                //           ),
                //           negativeText: "不再提示",
                //           positiveText: "发布活动",
                //           containerHeight: 80,
                //           onPositivePressEvent: () {
                //             Navigator.pop(context);
                //             Navigator.pushNamed(context, '/IssuedActivity')
                //                 .then((value) {});
                //           },
                //           onCloseEvent: () {
                //             Navigator.pop(context,);
                //           },);
                //       }
                //   );
                //
                //   Global.profile.isLogGuided = false;
                // }
              });
            }
            else{
              widget.parentJumpMyProfile!(4);
            }
        },
        child: Global.profile.user != null && Global.profile.defProfilePicture != null ? Container(
          child: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
//          border: new Border.all(color: Global.profile.fontColor, width: 1.5), // 边色与边宽度
                borderRadius: BorderRadius.circular(50.0),
                image: DecorationImage(
                    image: Global.profile.defProfilePicture!,
                    fit: BoxFit.cover)
            ),
          ),
        ): Container(
          height: 45,
          width: 45,
          alignment: Alignment.center,
          child: Text('登录', style: TextStyle(fontSize: 14, color: Global.defredcolor, fontWeight: FontWeight.bold),),
          decoration: BoxDecoration(
//          border: new Border.all(color: Global.profile.fontColor, width: 1.5), // 边色与边宽度
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.grey.shade200
          ),
        )
      );
    });
  }
}
