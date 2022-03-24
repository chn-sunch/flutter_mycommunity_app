import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';
import 'dart:ui' show lerpDouble, ImageFilter;
const int _kMaxDroppedSwipePageForwardAnimationTime = 800; // Milliseconds.
const int _kMaxPageBackAnimationTime = 300; // Milliseconds.

/// Fade效果的动画参数(primary)
final Tween<double> _primaryTweenFade = Tween<double>(begin: 0, end: 1.0);

final Tween<double> _secondaryTweenFade = Tween<double>(begin: 1.0, end: 0.0);

/// 动画效果从底部到顶部的参数(primary)
final Tween<Offset> _primaryTweenSlideFromBottomToTop =
Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero);

final Tween<Offset> _secondaryTweenSlideFromBottomToTop =
Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.0));

/// 动画效果从顶部到底部的参数(primary)
final Tween<Offset> _primaryTweenSlideFromTopToBottom =
Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero);

final Tween<Offset> _secondaryTweenSlideFromTopToBottom =
Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0));

/// 动画效果从右边到左边的参数(primary)
final Tween<Offset> _primaryTweenSlideFromRightToLeft =
Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero);

/// 动画效果从右边到左边的参数(secondary)
final Tween<Offset> _secondaryTweenSlideFromRightToLeft =
Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0));

/// 动画效果从左边到右边的参数(primary)
final Tween<Offset> _primaryTweenSlideFromLeftToRight =
Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero);

/// 动画效果从左边到右边的参(secondary)
final Tween<Offset> _secondaryTweenSlideFromLeftToRight =
Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0));

/// 动画类型枚举，`SlideRL`,`SlideLR`,`SlideTB`, `SlideBT`, `Fade`
enum AnimationType {
  /// 从右到左的滑动
  SlideRightToLeft,

  /// 从左到右的滑动
  SlideLeftToRight,

  /// 从上到下的滑动
  SlideTopToBottom,

  /// 从下到上的滑动
  SlideBottomToTop,

  /// 透明过渡
  Fade,
  /// 无任何特效
  NoSpecial

}

/// 页面受影响的类型
enum PageAffectedType {
  /// 都不受影响,无动画
  None,

  /// 进入时
  Enter,

  /// 退出时
  Exit,

  /// 都受影响，进出都有动画
  Both
}

/// 动画路由
class AnimationPageRoute<T> extends PageRoute<T> {
  AnimationPageRoute({
    @required this.builder,
    this.pageAffectedType = PageAffectedType.Both,
    this.animationType = AnimationType.SlideRightToLeft,
    this.animationDuration = const Duration(milliseconds: 230),
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
  })  : assert(builder != null),
        assert(animationType != null),
        assert(maintainState != null),
        assert(fullscreenDialog != null),
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  /// 页面构造
  final WidgetBuilder? builder;
  /// 页面受影响的类型, 默认为[PageAffectedType.Both]
  final PageAffectedType pageAffectedType;

  /// 动画类型
  final AnimationType animationType;

