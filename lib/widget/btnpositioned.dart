import 'package:flutter/material.dart';
///按钮
// ignore: must_be_immutable
class PositionedBtnWidget extends StatefulWidget {
  double? btnTop;
  double? right;
  double? left;
  String? image;
  double? opacity;
  double? size;
  Widget? content;

  ///更新透明度
  Function? updateOpacity;

  ///要触发的事件
  Function actionFunction;

  PositionedBtnWidget(
      {this.btnTop ,
        this.right ,
        this.left ,
        this.opacity ,
        this.image ,
        this.size ,
        this.content,
        required this.actionFunction});

  @override
  State<StatefulWidget> createState() {
    return PositionedBtnState();
  }
}

class PositionedBtnState extends State<PositionedBtnWidget> {
  double? btnTop;
  double? right;
  double? left;
  String? image;
  double? btnOpacity;
  double? size;

  @override
  void initState() {
    super.initState();
    if (widget != null) {
      btnTop = widget.btnTop != null ? widget.btnTop : null;
      right = widget.right != null ? widget.right : null;
      left = widget.left != null ? widget.left : null;
      image = widget.image != null ? widget.image : null;
      btnOpacity = widget.opacity != null ? widget.opacity : null;
      size = widget.size != null?widget.size : 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    ///更新透明度
    if (widget != null && widget.updateOpacity == null) {
      widget.updateOpacity = (double opacity) {
        setState(() {
          btnOpacity = opacity;
        });
      };
    }

    return Positioned(
      top: btnTop,
      right: right,
      left: left,
      child: Opacity(
        opacity: btnOpacity!,
        child: widget.content != null ? widget.content : IconButton(
          iconSize: size!,
          icon: Image.asset(image!),
          onPressed: () {
            if (widget != null && widget.actionFunction != null) {
              widget.actionFunction();
            }
          },
        ),
      ),
    );
  }
}

///app barb
class AppBarWidget extends StatefulWidget {
  Function? updateAppBarOpacity;

  @override
  State<StatefulWidget> createState() => AppBarState();
}

class AppBarState extends State<AppBarWidget> {
  double opacity = 0;

  @override
  void initState() {
    if (widget != null) {
      widget.updateAppBarOpacity = (double op) {
        if (mounted) {
          setState(() {
            opacity = op;
          });
        }
      };
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = MediaQuery.of(context).padding.top;
    appBarHeight += 44;

    return Opacity(
      opacity: opacity,
      child: Container(
        height: appBarHeight,
        child: AppBar(
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}