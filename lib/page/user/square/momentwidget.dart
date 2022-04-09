import 'package:flutter/material.dart';

import '../../../global.dart';
import '../../../model/bugsuggestion/moment.dart';
import '../../../service/imservice.dart';
import '../../../util/showmessage_util.dart';
import '../../../common/iconfont.dart';
import '../../../widget/circle_headimage.dart';
import '../../../widget/icontext.dart';
import '../../../widget/cityphoto_viewgallery.dart';
import '../../../widget/photo/playvoice.dart';

class MomentWidget extends StatefulWidget {
  Moment moment;
  Function refresh;

  MomentWidget({required this.moment, required this.refresh});

  @override
  _MomentWidgetState createState() => _MomentWidgetState();
}

class _MomentWidgetState extends State<MomentWidget> {
  bool isEnter = true;
  int maxImgs = 4;
  _MomentWidgetState();

  final ImService _imService = new ImService();

  @override
  initState(){

  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> lists = [];


    if(widget.moment.images != null && widget.moment.images.isNotEmpty){
      List<String> paths = widget.moment.images.split(',');
      for(int i=0;i<paths.length;i++){
        lists.add({"tag": UniqueKey().toString(),"img": paths[i].toString(), "imgwh": widget.moment.coverimgwh});
        if(i == maxImgs -1){
          break;
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 45,
          child: NoCacheClipRRectHeadImage(imageUrl: widget.moment.user!.profilepicture??"",
            width: 30, uid: widget.moment.user!.uid, cir: 50,),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 10, right: 30),
            child: InkWell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.moment.user!.username, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14),),

                                ],
                              ),
                              SizedBox(height: 3,),
                              Text('${widget.moment.user!.signature}',style:  TextStyle(color: Colors.black54, fontSize: 12, ), maxLines: 1, overflow: TextOverflow.ellipsis,)
                            ],
                          ),
                      ),
                    ]
                  ),
                  Padding(padding: EdgeInsets.only(top: 5),),
                  widget.moment.voice != "" ? PlayVoice( widget.moment.voice): SizedBox(),
                  lists.length == 0 ? SizedBox.shrink() : CityPhotoViewGallery(list: lists),
                  Padding(padding: EdgeInsets.only(top: 5),),
                  Text(widget.moment.content, style: TextStyle(color: Colors.black, fontSize: 13),),
                  Padding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox.shrink(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconText(
                              widget.moment.likenum.toString() == "0" ? '点赞':widget.moment.likenum.toString(),
                              padding: EdgeInsets.only(right: 2),
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                              icon: widget.moment.islike ? Icon(IconFont.icon_zan1, color: Colors.redAccent,size: 16,):
                              Icon(IconFont.icon_aixin, color: Colors.black54,size: 16,),
                              onTap: () async {
                                if(Global.profile.user == null){
                                  Navigator.pushNamed(context, '/Login');
                                  return;
                                }
                                if(isEnter) {
                                  isEnter = false;
                                  bool ret = false;
                                  if (widget.moment.islike) {
                                    ret = await _imService.delMomentLike(widget.moment.momentid,
                                        Global.profile.user!.uid,
                                        Global.profile.user!.token!, errorResponse);
                                    widget.moment.likenum = widget.moment.likenum - 1;
                                    widget.moment.islike = false;
                                  }
                                  else {
                                    ret = await _imService.updateMomentLike(
                                        widget.moment.momentid,
                                        Global.profile.user!.uid,
                                        Global.profile.user!.token!, errorResponse);
                                    widget.moment.likenum = widget.moment.likenum + 1;
                                    widget.moment.islike = true;
                                  }
                                  if (ret) {
                                    isEnter = true;
                                    setState(() {

                                    });
                                  }
                                }
                              },
                            ),
                            SizedBox(width: 20,),
                            IconText(
                              widget.moment.commentcount.toString() == "0" ? '评论' : widget.moment.commentcount.toString(),
                              padding: EdgeInsets.only(right: 2),
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                              icon: Icon(IconFont.icon_liuyan, color: Colors.black45, size: 16,),
                              onTap: (){
                                Navigator.pushNamed(context, '/MomentInfo', arguments: {"momentid": widget.moment.momentid}).then((val){
                                  setState(() {

                                  });
                                });
                              },
                            ),
                          ],
                        )

                      ],
                    ),
                    padding: EdgeInsets.all(10),
                  )
                ],
              ),
              onTap: (){
                Navigator.pushNamed(context, '/MomentInfo', arguments: {"momentid": widget.moment.momentid}).then((val){
                  if(val == "refresh"){
                    widget.refresh();
                  }
                });;
              },
            ),
          ),
        )
      ],
    );
  }

  errorResponse(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}
