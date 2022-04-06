import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../model/activity.dart';
import '../../model/user.dart';
import '../../util/imhelper_util.dart';
import '../../util//common_util.dart';
import '../../global.dart';

class MyCollectionActivity extends StatefulWidget{

  @override
  _MyCollectionActivityState createState() => _MyCollectionActivityState();
}

class _MyCollectionActivityState extends State<MyCollectionActivity>  {
  late User user;
  List<Activity> _activitys = [];
  ImHelper _imHelper = new ImHelper();
  bool _isPageLoad = false;
  double _activityContentHeight = 1.0;//瀑布组件高度
  double _pageWidth = 0;
  double _leftHeight = 0;//左边列的高度
  double _rigthHeight = 0;//右边列的高度
  double _contentText = 83;//图片下面的文字描述与间距

  getMyCollection() async {
    _activitys = await _imHelper.selActivityCollectionByUid(Global.profile.user!.uid);
    _isPageLoad = true;
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = Global.profile.user!;
    getMyCollection();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    _pageWidth = MediaQuery.of(context).size.width / 2 -8;


    return   Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back_ios, size: 18,),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title:  Text('收藏的商家活动',textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 16)),
          centerTitle: true,
        ),
        body: _isPageLoad ?  ((_activitys == null || _activitys.length == 0) ? Center(
          child: Text('还没有收藏的活动', style: TextStyle(color: Colors.black54, fontSize: 14, ),),
        ) : ListView(
          children: buildContent(_activitys),
        )) : Center(
          child: CircularProgressIndicator(
            valueColor:  AlwaysStoppedAnimation(Global.profile.backColor),
          ),
        )
    ) ;
  }

  List<Widget> buildContent(List<Activity> acivitys) {
    List<Widget> contents = [];

    if (acivitys != null && acivitys.length != 0 ) {
      contents.add(indexPageView(acivitys)) ;
    }

    return contents;
  }


  Widget indexPageView(List<Activity> acivitys){
    _getContentHeight(acivitys);
    return Container(
      height: _activityContentHeight,
      child: activityContent(acivitys),
    );
  }

  //瀑布流内容高度
  void _getContentHeight(List<Activity> data){
    List<Activity> temactivity = data;
    _rigthHeight = 0;
    _leftHeight = 0;
    for(int i=0; i<temactivity.length; i++ ){
      if(_rigthHeight < _leftHeight){
        _rigthHeight += getImageWH(temactivity[i]) + _contentText;
      }
      else{
        _leftHeight += getImageWH(temactivity[i]) + _contentText;
      }
    }
    _activityContentHeight = (_leftHeight >= _rigthHeight ? _leftHeight : _rigthHeight) +  0;//最后取左右两边的最大值作为瀑布组件的高,再加上分类的高
  }

  Widget activityContent(List<Activity> activitys){
    if(activitys.length == 0) {
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
      itemCount: activitys.length,
      itemBuilder: (BuildContext context, int index){
        return buildActivityItem(activitys[index]);
      },
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
  }

  //瀑布流内容
  Widget buildActivityItem(Activity activity){
    Widget widgetMoney = SizedBox.shrink();
    if(activity.mincost > 0.0){
      widgetMoney = Row(
        children: [
          Text("￥", style: TextStyle(color: Colors.red, fontSize: 10),),
          Text(activity.mincost.toString(), style: TextStyle(color: Colors.red, fontSize: 12,fontWeight: FontWeight.bold),)
        ],
      );
    }
    double temheight = 0.0;
    if(activity.coverimg != null && activity.coverimg != ""){
      temheight = getImageWH(activity);
    }

    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": activity.actid}).then((val){});
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
                    imageUrl: '${activity.coverimg}?x-oss-process=image/resize,m_fixed,w_600/sharpen,50/quality,q_80',//缩放压缩
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
                activity.content ,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            activity.mincost > 0 ? Container(
              height: 16,
              padding: EdgeInsets.only(left: 9, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widgetMoney,
                  Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CommonUtil.getTextDistance(activity.lat, activity.lng, Global.profile.lat, Global.profile.lng),
                      )
                  ),
                ],
              ),
            ) : Container(
                height: 16,
                padding: EdgeInsets.only(left: 9, right: 5),
                child:   Container(
                  alignment: Alignment.centerLeft,
                  child: CommonUtil.getTextDistance(activity.lat, activity.lng, Global.profile.lat, Global.profile.lng),
                )
            ),
            Container(
              height: 26,
              padding: EdgeInsets.only(left: 9, bottom: 5, right: 5, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(activity.user!.profilepicture!),
                    radius: 9,
                    // maxRadius: 40.0,
                  ),
                  Expanded(child:Container(
                    margin: EdgeInsets.only(left: 5),
                    child:  Text(
                      activity.user!.username,
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


  //计算图片高度和宽度
  double getImageWH(Activity activity){
    double retheight = 200;
    if(activity.coverimg != ""){
      return retheight;
    }
    else
      retheight = 0;
    return retheight; //图片缩放高度
  }
}


