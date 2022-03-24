import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/src/tweens/delay_tween.dart';

enum MySpinKitWaveType { start, end, center }

class MySpinKitWave extends StatefulWidget {
  const MySpinKitWave({
    Key? key,
    this.color,
    this.type = MySpinKitWaveType.start,
    this.size = 50.0,
    this.itemBuilder,
    this.itemCount = 5,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  })  : assert(!(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
  'You should specify either a itemBuilder or a color'),
        assert(itemCount != null && itemCount >= 2, 'itemCount Cant be less then 2 '),
        assert(type != null),
        assert(size != null),
        super(key: key);

  final Color? color;
  final int itemCount;
  final double size;
  final MySpinKitWaveType type;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration duration;
  final AnimationController? controller;

  @override
  _SpinKitWaveState createState() => _SpinKitWaveState();
}

class MySpinKitWaveStop extends StatefulWidget {
  const MySpinKitWaveStop({
    Key? key,
    this.color,
    this.type = MySpinKitWaveType.start,
    this.size = 50.0,
    this.itemBuilder,
    this.itemCount = 5,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  })  : assert(!(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
  'You should specify either a itemBuilder or a color'),
        assert(itemCount != null && itemCount >= 2, 'itemCount Cant be less then 2 '),
        assert(type != null),
        assert(size != null),
        super(key: key);

  final Color? color;
  final int itemCount;
  final double size;
  final MySpinKitWaveType type;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration duration;
  final AnimationController? controller;

  @override
  _SpinKitWaveStopState createState() => _SpinKitWaveStopState();
}

class _SpinKitWaveState extends State<MySpinKitWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))..repeat();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<double> _bars = getAnimationDelay(widget.itemCount);
    return Center(
      child: SizedBox.fromSize(
        size: Size(30, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_bars.length, (i) {
            return ScaleYWidget(
              scaleY: DelayTween(begin: .4, end: 1.0, delay: _bars[i]).animate(_controller),
              child: SizedBox.fromSize(size: Size(3, widget.size), child: _itemBuilder(i)),
            );
          }),
        ),
      ),
    );
  }

  List<double> getAnimationDelay(int itemCount) {
    switch (widget.type) {
      case MySpinKitWaveType.start:
        return _startAnimationDelay(itemCount);
      case MySpinKitWaveType.end:
        return _endAnimationDelay(itemCount);
      case MySpinKitWaveType.center:
      default:
        return _centerAnimationDelay(itemCount);
    }
  }

  List<double> _startAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(count ~/ 2, (index) => -1.0 - (index * 0.1) - 0.1).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
            (index) => -1.0 + (index * 0.1) + (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  List<double> _endAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(count ~/ 2, (index) => -1.0 + (index * 0.1) + 0.1).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
            (index) => -1.0 - (index * 0.1) - (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  List<double> _centerAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(count ~/ 2, (index) => -1.0 + (index * 0.2) + 0.2).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(count ~/ 2, (index) => -1.0 + (index * 0.2) + 0.2),
    ];
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(decoration: BoxDecoration(color: widget.color));
}

class _SpinKitWaveStopState extends State<MySpinKitWaveStop> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))..repeat();
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<double> _bars = getAnimationDelay(widget.itemCount);
    return Center(
      child: SizedBox.fromSize(
        size: Size(30, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_bars.length, (i) {
            return ScaleYWidget(
              scaleY: DelayTween(begin: .4, end: 1.0, delay: _bars[i]).animate(_controller),
              child: SizedBox.fromSize(size: Size(3, widget.size), child: _itemBuilder(i)),
            );
          }),
        ),
      ),
    );
  }

  List<double> getAnimationDelay(int itemCount) {
    switch (widget.type) {
      case MySpinKitWaveType.start:
        return _startAnimationDelay(itemCount);
      case MySpinKitWaveType.end:
        return _endAnimationDelay(itemCount);
      case MySpinKitWaveType.center:
      default:
        return _centerAnimationDelay(itemCount);
    }
  }

  List<double> _startAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(count ~/ 2, (index) => -1.0 - (index * 0.1) - 0.1).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
            (index) => -1.0 + (index * 0.1) + (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  List<double> _endAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(count ~/ 2, (index) => -1.0 + (index * 0.1) + 0.1).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
            (index) => -1.0 - (index * 0.1) - (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  List<double> _centerAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(count ~/ 2, (index) => -1.0 + (index * 0.2) + 0.2).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(count ~/ 2, (index) => -1.0 + (index * 0.2) + 0.2),
    ];
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(decoration: BoxDecoration(color: widget.color));
}


class ScaleYWidget extends AnimatedWidget {
  ScaleYWidget({
    Key? key,
    required Animation<double> scaleY,
    required this.child,
    this.alignment = Alignment.center,
  }) : super(key: key, listenable: scaleY);

  Widget child;
  final Alignment alignment;

  Animation<double> get scale => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform(transform: Matrix4.identity()..scale(1.0, scale.value, 1.0), alignment: alignment, child: child);
  }
}
