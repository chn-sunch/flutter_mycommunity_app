import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../bloc/user/myfollow_bloc.dart';
import '../../model/activity.dart';
import '../../model/user.dart';
import '../../util/common_util.dart';
import '../../global.dart';
import '../../widget/circle_headimage.dart';

class MyFollow extends StatefulWidget {
  @override
  _MyFollowState createState() => _MyFollowState();
}

class _MyFollowState extends State<MyFollow> {
  MyFollowBloc _myFollowBloc = MyFollowBloc();
  double _activityContentHeight = 1.0;//瀑布组件高度
  double _pageWidth = 0;
  double _leftHeight = 0;//左边列的高度
  double _rigthHeight = 0;//右边列的高度
  double _contentText = 99;//图片下面的文字描述与间距
  double _categoryBarHeight=180.0;
  var _loadstate = 0;
  bool _lock = false;//防止滚动条多次执行加载更多
  bool _lockUser = false;//防止滚动条多次执行加载更多


  double _scrollThreshold = 100;

  ScrollController _scrollControllerContent = new ScrollController(initialScrollOffset: 0);
  ScrollController _scrollControllerUserContent = new ScrollController(initialScrollOffset: 0);

  @override
  initState(){
    _myFollowBloc.add(PostFetched(user: Global.profile.user));

    _scrollControllerContent.addListener(() {
      final maxScroll = _scrollControllerContent.position.maxScrollExtent;
      double currentScroll = _scrollControllerContent.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_lock) {
        _myFollowBloc.add(PostActvityFetched(user: Global.profile.user!));
        _lock = true;//加载完毕后再解锁
      }
    });