  final Duration animationDuration ;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => animationDuration ;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is AnimationPageRoute && !nextRoute.fullscreenDialog;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final Widget result = builder!(context);
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'The builder for route "${settings.name}" returned null.'),
          ErrorDescription('Route builders must never return null.')
        ]);
      }
      return true;
    }());


    //print(context.toString());

    return Semantics(
        scopesRoute: true, explicitChildNodes: true, child: result);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final Curve curve = Curves.decelerate, reverseCurve = Curves.decelerate;
    if (pageAffectedType == PageAffectedType.None) return child;
    if (animationType == AnimationType.Fade)
      return _buildFadeTransitionAnimateWidget(animation, secondaryAnimation,
          curve, reverseCurve, _primaryTweenFade, _secondaryTweenFade, child);
    final TextDirection textDirection = Directionality.of(context);
    Tween<Offset> primaryTween = _primaryTweenSlideFromRightToLeft,
        secondaryTween = _secondaryTweenSlideFromRightToLeft;
    if (animationType == AnimationType.SlideLeftToRight) {
      primaryTween = _primaryTweenSlideFromLeftToRight;
      secondaryTween = _secondaryTweenSlideFromLeftToRight;
    } else if (animationType == AnimationType.SlideBottomToTop) {
      primaryTween = _primaryTweenSlideFromBottomToTop;
      secondaryTween = _secondaryTweenSlideFromBottomToTop;
    } else if (animationType == AnimationType.SlideTopToBottom) {
      primaryTween = _primaryTweenSlideFromTopToBottom;
      secondaryTween = _secondaryTweenSlideFromTopToBottom;
    }
    return _buildSlideTransitionAnimateWidget(
        animation,
        secondaryAnimation,
        curve,
        reverseCurve,
        primaryTween,
        secondaryTween,
        textDirection,
        child);
  }

  Widget _buildFadeTransitionAnimateWidget(
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Curve curve,
      Curve reverseCurve,
      Tween<double> primaryTween,
      Tween<double> secondaryTween,
      Widget child) {
    Animation<double> childAnimation = CurvedAnimation(
      parent: pageAffectedType != PageAffectedType.Exit
          ? animation
          : secondaryAnimation,
      curve: curve,
      reverseCurve: reverseCurve,
    ).drive(pageAffectedType != PageAffectedType.Exit
        ? primaryTween
        : secondaryTween);
    Widget childAnimWidget =
    FadeTransition(opacity: childAnimation, child: child);
    if (pageAffectedType != PageAffectedType.Both) return childAnimWidget;
    return FadeTransition(
        opacity: CurvedAnimation(
          parent: secondaryAnimation,
          curve: curve,
          reverseCurve: reverseCurve,
        ).drive(secondaryTween),
        child: childAnimWidget);
  }

  Widget _buildSlideTransitionAnimateWidget(
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Curve curve,
      Curve reverseCurve,
      Tween<Offset> primaryTween,
      Tween<Offset> secondaryTween,
      TextDirection textDirection,
      Widget child) {
    Animation<Offset> childAnimation = CurvedAnimation(
      parent: pageAffectedType != PageAffectedType.Exit
          ? animation
          : secondaryAnimation,
      curve: curve,
      reverseCurve: reverseCurve,
    ).drive(pageAffectedType != PageAffectedType.Exit
        ? primaryTween
        : secondaryTween);
    Widget childAnimWidget = SlideTransition(
        position: childAnimation, textDirection: textDirection, child: child);
    if (pageAffectedType != PageAffectedType.Both) return childAnimWidget;
    return SlideTransition(
        position: CurvedAnimation(
          parent: secondaryAnimation,
          curve: curve,
          reverseCurve: reverseCurve,
        ).drive(secondaryTween),
        textDirection: textDirection,
        child: childAnimWidget);
  }


  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

/// 单一动画路由，指只有EnterPage才有的动画路由
class UnitaryAnimationPageRoute<T> extends PageRouteBuilder<T> {
  UnitaryAnimationPageRoute({
    @required this.builder,
    this.pageAffectedType = PageAffectedType.Enter,
    this.animationType = AnimationType.SlideRightToLeft,
    RouteSettings? settings,
    Duration animationDuration = const Duration(milliseconds: 250),
    bool opaque = true,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
    bool maintainState = true,
    bool fullscreenDialog = false,
  })  : assert(builder != null),
        assert(pageAffectedType != null &&
            pageAffectedType != PageAffectedType.Both),
        assert(opaque != null),
        assert(barrierDismissible != null),
        assert(maintainState != null),
        assert(fullscreenDialog != null),
        super(
          settings: settings,
          pageBuilder: (ctx, _, __) => builder!(ctx),
          transitionsBuilder: (ctx, animation, secondaryAnimation, __) {
            Widget page = builder!(ctx);
            if (pageAffectedType == PageAffectedType.None) return page;
            Animation<double> targetAnimation = pageAffectedType  ==
                PageAffectedType.Enter
                ? animation
                : secondaryAnimation;
            switch (animationType) {
              case AnimationType.Fade:
                return _buildFadeTransition(
                    pageAffectedType, targetAnimation, page);
              case AnimationType.NoSpecial:
                return page;
              case AnimationType.SlideBottomToTop:
              case AnimationType.SlideTopToBottom:
                return _buildVerticalTransition(
                    pageAffectedType, targetAnimation, animationType, page);
              case AnimationType.SlideLeftToRight:
              case AnimationType.SlideRightToLeft:
                return _buildHorizontalTransition(
                    pageAffectedType, targetAnimation, animationType, page);
              default:
                return page;
            }
          },
          transitionDuration: animationDuration,
          opaque: opaque,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog);

