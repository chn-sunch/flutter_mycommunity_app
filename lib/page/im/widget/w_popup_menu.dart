import 'package:flutter/material.dart';

const double _kMenuScreenPadding = 8.0;
const List<String> wPopupMenuActions = [
  '复制',
  '转发',
  '收藏',
  '删除',
  '撤回',
  '提醒',
  '翻译',
  '标记',
];

class WPopupMenu extends StatefulWidget {
  WPopupMenu({
    Key? key,
    required this.onValueChanged,
    required this.actions,
    required this.child,
    required this.leftorright,
    this.pressType = PressType.longPress,
    this.pageMaxChildCount = 5,
    this.backgroundColor = Colors.black,
    this.menuWidth = 225,
    this.menuHeight = 42,
  });

  final ValueChanged<int> onValueChanged;
  final List<String> actions;
  final Widget child;
  final int leftorright; //0 左边  1 右边
  final PressType pressType; // 点击方式 长按 还是单击
  final int pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;

  @override
  _WPopupMenuState createState() => _WPopupMenuState();
}

class _WPopupMenuState extends State<WPopupMenu> {
  double width = 0;
  double height = 0;
  RenderBox? button;
  RenderBox? overlay;
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((call) {
      width = context.size!.width;
      height = context.size!.height;
      button = context.findRenderObject() as RenderBox;
      overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        if (entry != null) {
          removeOverlay();
        }
        return Future.value(true);
      },
      child: GestureDetector(
        child: widget.child,
        onTap: () {
          if (widget.pressType == PressType.singleClick) {
            onTap();
          }
        },
        onLongPress: () {
          if (widget.pressType == PressType.longPress) {
            onTap();
          }
        },
        onDoubleTap: () {
          if (widget.pressType == PressType.doubleClick) {
            onTap();
          }
        },
      ),
    );
  }

  void onTap() {
    Widget menuWidget = _MenuPopWidget(
      context,
      height,
      widget.leftorright,
      widget.actions,
      widget.pageMaxChildCount,
      widget.backgroundColor,
      widget.menuWidth,
      widget.menuHeight,
      button!,
      overlay!,
          (index) {
        if (index != -1) widget.onValueChanged(index);
        removeOverlay();
      },
    );

    entry = OverlayEntry(builder: (context) {
      return menuWidget;
    });
    Overlay.of(this.context)!.insert(entry!);
  }

  void removeOverlay() {
    entry!.remove();
    entry = null;
  }
}

enum PressType {
  // 长按
  longPress,
  // 单击
  singleClick,
  // 双击
  doubleClick,
}

class _MenuPopWidget extends StatefulWidget {
  final BuildContext btnContext;
  final List<String> actions;
  final int _pageMaxChildCount;
  final Color backgroundColor;
  final double menuWidth;
  final double menuHeight;
  final double _height;
  final int leftorright;//0 左  1右
  final RenderBox button;
  final RenderBox overlay;
  final ValueChanged<int> onValueChanged;

  _MenuPopWidget(
      this.btnContext,
      this._height,
      this.leftorright,
      this.actions,
      this._pageMaxChildCount,
      this.backgroundColor,
      this.menuWidth,
      this.menuHeight,
      this.button,
      this.overlay,
      this.onValueChanged,
      );

  @override
  _MenuPopWidgetState createState() => _MenuPopWidgetState();
}

class _MenuPopWidgetState extends State<_MenuPopWidget> {
  int _curPage = 0;
  final double _arrowWidth = 40;
  final double _separatorWidth = 1;
  final double _triangleHeight = 10;

  RelativeRect? position;

  @override
  void initState() {
    super.initState();
    position = RelativeRect.fromRect(
      Rect.fromPoints(
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
        widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
      ),
      Offset.zero & widget.overlay.size,
    );
    print(position);
  }

