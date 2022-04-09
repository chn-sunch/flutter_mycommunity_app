import 'package:flutter/material.dart';
import '../../model/activity.dart';
import '../../service/activity.dart';
import '../../util/imhelper_util.dart';
import '../../util/common_util.dart';
import '../../common/iconfont.dart';
import '../../widget/circle_headimage.dart';
import '../../widget/cityphoto_viewgallery.dart';
import '../../widget/shareview.dart';
import '../../widget/icontext.dart';

import '../../global.dart';

class CityActivityWidget extends StatefulWidget {
  Activity activity;

  CityActivityWidget({required this.activity});

  @override
  _CityActivityWidgetState createState() => _CityActivityWidgetState();
}

class _CityActivityWidgetState extends State<CityActivityWidget> {
  bool isEnter = true;
  int maxImgs = 4;
  _CityActivityWidgetState();
  ImHelper _imHelper = new ImHelper();
  bool retLike = false;
  final ActivityService _activityService = new ActivityService();

  @override
  initState(){
    if(Global.profile.user != null){
       _imHelper.selActivityState(widget.activity.actid, Global.profile.user!.uid, (List<String> actid){
        if(actid.length > 0){
          if(mounted){
            setState(() {
              retLike = true;
            });
          }
        }
        else{
          retLike = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> lists = [];


    if(widget.activity.actimagespath != null && widget.activity.actimagespath!.isNotEmpty){
      List<String> paths = widget.activity.actimagespath!.split(',');
      for(int i=0;i<paths.length;i++){
        lists.add({"tag": UniqueKey().toString(),"img": paths[i].toString(), "imgwh": widget.activity.coverimgwh});
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
          child: NoCacheClipRRectHeadImage(imageUrl: widget.activity.user!.profilepicture??"",
            width: 30, uid: widget.activity.user!.uid, cir: 50,),
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
                              Text(widget.activity.user!.username, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14),),
                              SizedBox(height: 3,),
                              Text('${widget.activity.joinnum! + 1}人想参加',style:  TextStyle(color: Colors.black54, fontSize: 12,))
                            ],
                          ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                alignment: Alignment.centerRight,
                                child: CommonUtil.getTextDistance(widget.activity.lat, widget.activity.lng, Global.profile.lat, Global.profile.lng),
                            ),
//                            widgetMoney
                          ],
                        ),
                      )
                    ]
                  ),
                  Padding(padding: EdgeInsets.only(top: 5),),
                  lists.length == 0 ? SizedBox.shrink() : CityPhotoViewGallery(list: lists),
                  Padding(padding: EdgeInsets.only(top: 5),),
                  Text(widget.activity.content, style: TextStyle(color: Colors.black, fontSize: 13),),
                  Padding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          child: ShareView(icon: Icon(IconFont.icon_fenxiang2, color: Colors.black45, size: 16,), image: widget.activity.coverimg, contentid: widget.activity.actid,
                            content: widget.activity.content, sharedtype: "0", actid: widget.activity.actid, createuid: widget.activity.user!.uid,),
                          onTap: (){

                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconText(
                              widget.activity.likenum.toString() == "0" ? '点赞':widget.activity.likenum.toString(),
                              padding: EdgeInsets.only(right: 2),
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                              icon: retLike ? Icon(IconFont.icon_zan1, color: Colors.redAccent,size: 16,): Icon(IconFont.icon_aixin, color: Colors.black54,size: 16,),
                              onTap: () async {
                                if(Global.profile.user == null){
                                  Navigator.pushNamed(context, '/Login');
                                  return;
                                }
                                if(isEnter) {
                                  isEnter = false;
                                  bool ret = false;
                                  if (retLike) {
                                    ret = await _activityService.delLike(
                                        widget.activity.actid,
                                        Global.profile.user!.uid,
                                        Global.profile.user!.token!, () {});
                                    widget.activity.likenum = widget.activity.likenum - 1;
                                    retLike = false;
                                  }
                                  else {
                                    ret = await _activityService.updateLike(
                                        widget.activity.actid,
                                        Global.profile.user!.uid,
                                        Global.profile.user!.token!, () {});
                                    widget.activity.likenum = widget.activity.likenum + 1;
                                    retLike = true;
                                  }
                                  if (ret) {
                                    isEnter = true;
                                    setState(() {});
                                  }
                                }
                              },
                            ),
                            SizedBox(width: 20,),
                            IconText(
                              widget.activity.commentnum.toString() == "0" ? '评论' : widget.activity.commentnum.toString(),
                              padding: EdgeInsets.only(right: 2),
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                              icon: Icon(IconFont.icon_liuyan, color: Colors.black45, size: 16,),
                              onTap: (){
                                Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": widget.activity.actid}).then((val){
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
                Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": widget.activity.actid}).then((val){
                });;
              },
            ),
          ),
        )
      ],
    );



  }
}