  /// 页面构建
  final WidgetBuilder? builder;

  /// 页面受影响的类型
  final PageAffectedType pageAffectedType;

  /// 动画类型
  final AnimationType animationType;

  /// 构建Fade效果的动画
  static FadeTransition _buildFadeTransition(PageAffectedType affectedType,
      Animation<double> animation, Widget child) =>
      FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.decelerate,
            reverseCurve: Curves.decelerate,
          ).drive(affectedType == PageAffectedType.Enter
              ? _primaryTweenFade
              : _secondaryTweenFade),
          child: child);

  /// 构建上下向的动画
  static SlideTransition _buildVerticalTransition(PageAffectedType affectedType,
      Animation<double> animation, AnimationType animType, Widget child) =>
      SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.decelerate,
            reverseCurve: Curves.decelerate,
          ).drive(animType == AnimationType.SlideBottomToTop
              ? (affectedType == PageAffectedType.Enter
              ? _primaryTweenSlideFromBottomToTop
              : _secondaryTweenSlideFromBottomToTop)
              : (affectedType == PageAffectedType.Enter
              ? _primaryTweenSlideFromTopToBottom
              : _secondaryTweenSlideFromTopToBottom)),
          child: child);

  /// 构建左右向的动画
  static SlideTransition _buildHorizontalTransition(
      PageAffectedType affectedType,
      Animation<double> animation,
      AnimationType animType,
      Widget child) =>
      SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.decelerate,
            reverseCurve: Curves.decelerate,
          ).drive(animType == AnimationType.SlideLeftToRight
              ? (affectedType == PageAffectedType.Enter
              ? _primaryTweenSlideFromLeftToRight
              : _secondaryTweenSlideFromLeftToRight)
              : (affectedType == PageAffectedType.Enter
              ? _primaryTweenSlideFromRightToLeft
              : _secondaryTweenSlideFromRightToLeft)),
          child: child);
}

//没有动画,直接切换
class UnitaryCupertinoPageRoute<T> extends CupertinoPageRoute<T>  {
  UnitaryCupertinoPageRoute({ WidgetBuilder? builder, RouteSettings? settings })
      : super(builder: builder!, settings: settings);

  @override
  buildTransitions(context, animation, secondaryAnimation, __){
    Widget page = builder(context);
    return super.buildMyTransitions(context, animation, secondaryAnimation, page);
    //return super.buildTransitions(context, animation, secondaryAnimation, page);原来使用的IOS动画
  }

//修改flutter的源文件,flutter版本更新后需要添加代码
//  @override
//  Widget buildMyTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
//    return buildMyPageTransitions<T>(this, context, animation, secondaryAnimation, child);
//  }

//创建一个自定义的ios动画，没有任何特效直接切换页面
//  static Widget buildMyPageTransitions<T>(
//      PageRoute<T> route,
//      BuildContext context,
//      Animation<double> animation,
//      Animation<double> secondaryAnimation,
//      Widget child,
//      ) {
//    return _CupertinoBackGestureDetector<T>(
//        enabledCallback: () => _isPopGestureEnabled<T>(route),
//        onStartPopGesture: () => _startPopGesture<T>(route),
//        child: child,
//
//    );
//  }
}
