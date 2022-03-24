import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../global.dart';
import '../../bloc/user/authentication_bloc.dart';
import '../../util/showmessage_util.dart';

class NameAndSignature extends StatelessWidget {
  Object? arguments;
  TextEditingController _textEditingController = new TextEditingController();
  String _type = "";
  String _content = "";
  NameAndSignature({this.arguments}){
    _type = (arguments as Map)["type"].toString();
    _content = (arguments as Map)["content"] == null ? "" : (arguments as Map)["content"].toString();
    _textEditingController.text = _content != null ? _content : "";
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationAuthenticated) {
          //Navigator.of(context).pop(_textEditingController.text);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text(_type == "1" ? '昵称' : '个人简介', style: TextStyle(color: Colors.black, fontSize: 16)),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 20,left: 10, right: 10),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _type == "1" ? userName() : signature(),
              Container(
                width:double.infinity,
                child: RaisedButton(
                  child: Text('保存', style: TextStyle(color: Global.profile.fontColor),),
                  color: Global.profile.backColor,
                  onPressed: () async {
                    if(_type == "1") {
                      if (_textEditingController.text.length > 1) {
                        BlocProvider.of<AuthenticationBloc>(context).add(UpdateUserNamePressed(user: Global.profile.user!, username: _textEditingController.text));
                        Navigator.of(context).pop(_textEditingController.text);
                      }
                      else {
                        ShowMessage.showToast("昵称应该在2-15个字符之间");
                      }
                    }
                    else{
                      if(_textEditingController.text.length > 1){
                          BlocProvider.of<AuthenticationBloc>(context).add(
                              UpdateUserSignaturePressed(user: Global.profile.user!, signature: _textEditingController.text));
                          Navigator.of(context).pop(_textEditingController.text);
                      }
                      else{
                        ShowMessage.showToast("简介应该在2-100个字符之间");
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextField userName(){
    return TextField(
      controller: _textEditingController,
      maxLength: 15,//最大长度，设置此项会让TextField右下角有一个输入数量的统计字符串
      maxLines: 1,//最大行数
      autocorrect: true,//是否自动更正
      autofocus: true,//是否自动对焦
      textAlign: TextAlign.left,//文本对齐方式
      style: TextStyle(fontSize: 14.0, color: Colors.black),//输入文本的样式
      onChanged: (text) {//内容改变的回调
        //print('change $text');
      },

      decoration: InputDecoration(
        border: InputBorder.none,//去掉输入框的下滑线
        hintStyle: TextStyle(fontSize: 14),
        hintText: "请输入新昵称",
        filled: true,
        fillColor: Colors.white,
      )
    );
  }

  TextField signature(){
    return TextField(
          controller: _textEditingController,
          maxLength: 100,//最大长度，设置此项会让TextField右下角有一个输入数量的统计字符串
          maxLines: 9,//最大行数
          autocorrect: true,//是否自动更正
          autofocus: true,//是否自动对焦
          textAlign: TextAlign.left,//文本对齐方式
          style: TextStyle(fontSize: 14.0, color: Colors.black87),//输入文本的样式
          onChanged: (text) {//内容改变的回调
        },

        decoration: InputDecoration(
          border: InputBorder.none,//去掉输入框的下滑线
          hintStyle: TextStyle(fontSize: 14),
          hintText: "说说你的兴趣与爱好",
          filled: true,
          fillColor: Colors.white,
//          enabledBorder: OutlineInputBorder(
//            /*边角*/
//            borderRadius: BorderRadius.all(
//              Radius.circular(5), //边角为5
//            ),
//            borderSide: BorderSide(
//              color: Global.profile.backColor, //边线颜色为白色
//              width: 1, //边线宽度为2
//            ),
//          ),
//          focusedBorder: OutlineInputBorder(
//            borderSide: BorderSide(
//              color: Global.profile.backColor, //边框颜色为白色
//              width: 1, //宽度为5
//            ),
//            borderRadius: BorderRadius.all(
//              Radius.circular(5), //边角为30
//            ),
//          ),
        )
    );
  }
}
