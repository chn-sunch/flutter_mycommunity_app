import 'package:flutter/material.dart';

class SoundCircleProcess extends StatefulWidget {
  @override
  _SoundCircleProcessState createState() => _SoundCircleProcessState();
}

class _SoundCircleProcessState extends State<SoundCircleProcess> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  //doubler类型动画
  late Animation<double> doubleAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //创建AnimationController
    controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    //animation第一种创建方式：
    doubleAnimation =
    new Tween<double>(begin: 55.0, end: 50.0).animate(controller)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..addStatusListener((AnimationStatus status) {
        //执行完成后反向执行
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          //反向执行完成，正向执行
          controller.forward();
        }
      });
    //启动动画
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Container(
      width: doubleAnimation.value,
      height: doubleAnimation.value,
      decoration: BoxDecoration(
          color: Colors.cyan,
          shape: BoxShape.circle
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }
}
