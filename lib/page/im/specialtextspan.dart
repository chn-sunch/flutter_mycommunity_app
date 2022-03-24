import 'package:extended_text/extended_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../widget/circle_headimage.dart';

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  MySpecialTextSpanBuilder({this.showAtBackground = false,  this.isplay = false, this.pagewidth = 0, this.isText = false, this.myonTap,
    this.isopen = false});

  /// whether show background for @somebody
  final bool showAtBackground;
  final bool isplay;
  final bool isText;
  final bool isopen;//是否打开过红包
  final double pagewidth;
  final myonTap; //

  @override
  TextSpan build(String data,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    if (kIsWeb) {
      return TextSpan(text: data, style: textStyle);
    }

    return super.build(data, textStyle: textStyle, onTap: onTap);
  }

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {
    if (flag == null || flag == '') {
      return null;
    }
    if(textStyle == null){
      textStyle = TextStyle(color: Colors.black87, fontSize: 13);
    }

    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle,
          start: index - (EmojiText.flag.length - 1));
    }
    else if (isStart(flag, AtText.flag)) {
      return AtText(
        textStyle,
        onTap,
        start: index - (AtText.flag.length - 1),
        showAtBackground: showAtBackground,
      );
    }
    else if (isStart(flag, SoundText.flag)) {
      return SoundText(textStyle, null,
          start: index - (EmojiText.flag.length - 1), isplay: this.isplay, isText: this.isText );
    }
    else if (isStart(flag, ImageText.flag)) {
      return ImageText(textStyle, null,
          start: index - (EmojiText.flag.length - 1), isText: this.isText, pageWidth: this.pagewidth);
    }
    else if (isStart(flag, LocationText.flag)) {
      return LocationText(textStyle, null,
          start: index - (LocationText.flag.length - 1), isText: this.isText, pageWidth: this.pagewidth);
    }
    else if (isStart(flag, SharedText.flag)){
      return SharedText(textStyle, myonTap,
        start: index - (SharedText.flag.length - 1), isText: this.isText, pageWidth: this.pagewidth, );
    }
    else if (isStart(flag, RedPacketText.flag)){
      return RedPacketText(textStyle, myonTap,
        start: index - (EmojiText.flag.length - 1), isText: this.isText, isopen: this.isopen, pageWidth: this.pagewidth, );
    }
    return null;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class EmojiText extends SpecialText {
  EmojiText(TextStyle textStyle, {this.start = 0})
      : super(EmojiText.flag, ']', textStyle);
  static const String flag = '[';
  final int start;
  @override
  InlineSpan finishText() {
    final String key = toString();

    ///https://github.com/flutter/flutter/issues/42086
    /// widget span is not working on web
    if (EmojiUitl.instance.emojiMap.containsKey(key) && !kIsWeb) {
      //fontsize id define image height
      //size = 30.0/26.0 * fontSize
      const double size = 20.0;

      ///fontSize 26 and text height =30.0
      //final double fontSize = 26.0;
      return ImageSpan(
          AssetImage(
            EmojiUitl.instance.emojiMap[key]??"images/emoji/8.png",
          ),
          actualText: key,
          imageWidth: size,
          imageHeight: size,
          start: start,
          fit: BoxFit.fill,
          margin: const EdgeInsets.only(left: 2.0, top: 2.0, right: 2.0));
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}

class AtText extends SpecialText {
  AtText(TextStyle textStyle,  SpecialTextGestureTapCallback? onTap,
      {this.showAtBackground = false, this.start = 0})
      : super(flag, ' ', textStyle, onTap: onTap);
  static const String flag = '@';
  final int start ;

  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  InlineSpan finishText() {
    final TextStyle textStyle = this.textStyle!.copyWith();
    final String atText = toString();

    Paint paint=new Paint();
    paint.color = Colors.white;

    return showAtBackground ? BackgroundTextSpan(
      background: paint,
      text: atText,
      actualText: atText,
      start: start,
      ///caret can move into special text
      deleteAll: true,
      style: textStyle,
      recognizer: (TapGestureRecognizer()
        ..onTap = () {
          if (onTap != null) {
            onTap!(atText);
          }
        }))
      : SpecialTextSpan(
        text: atText,
        actualText: atText,
        start: start,
        style: textStyle,
        recognizer: (TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) {
              onTap!(atText);
            }
          }));
  }
}

