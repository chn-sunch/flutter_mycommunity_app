import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/iconfont.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../global.dart';
import '../../model/usershared.dart';
import '../../util/imhelper_util.dart';
import '../../util/common_util.dart';
import '../../widget/weixing/wxshareview.dart';

class SharedList extends StatefulWidget {
  @override
  _SharedListState createState() => _SharedListState();
}

class _SharedListState extends State<SharedList> {
  double _activityContentHeight = 1.0;//瀑布组件高度
  double _leftHeight = 0;//左边列的高度
  double _rigthHeight = 0;//右边列的高度
  double _contentText = 83;//图片下面的文字描述与间距
  double _pageWidth = 0;
  var _loadstate = 0;
  List<UserShared>? userShareds;
  ImHelper imHelper = new ImHelper();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserSharedsList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _getUserSharedsList() async {
    imHelper.updateSharedFriendRead();
    userShareds = await imHelper.getSharedFriend(0, 1000);

    if(mounted)
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    _pageWidth = MediaQuery.of(context).size.width / 2 -8;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('活动分享', style: TextStyle(color: Colors.black, fontSize: 16)),
        centerTitle: true,
        actions: [
          WXShareView(icon: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(IconFont.icon_fenxiang, color: Colors.black,),
          ),),
        ],
      ),
      body: userShareds != null ? ListView(
          addAutomaticKeepAlives: true,
          children: buildContent()
      ): Container(
        alignment: Alignment.center,
        child: Text(''
            'Emm...就是没人分享活动...',style: TextStyle(color: Colors.black54, fontSize: 14, )),
      ),
    ) ;
  }

  //内容
  List<Widget> buildContent() {
    List<Widget> contents = [];
    if (userShareds != null && userShareds!.length != 0 ) {
      contents.add(indexPageView()) ;
    }

    return contents;
  }

  Widget indexPageView(){
    _getContentHeight(userShareds!);
    return Container(
      height: _activityContentHeight,
      child: activityContent(userShareds!),
    );
  }
  //瀑布流内容高度
  void _getContentHeight(List<UserShared> data){
    List<UserShared> userShareds = data;
    _rigthHeight = 0;
    _leftHeight = 0;
    for(int i=0; i<userShareds.length; i++ ){
      if(_rigthHeight < _leftHeight){
        _rigthHeight += getImageWH(userShareds[i]) + _contentText;
      }
      else{
        _leftHeight += getImageWH(userShareds[i]) + _contentText;
      }
    }
    _activityContentHeight = (_leftHeight >= _rigthHeight ? _leftHeight : _rigthHeight) +  0;//最后取左右两边的最大值作为瀑布组件的高,再加上分类的高
  }
  //计算图片高度和宽度
  double getImageWH(UserShared userShared){
    double retheight = 200;
    if(userShared.image != ""){
      return retheight;
    }
    else
      retheight = 0;
    return retheight; //图片缩放高度
  }

  Widget activityContent(List<UserShared> userShared){
    if(userShared.length == 0) {
      //return Center(child: Image.asset('images/26074001_bzCh.gif'),);
      return Center(child: Text('还没有活动', style: TextStyle(color: Colors.black54, fontSize: 15),));
    }
    return  StaggeredGridView.countBuilder(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 0),
      addAutomaticKeepAlives:true,
      primary: false,
      shrinkWrap: false,
      crossAxisCount: 2,
      mainAxisSpacing: 0.0,
      crossAxisSpacing: 0.0,
      itemCount: userShared.length,
      itemBuilder: (BuildContext context, int index){
        return buildActivityItem(userShared[index]);
      },
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
  }
  //加载中图标
  Widget buildLoading(){
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
          ),
        ),
      ),);
  }
  //瀑布流内容
  Widget buildActivityItem(UserShared userShared){
    Widget widgetMoney = SizedBox.shrink();
    if(userShared.mincost! > 0.0){
      widgetMoney = Row(
        children: [
          Text("￥", style: TextStyle(color: Colors.red, fontSize: 10),),
          Text(userShared.mincost!.toString(), style: TextStyle(color: Colors.red, fontSize: 12,fontWeight: FontWeight.bold),)
        ],
      );
    }
    double temheight = 0.0;
    if(userShared.image != null && userShared.image != ""){
      temheight = getImageWH(userShared);
    }

    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": userShared.contentid}).then((val){});
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            temheight != 0 ? Container(
              width: _pageWidth,
              height: temheight,
              child:  ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                  child: CachedNetworkImage(
                    imageUrl: '${userShared.image}?x-oss-process=image/resize,m_fixed,w_600/sharpen,50/quality,q_80',//缩放压缩
                    fit: BoxFit.cover,
                  )
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
              ),
            ) : SizedBox.shrink(),
            Container(
              height: 37,
              padding: EdgeInsets.only(top: 5, left: 10),
              child: Text(
                userShared.content! ,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            userShared.mincost! > 0 ? Container(
              height: 16,
              padding: EdgeInsets.only(left: 9, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widgetMoney,
                  Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CommonUtil.getTextDistance(userShared.lat, userShared.lng, Global.profile.lat, Global.profile.lng),
                      )
                  ),
                ],
              ),
            ) : Container(
                height: 16,
                padding: EdgeInsets.only(left: 9, right: 5),
                child:   Container(
                  alignment: Alignment.centerLeft,
                  child: CommonUtil.getTextDistance(userShared.lat, userShared.lng, Global.profile.lat, Global.profile.lng),
                )
            ),
            Container(
              height: 26,
              padding: EdgeInsets.only(left: 9, bottom: 5, right: 5, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(userShared.fromprofilepicture!),
                    radius: 9,
                    // maxRadius: 40.0,
                  ),
                  Expanded(child:Container(
                    margin: EdgeInsets.only(left: 5),
                    child:  Text(
                      userShared.fromusername!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