  @override
  Widget build(BuildContext context) {
    // 这里计算出来 当前页的 child 一共有多少个
    int _curPageChildCount = (_curPage + 1) * widget._pageMaxChildCount > widget.actions.length
        ? widget.actions.length % widget._pageMaxChildCount
        : widget._pageMaxChildCount;

    double _curArrowWidth = 0;
    int _curArrowCount = 0; // 一共几个箭头

    if (widget.actions.length > widget._pageMaxChildCount) {
      // 数据长度大于 widget._pageMaxChildCount
      if (_curPage == 0) {
        // 如果是第一页
        _curArrowWidth = _arrowWidth;
        _curArrowCount = 1;
      } else if ((_curPage + 1) * widget._pageMaxChildCount >= widget.actions.length) {
        // 如果不是第一页 则需要也显示左箭头
        _curArrowWidth = _arrowWidth;
        _curArrowCount = 2;
      } else {
        _curArrowWidth = _arrowWidth * 2;
        _curArrowCount = 2;
      }
    }

    double _curPageWidth =
        widget.menuWidth + (_curPageChildCount - 1 + _curArrowCount) * _separatorWidth + _curArrowWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onValueChanged(-1);
      },
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: Builder(
          builder: (BuildContext context) {
            var isInverted = position!.top <= (50) * 2;
            return CustomSingleChildLayout(
              delegate: _PopupMenuRouteLayout(position!, widget.menuHeight + _triangleHeight,
                  Directionality.of(widget.btnContext),  widget.menuWidth, widget._height, widget.leftorright),
              child: SizedBox(
                height: widget.menuHeight + _triangleHeight,
                width: 150,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      isInverted
                          ? Padding(padding: EdgeInsets.only(top: 6), child: CustomPaint(
                        size: Size(_curPageWidth, _triangleHeight),
                        painter: TrianglePainter(
                          color: widget.backgroundColor,
                          position: position!,
                          isInverted: true,
                          size: widget.button.size,
                          screenWidth: MediaQuery.of(context).size.width,
                        ),
                      )) : Container(),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              child: Container(
                                color: widget.backgroundColor,
                                height: widget.menuHeight,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _buildList(_curPageChildCount, _curPageWidth, _curArrowWidth, _curArrowCount),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isInverted
                          ? Container()
                          : Padding(padding: EdgeInsets.only(bottom: 6), child: CustomPaint(
                          size: Size(_curPageWidth, _triangleHeight),
                          painter: TrianglePainter(
                            color: widget.backgroundColor,
                            position: position!,
                            size: widget.button.size,
                            screenWidth: MediaQuery.of(context).size.width,
                          ),)
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(int _curPageChildCount, double _curPageWidth, double _curArrowWidth, int _curArrowCount) {
    List<Widget> lists = [];
    int index = 0;
    widget.actions.forEach((element) {
      lists.add(GestureDetector(
        onTap: () {
          widget.onValueChanged(_curPage * widget._pageMaxChildCount + widget.actions.indexOf(element));
        },
        child: SizedBox(
          width: 50,
          height: widget.menuHeight,
          child: Center(
            child: Text(
              widget.actions[_curPage * widget._pageMaxChildCount + index],
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ));
      index++;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: lists,
    );
  }
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(
      this.position, this.selectedItemOffset, this.textDirection, this.menuWidth, this.height, this.leftorright);

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;
  final int leftorright;
  // The distance from the top of the menu to the middle of selected item.
  //
  // This will be null if there's no item to position in this way.
  final double selectedItemOffset;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  final double height;
  final double menuWidth;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(
        constraints.biggest - const Offset(_kMenuScreenPadding * 2.0, _kMenuScreenPadding * 2.0) as Size);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.
    // Find the ideal vertical position.
    double  y = position.top;
    // Find the ideal horizontal position.
    double   x = position.left + position.right - 150 - 10;

    if(leftorright == 1) {
      if (position.right >= 150) {
        x = (position.left + (position.right - 10) / 2) - (150 / 2) - 10;
      }
      else {
        x = position.left + position.right - 150 - 10;
      }
      y = position.top;

      if (y <= 50 * 2) {
        y = position.top + 23;
      }
      else
        y = position.top - 50;
      return Offset(x, y);
    }

    if(leftorright == 0){
      print(position);

      y = position.top;

      if (y <= 50 * 2) {
        y = position.top + 23;
      }
      else
        y = position.top - 50;
      return Offset(position.left, y);

    }

    return Offset(x, y);

  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}


class TrianglePainter extends CustomPainter {
  Paint? _paint;
  final Color color;
  final RelativeRect position;
  final Size size;
  final double radius;
  final bool isInverted;
  double screenWidth = 0;

  TrianglePainter(
      {required this.color,
        required this.position,
        required this.size,
        this.radius = 9,
        this.isInverted = false,
        this.screenWidth = 0}) {
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 15
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    // 如果 menu 的长度 大于 child 的长度
    if (size.width > this.size.width) {
      // 靠右
      if (position.left + this.size.width / 2 > position.right) {
        if (screenWidth - (position.left + this.size.width) > size.width / 2 + _kMenuScreenPadding) {
          path.moveTo(size.width / 2 -5, isInverted ? 6 : size.height - 6);
          path.lineTo(size.width / 2 - radius / 2 -5, isInverted ? size.height : 0);
          path.lineTo(size.width / 2 + radius / 2 -5, isInverted ? size.height : 0);
        }else {
          path.moveTo(size.width - this.size.width + this.size.width / 2 -5, isInverted ? 6 : size.height - 6);
          path.lineTo(
              size.width - this.size.width + this.size.width / 2 - radius / 2 -5,
              isInverted ? size.height : 0);
          path.lineTo(
              size.width - this.size.width + this.size.width / 2 + radius / 2 -5,
              isInverted ? size.height : 0);
        }
      }
      else{// 靠左
        if(position.left > size.width / 2 + _kMenuScreenPadding){
            path.moveTo(size.width / 2 +5 , isInverted ? 6 : size.height - 6);
            path.lineTo(size.width / 2 - radius / 2+5, isInverted ? size.height : 0);
            path.lineTo(size.width / 2 + radius / 2+5, isInverted ? size.height : 0);
        }
        else {
            path.moveTo(this.size.width / 2 +5, isInverted ? 6: size.height - 6);
            path.lineTo(
                this.size.width / 2 - radius / 2+5, isInverted ? size.height : 0);
            path.lineTo(
                this.size.width / 2 + radius / 2+5, isInverted ? size.height : 0);

          }
        }
    }
    else {
      path.moveTo(size.width / 2, isInverted ? 6 : size.height - 6);
      path.lineTo(
          size.width / 2 - radius / 2, isInverted ? size.height : 0);
      path.lineTo(
          size.width / 2 + radius / 2, isInverted ? size.height : 0);
    }

    path.close();

    canvas.drawPath(
      path,
      _paint!,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