    _scrollControllerUserContent.addListener(() {
      final maxScrollUser = _scrollControllerUserContent.position.maxScrollExtent;
      double currentUserScroll = _scrollControllerUserContent.position.pixels;
      if (maxScrollUser - currentUserScroll <= _scrollThreshold && !_lockUser) {
//        _myFollowBloc.add(PostCommunityFetched(user: Global.profile.user));
//        _lockUser = true;//加载完毕后再解锁
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollControllerContent.dispose();
    _scrollControllerUserContent.dispose();
    _myFollowBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    _pageWidth = MediaQuery.of(context).size.width / 2 -8;

    return RefreshIndicator(
        color: Colors.redAccent,
        onRefresh: () async{
        _myFollowBloc.add(Refreshed(user: Global.profile.user!));
      },
      child: Container(
          child: BlocBuilder<MyFollowBloc, MyFollowState>(
          bloc: _myFollowBloc,
          builder: (context, state){
            if(state is NoLogin){
              return InkWell(
                child: Center(
                  child: Text('登录后才能看到你关注了谁.',style: TextStyle(color: Colors.black54, fontSize: 15),),
                ),
                onTap: (){
                  Navigator.pushNamed(context, '/Login').then((value){
                    if(Global.profile.user != null)
                      _myFollowBloc.add(Refreshed(user: Global.profile.user!));
                  });
                },
              );
            }
            if(state is PostLoading){
              return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Global.profile.backColor)
                ),
              );
            }
            if(state is PostSuccess){
              return ListView(
                  addAutomaticKeepAlives: true,
                  controller: _scrollControllerContent,
                  children: buildContent(state.users, state.activitys, state)
              );
            }
            else{
              return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Global.profile.backColor)
                ),
              );
            }
        }
      ),
    ));
  }

  //内容
  List<Widget> buildContent(List<User> users, List<Activity> activitys, MyFollowState state){
    List<Widget> contents = [];
    List<Widget> follow = [];
//    contents.add(
//        SearchBar()
//    );

    if(users != null && users.length > 0){
      for(int i=0; i< users.length; i++){
        if(i == activitys.length-1) {
          this._lockUser = false;//加载完毕后解锁，允许再次加载
        }
        follow.add(buildFollow(users[i]));
      }
    }

    contents.add(Card(
      child: Padding(
        padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('我关注的人', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: InkWell(
                    child: Text('全部>', style: TextStyle(color: Colors.black54, fontSize: 13),),
                    onTap: (){
                      Navigator.pushNamed(context, '/MyFollowCommunityList');
                    },
                  ),
                )
              ],
            ),
            users.length == 0 ? SizedBox(height: 10,) : SizedBox(height: 5,),
            users.length == 0 ? Container(height: 26,
              child: Center(child: Text('被你关注的人或许会分享有趣的活动给你',
                style: TextStyle(color: Colors.black54, fontSize: 14, ),),),): Container(
              margin: EdgeInsets.only(top: 10),
              height: 85,
              child: ListView(
                controller: _scrollControllerUserContent,
                scrollDirection: Axis.horizontal,
                children: follow,
              ),
            ),
            users.length == 0 ? SizedBox(height: 10,) : SizedBox(height: 0,),
          ],
        ),
      ),
    )) ;
    if (activitys.length != 0) {
      contents.add(indexPageView(activitys, state)) ;
    }

    return contents;
  }

  Widget buildFollow(User user){
    return Padding(
      padding: EdgeInsets.only(right: 15),
      child: Column(
        children: [
          NoCacheClipRRectHeadImage(imageUrl: user.profilepicture??"", uid: user.uid,
            width: 50,),
          SizedBox(height: 5,),
          Text(user.username.length > 6 ? '${user.username.substring(0, 5)}' :
          user.username, style: TextStyle(color: Colors.black45, fontSize: 13),)      ],
      ),
    );
  }

  Widget indexPageView(List<Activity> activitys, MyFollowState state){
    _getContentHeight(activitys);
    return Container(
      height: _activityContentHeight,
      child: activityContent(activitys, state as PostSuccess),
    );
  }

  //瀑布流内容高度
  void _getContentHeight(List<Activity> data){
    List<Activity> activitys = data;
    _rigthHeight = 0;
    _leftHeight = 0;
    for(int i=0; i<activitys.length; i++ ){
      if(_rigthHeight < _leftHeight){
        _rigthHeight += getImageWH(activitys[i]) + _contentText;
      }
      else{
        _leftHeight += getImageWH(activitys[i]) + _contentText;
      }
    }
    _activityContentHeight = (_leftHeight >= _rigthHeight ? _leftHeight : _rigthHeight) +  _categoryBarHeight;//最后取左右两边的最大值作为瀑布组件的高,再加上分类的高
  }
  //计算图片高度和宽度
  double getImageWH(Activity activity){
    double retheight = 200;
    if(activity.coverimgwh.split(',').length > 1) {
      double width = double.parse(activity.coverimgwh.split(',')[0]);
      double height = double.parse(activity.coverimgwh.split(',')[1]);
      double ratio = width / height; //宽高比
      double retheight = (_pageWidth) / ratio;
      if (retheight > 200)
        retheight = 200;
    }
    else
      retheight = 0;
    return retheight; //图片缩放高度
  }

  Widget activityContent(List<Activity> activitys, PostSuccess state){
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
      itemCount: state.hasReachedActivityMax? activitys.length : activitys.length + 1,
      itemBuilder: (BuildContext context, int index){
        if(index == activitys.length) {
          this._lock = false;//加载完毕后解锁，允许再次加载
        }
        return index > activitys.length ? buildLoading() :
        (index == activitys.length ? SizedBox.shrink() :buildActivityItem(activitys[index], _loadstate) );
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
  Widget buildActivityItem(Activity activity, int state){
    double temheight = getImageWH(activity);

    Widget widgetMoney = Row(
      children: [
        Text("￥", style: TextStyle(color: Colors.red, fontSize: 10),),
        Text(activity.mincost.toString(), style: TextStyle(color: Colors.red, fontSize: 12,fontWeight: FontWeight.bold),)
      ],
    );

    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, '/ActivityInfo', arguments: {"actid": activity.actid}).then((val){
        });
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
            ): SizedBox.shrink(),
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
            Container(
              height: 16,
              padding: EdgeInsets.only(left: 9, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widgetMoney,
                  Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CommonUtil.getTextDistance(activity.lat, activity.lng,
                            Global.profile.lat, Global.profile.lng),
                      )
                  ),
                ],
              ),
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

}
