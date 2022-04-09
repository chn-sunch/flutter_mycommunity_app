import 'package:flutter/material.dart';

import '../../../model/user.dart';
import '../../../model/bugsuggestion/moment.dart';
import '../../../util/imhelper_util.dart';
import '../../../util/showmessage_util.dart';
import '../../../common/iconfont.dart';
import '../../../service/imservice.dart';
import '../../../widget/icontext.dart';
import '../../../widget/photo/playvoice.dart';
import '../../../widget/cityphoto_viewgallery.dart';

import '../../../global.dart';

class MyMoment extends StatefulWidget{
  final User user;
  bool isScroll;
  bool isAppbar;//是否有appbar的页面，默认是在个人主页中使用的无appbar
  Function? srollChange;
  MyMoment({required this.user, this.isScroll = false, this.srollChange, this.isAppbar=false}){

  }

  @override
  _MyMomentState createState() => _MyMomentState();
}

class _MyMomentState extends State<MyMoment>  with  AutomaticKeepAliveClientMixin  {
  List<Moment> moments = [];
  ImService _imService = new ImService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMomentList();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  bool get wantKeepAlive => true;

  void _getMomentList() async {
    moments = await _imService.getMomentListByUser(widget.user.uid, errorCallBack);

    if(mounted)
      setState(() {

      });
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: buildContent(),
    );
  }

  Widget buildContent(){
    return Padding(padding: EdgeInsets.only(top: 3), child: moments.length == 0 ?
      Center(child: Text('这里什么也没有', style:  TextStyle(color: Colors.black54, fontSize: 14, )),) : Container(
        color: Colors.white,
        child: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Container(
              child: ListView.builder(
                addAutomaticKeepAlives: true,
                itemBuilder: (BuildContext context, int index) {
                  return MomentWidget(moment: moments[index]);
                },
                itemCount: moments.length,
              ),
            )
        )),);
  }

  errorCallBack(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }
}


class MomentWidget extends StatefulWidget {
  final Moment moment;

  MomentWidget({required this.moment});

  @override
  _MomentWidgetState createState() => _MomentWidgetState(moment);


}

class _MomentWidgetState extends State<MomentWidget> {
  Moment moment;
  bool retLike = false;
  ImHelper _imHelper = new ImHelper();
  ImService _imService = new ImService();
  bool isEnter = true;

  _MomentWidgetState(this.moment);

  @override
  initState(){
    if(Global.profile.user != null){
      _imHelper.selActivityState(this.moment.momentid, Global.profile.user!.uid, (List<String> actid){
        if(actid.length > 0){
          setState(() {
            retLike = true;
          });
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

    if(moment.images != null && moment.images.isNotEmpty){
      List<String> paths = moment.images.split(',');
      for(int i=0;i<paths.length;i++){
        lists.add({"tag": UniqueKey().toString(),"img": paths[i].toString(), "imgwh": widget.moment.coverimgwh});
      }
    }
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(moment.createtime, style: TextStyle(color: Colors.black45, fontSize: 13),),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 5),),
          InkWell(
            child: Container(
              width: double.infinity,
              child: Text(moment.content, style: TextStyle(color: Colors.black87, fontSize: 13),),
            ),
            onTap: (){
              Navigator.pushNamed(context, '/MomentInfo', arguments: {"momentid": moment.momentid});
            },
          ),
          Padding(padding: EdgeInsets.only(top: 5),),
          widget.moment.voice != "" ? PlayVoice( widget.moment.voice): SizedBox(),
          lists.length == 0 ? SizedBox.shrink() : CityPhotoViewGallery(list: lists),
          Padding(padding: EdgeInsets.only(top: 10),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconText(
                    moment.likenum.toString() == "0" ? '点赞':moment.likenum.toString(),
                    padding: EdgeInsets.only(right: 2),
                    style: TextStyle(color: Colors.black45, fontSize: 13),
                    icon: retLike ? Icon(IconFont.icon_zan1, color: Global.profile.backColor,size: 16,): Icon(IconFont.icon_aixin, color: Colors.black45,size: 16,),
                    onTap: () async {
                      if(isEnter) {
                        isEnter = false;
                        bool ret = false;
                        if (retLike) {
                          ret = await _imService.delMomentLike(
                              moment.momentid,
                              Global.profile.user!.uid,
                              Global.profile.user!.token!, () {});
                          moment.likenum -= 1;
                          retLike = false;
                        }
                        else {
                          ret = await _imService.updateMomentLike(
                              moment.momentid,
                              Global.profile.user!.uid,
                              Global.profile.user!.token!, () {});
                          moment.likenum += 1;
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
                    moment.commentcount.toString() == "0" ? '评论' : moment.commentcount.toString(),
                    padding: EdgeInsets.only(right: 2),
                    style: TextStyle(color: Colors.black45, fontSize: 13),
                    icon: Icon(IconFont.icon_navbar_xiaoxi, color: Colors.black45, size: 16,),
                    onTap: (){
                      Navigator.pushNamed(context, '/MomentInfo', arguments: {"momentid": moment.momentid});
                    },
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }


}


