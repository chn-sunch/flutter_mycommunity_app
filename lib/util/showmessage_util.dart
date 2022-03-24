import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowMessage{
    static showToast(String msg){
      Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.black54,
          textColor: Colors.white);
    }


    static showCenterToast(String msg){
      Widget toast = Container(
        alignment: Alignment.center,
        height: 130,
        width: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9.0),
          color: Colors.black54.withAlpha(120),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor:  AlwaysStoppedAnimation(Colors.white),
            ),
            SizedBox(
              height: 12,
            ),
            Text(msg, style: TextStyle(fontSize: 16, color: Colors.white),),
          ],
        ),

      );


      FToast().showToast(
        child: toast,
        gravity: ToastGravity.CENTER,
        toastDuration: Duration(seconds: 3),
      );
    }

    static cancel(){
      Fluttertoast.cancel();
      FToast().removeCustomToast();
    }
}