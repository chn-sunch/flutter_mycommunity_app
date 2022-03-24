import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../global.dart';

class PhotoViewGalleryScreen extends StatefulWidget {
  List images=[];
  int index;
  String heroTag;
  PageController? controller;

  PhotoViewGalleryScreen({Key? key,Ag,this.index=-1,arguments,this.controller,this.heroTag=""}) : super(key: key){
    this.images = arguments["images"];
    if(this.index >= 0){
      controller=PageController(initialPage: index);
    }
    else
      controller=PageController();
  }

  @override
  _PhotoViewGalleryScreenState createState() => _PhotoViewGalleryScreenState();
}

class _PhotoViewGalleryScreenState extends State<PhotoViewGalleryScreen> {
  int currentIndex=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex=widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: widget.images[index],
                    );
                  },
                  itemCount: widget.images.length,
                  backgroundDecoration: null,
                  pageController: widget.controller,
                  enableRotation: true,
                  onPageChanged: (index){
                    setState(() {
                      currentIndex=index;
                    });
                  },
                )
            ),
          ),
          Positioned(//图片index显示
            top: MediaQuery.of(context).padding.top+15,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("${currentIndex+1}/${widget.images.length}",style: TextStyle(color: Colors.white,fontSize: 16)),
            ),
          ),
          Positioned(//右上角关闭按钮
            right: 10,
            top: MediaQuery.of(context).padding.top,
            child: IconButton(
              icon: Icon(Icons.close,size: 30,color: Colors.white,),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}



class PhotoViewSimpleScreen extends StatelessWidget{
  ImageProvider? imageProvider;
  final Widget? loadingChild;
  final Decoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String heroTag;

  PhotoViewSimpleScreen({
    this.imageProvider,//图片
    this.loadingChild,//加载时的widget
    this.backgroundDecoration,//背景修饰
    this.minScale,//最大缩放倍数
    this.maxScale,//最小缩放倍数
    this.heroTag="simple",//hero动画tagid
    arguments,
  }){
    //this.imageProvider = arguments["image"];
    if(Global.profile.profilePicture != null)
      this.imageProvider = AssetImage("images/icon_head_default.png");
    else
      this.imageProvider = Global.profile.defProfilePicture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child: PhotoView(
                imageProvider: imageProvider,
                minScale: minScale,
                maxScale: maxScale,
                heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
                enableRotation: true,
              ),
            ),
            Positioned(//右上角关闭按钮
              right: 10,
              top: MediaQuery.of(context).padding.top,
              child: IconButton(
                icon: Icon(Icons.close,size: 30,color: Colors.white,),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

}

class PhotoViewImageHead extends StatelessWidget{
  ImageProvider? imageProvider;
  final Widget? loadingChild;
  final Decoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String heroTag;
  PhotoViewImageHead({
    this.imageProvider,//图片
    this.loadingChild,//加载时的widget
    this.backgroundDecoration,//背景修饰
    this.minScale,//最大缩放倍数
    this.maxScale,//最小缩放倍数
    this.heroTag="simple",//hero动画tagid
    arguments,
  }){
      if(arguments["iscache"] != null && !arguments["iscache"] ) {
        imageProvider =
            NetworkImage(arguments["image"].toString());
      }
      else {
        imageProvider =
            CachedNetworkImageProvider(arguments["image"].toString());
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child: PhotoView(
                imageProvider: imageProvider,
                minScale: minScale,
                maxScale: maxScale,
                heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
                enableRotation: true,
              ),
            ),
            Positioned(//右上角关闭按钮
              right: 10,
              top: MediaQuery.of(context).padding.top,
              child: IconButton(
                icon: Icon(Icons.close,size: 30,color: Colors.white,),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

}
