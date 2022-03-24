import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

import '../service/commonjson.dart';
import '../global.dart';

class HtmlContent extends StatefulWidget {
  Object? arguments;
  String parameterkey = "";
  String title = "";

  HtmlContent({this.arguments}){
    if(arguments != null){
      Map map = arguments as Map;
      parameterkey = map["parameterkey"];
      title = map["title"];
    }
  }

  @override
  _HtmlContentState createState() => _HtmlContentState();
}

class _HtmlContentState extends State<HtmlContent> {

  String htmlData = "";
  CommonJSONService _commonJSONService = new  CommonJSONService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _commonJSONService.getHtmlContent((Map<String, dynamic> data){
      if(data!= null && data["data"] != null) {
        setState(() {
          htmlData = data["data"]["value"];
        });
      }
    }, widget.parameterkey);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(widget.title, style: TextStyle(fontSize: 16, color: Colors.black),),
        centerTitle: true,
      ),

      body: htmlData == null ? indicator() : MediaQuery.removePadding(
          context: this.context,
          removeTop: true,
          child: ListView(
            children: [
              Html(
                data: htmlData,
                //Optional parameters:
                style: {
                  "html": Style(
                    backgroundColor: Colors.white,
//              color: Colors.white,
                  ),
//            "h1": Style(
//              textAlign: TextAlign.center,
//            ),
                  "table": Style(
                    backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                  ),
                  "tr": Style(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  "th": Style(
                    padding: EdgeInsets.all(6),
                    backgroundColor: Colors.grey,
                  ),
                  "td": Style(
                    padding: EdgeInsets.all(6),
                  ),
                  "var": Style(fontFamily: 'serif'),
                },

                onImageError: (exception, stackTrace) {
                  print(exception);
                },
              )
            ],
          )),
    );
  }

  Widget indicator(){
    return Center(
      child: CircularProgressIndicator(
        valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
      ),
    );
  }
}