class SoundText extends SpecialText{
  SoundText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap,
      {this.showAtBackground = false, this.start, this.isplay, this.isText = false})
      : super(flag, '|', textStyle, onTap: onTap);
  static const String flag = '|sound: ';
  static const String flag_img = '|img: ';

  final bool? isplay;
  final int? start;
  final bool isText;

  /// whether show background for @somebody
  final bool showAtBackground;

  Widget webContent= SizedBox.shrink();

  @override
  InlineSpan finishText() {
    String key = toString();
    key = key.replaceAll(flag, '');
    key = key.replaceAll('|', '');

    List<String> soundinfo = key.split('#');
    if(!isText){
      webContent = Container(
        width: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('${soundinfo[0]}s', style: textStyle,),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
          ],
        ),
      );
    }
    else{
      webContent = Text("[语音${soundinfo[0]}s]", style: TextStyle(color: Colors.black45, fontSize: 13),);
    }
    //print(isplay);
    // TODO: implement finishText
    return ExtendedWidgetSpan(
        child:  webContent
    );
  }
}

class ImageText extends SpecialText{
  ImageText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap,
      {this.showAtBackground = false, this.start,  this.pageWidth = 0, this.isText = false})
      : super(flag, '|', textStyle, onTap: onTap);
  static const String flag = '|img: ';
  final bool isText;//是否显示图片
  final int? start;
  final double pageWidth;
  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  InlineSpan finishText() {
    String key = toString();
    key = key.replaceAll(flag, '');
    key = key.replaceAll('|', '');
    List<String> imginfo = key.split('#');

    Widget webContent = SizedBox.shrink();
    if(isText){
      webContent = Text("[图片]", style:  TextStyle(color: Colors.black45, fontSize: 13),);
    }
    else{
      webContent = Container(
        alignment: Alignment.centerLeft,
        width: pageWidth-10,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(child:
              isText ? Text("[图片]", style:  TextStyle(color: Colors.black45, fontSize: 13),) : ClipRRectOhterHeadImageContainerByWidthNoEventNoHeight(
                imageUrl: '${imginfo[0]}', pagewidth: pageWidth-50, sourceWidth: double.parse(imginfo[1].split(',')[0]), sourceHeight: double.parse(imginfo[1].split(',')[1]),)
              ),
            ]
        ),
      );
    }

    // TODO: implement finishText
    return ExtendedWidgetSpan(
        child: webContent
    );
  }

}

class LocationText extends SpecialText{
  LocationText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap,
      {this.showAtBackground = false, this.start,  this.pageWidth = 0, this.isText = false})
      : super(flag, '|', textStyle, onTap: onTap);
  static const String flag = '|location: ';
  final bool isText;//是否显示图片
  final int? start;
  final double pageWidth;
  /// whether show background for @somebody
  final bool showAtBackground;


  @override
  InlineSpan finishText() {
    String key = toString();
    key = key.replaceAll(flag, '');
    key = key.replaceAll('|', '');
    List<String> locatoninfo = key.split('#');
    String lat = locatoninfo[4].split(':')[1].toString();
    String lng = locatoninfo[5].split(':')[1].toString();


    Widget webContent = SizedBox.shrink();
    if(isText){
      webContent = Text("[位置]", style: TextStyle(color: Colors.black45, fontSize: 13),);
    }
    else{
      webContent = Container(
        width: pageWidth + 30,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(child:
              isText ? Text("[位置]", style: TextStyle(color: Colors.black45, fontSize: 13),) : InkWell(
                child: Container(
                  padding: EdgeInsets.all(3),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      locatoninfo[3].split(":")[1].isNotEmpty ?
                      Container(
                        child: Text(locatoninfo[3].split(":")[1], style: TextStyle(color: Colors.black87, fontSize: 14), maxLines: 1, ),
                      ) : SizedBox.shrink(),
                      Container(
                        child: Text(locatoninfo[2].split(":")[1], style: TextStyle(color: Colors.grey.shade500, fontSize: 12, ), maxLines: 1, ),
                      ),
                      ClipRRectOhterHeadImageContainerLocationNoEvent(imageUrl: '${locatoninfo[0]}',
                        width: pageWidth + 29, height: 160, lat: lat, lng: lng, title: locatoninfo[3].split(":")[1], address: locatoninfo[2].split(":")[1],)
                    ],
                  ),
                ),
              )
              ),
            ]
        ),
      );
    }

    // TODO: implement finishText
    return ExtendedWidgetSpan(
        child: webContent
    );
  }
}

