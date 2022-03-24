import 'package:flutter/material.dart';

class MyLoadingProgress extends StatelessWidget {
  //子布局
  final Widget child;

  //加载中是否显示
  final bool loading;

  //是否网络异常
  final bool isNetError;

  //进度提醒内容
  final String msg;

  //加载中动画
  final Widget progress;

  //背景透明度
  final double alpha;

  //字体颜色
  final Color textColor;

  MyLoadingProgress(
      {Key? key,
        required this.loading,
        required this.isNetError,
        this.msg = "加载中",
        this.progress = const CircularProgressIndicator(),
        this.alpha = 0.6,
        this.textColor = Colors.grey,
        required this.child})
      : //assert(child != null),
        assert(loading != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    if(child != null)
      widgetList.add(child);
    if(!isNetError){
      if (loading) {
        Widget layoutProgress;
        if (msg == null) {
          layoutProgress = Center(
            child: progress,
          );
        } else {
          layoutProgress = Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  progress,
                  Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                    child: Text(
                      msg,
                      style: TextStyle(color: textColor, fontSize: 16.0),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        widgetList.add(Opacity(
          opacity: alpha,
          child: new ModalBarrier(color: Colors.white),
        ));
        widgetList.add(layoutProgress);
      }
    }
//    else{
//      widgetList.add(Center(child: new Image.asset(
//          "images/load_error.png",//广告图
//          fit: BoxFit.fill)
//      ),
//      );
//    }
    return Stack(
      children: widgetList,
    );
  }
}