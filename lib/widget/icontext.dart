import 'package:flutter/material.dart';

/// icon text
class IconText extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final double? iconSize;
  final Axis? direction;
  /// icon padding
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final int? maxLines;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final Function? onTap;

  const IconText(this.text,
      {Key? key,
        this.icon,
        this.iconSize,
        this.direction = Axis.horizontal,
        this.style,
        this.maxLines,
        this.softWrap,
        this.padding,
        this.textAlign,
        this.overflow = TextOverflow.ellipsis, this.onTap})
      : assert(direction != null),
        assert(overflow != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: buildContent(),
      onTap: (){
        if(onTap != null) {
          onTap!();
        }
      },
    );
  }

  Widget? buildContent(){
    return icon == null ? Text(text ?? '', style: style) : text == null || text!.isEmpty ? (padding == null ? icon : Padding(padding: padding!, child: icon))
        : RichText(
      text: TextSpan(style: style, children: [
        WidgetSpan(
            child: IconTheme(
              data: IconThemeData(
                  size: iconSize ??
                      (style == null || style!.fontSize == null
                          ? 16
                          : style!.fontSize! + 1),
                  color: style == null ? null : style!.color),
              child: padding == null
                  ? icon!
                  : Padding(
                padding: padding!,
                child: icon,
              ),
            )),

        TextSpan(
            text: direction == Axis.horizontal ? text : "\n$text", style: style),
      ]),
      maxLines: maxLines,
      softWrap: softWrap ?? true,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign ?? (direction == Axis.horizontal ? TextAlign.start : TextAlign.center),
    );
  }
}