class SharedText extends SpecialText{
  SharedText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap,
      {this.showAtBackground = false, this.start,  this.pageWidth = 0, this.isText = false})
      : super(flag, '|', textStyle, onTap: onTap);

  static const String flag = '|shared: ';
  final bool isText;//是否显示图片
  final int? start;
  final double pageWidth;
  /// whether show background for @somebody
  final bool showAtBackground;


  @override
  InlineSpan finishText() {
    String key = toString();
    key = key.replaceAll(flag, '');
    key = key.replaceAll('|', '');
    List<String> sharedinfo = key.split('#');
    String sharedtype = sharedinfo[0];//分享类型 0 活动 1商品
    String contentid = sharedinfo[1];
    String content = sharedinfo[2];
    String image = sharedinfo[3];

    Widget webContent = SizedBox.shrink();
    if(isText){
      webContent = Text("[分享]", style: TextStyle(color: Colors.black45, fontSize: 13),);
    }
    else{
      webContent = Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey.shade200,
        child: Container(
          width: pageWidth + 30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRectOhterHeadImageContainer(imageUrl: image,
                width: pageWidth + 29, height: pageWidth + 30,),
              SizedBox(height: 3,),
              Container(
                width: pageWidth + 29,
                child: Text(content, style: TextStyle(color: Colors.black87, fontSize: 13, overflow: TextOverflow.ellipsis), maxLines: 2, ),
              ),
            ],
          ),
        ),
      );
    }

    // TODO: implement finishText
    return ExtendedWidgetSpan(
        child: webContent
    );
  }
}

class RedPacketText extends SpecialText{
  RedPacketText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap,
      {this.showAtBackground = false, this.start,  this.pageWidth = 0, this.isopen = false, this.isText = true})
      : super(flag, '|', textStyle, onTap: onTap);

  static const String flag = '|sendredpacket:';
  final bool isText;//是否显示图片
  final int? start;
  final bool isopen;
  final double pageWidth;
  /// whether show background for @somebody
  final bool showAtBackground;


  @override
  InlineSpan finishText() {
    String key = toString();
    key = key.replaceAll(flag, '');
    key = key.replaceAll('|', '');
    List<String> sharedinfo = key.split("#");
    String content = sharedinfo[0];//分享类型 0 活动 1商品 2拼玩
    String redpacketid = sharedinfo[1];
    String redpackettype = sharedinfo[2];//0拼手气红包 1普通红包
    String status = isopen ? "" : "";

    if(content == ""){
      content = "恭喜发财，大吉大利asdasdasd";//临时测试用
    }
    Widget webContent = SizedBox.shrink();
    if(isText){
      webContent = Text("[红包]", style: TextStyle(color: Colors.black45, fontSize: 13),);
    }
    else{
      webContent = Container(
        width: pageWidth+30,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(child:Container(
                  height: 99,
                  decoration: new BoxDecoration(
                      color: isopen ? Colors.deepOrangeAccent.shade100 : Colors.deepOrange,
                      borderRadius: new BorderRadius.circular((5.0))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image(
                              image: isopen ? AssetImage("images/redpacket_open.png",) : AssetImage("images/redpacket_close.png",),
                              fit: BoxFit.cover,
                              width: 39,
                              height: 39,
                            ),
                            SizedBox(width: 5,),
                            Expanded(
                              child: Container(
                                child: Text(content, style: TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis,),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
                        height: 29,
                        width: pageWidth+30,
                        color: Colors.white,
                        child: Text(redpackettype=="0"?"拼手气红包${status}":"普通红包${status}", style: TextStyle(color: Colors.black45, fontSize: 12, ),),
                      ),
                    ],
                  )
              )),
            ]
        ),
      );
    }

    // TODO: implement finishText
    return ExtendedWidgetSpan(
        child: webContent
    );
  }
}

class EmojiUitl {
  EmojiUitl._() {
    for (int i = 1; i < 65; i++) {
      _emojiMap['[$i]'] = '$_emojiFilePath/$i.png';
    }
  }

  final Map<String, String> _emojiMap = <String, String>{};

  Map<String, String> get emojiMap => _emojiMap;

  final String _emojiFilePath = 'images/emoji';

  static EmojiUitl? _instance;
  static EmojiUitl get instance => _instance ??= EmojiUitl._();
}


