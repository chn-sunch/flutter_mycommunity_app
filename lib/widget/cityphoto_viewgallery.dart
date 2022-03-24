import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'photo/photo_viewwrapper.dart';


class CityPhotoViewGallery extends StatefulWidget {
  List<Map<String, String>> list;
  CityPhotoViewGallery({required this.list});

  @override
  _CityPhotoViewGalleryState createState() => _CityPhotoViewGalleryState();
}

class _CityPhotoViewGalleryState extends State<CityPhotoViewGallery> {
  bool verticalGallery = false;
  double pagewidth = 0;

  @override
  Widget build(BuildContext context) {
    pagewidth = MediaQuery.of(context).size.width-130;
    double pageheight = 0;

    if(widget.list.length == 1){
      double width = double.parse(widget.list[0]['imgwh'].toString().split(',')[0]);
      double height = double.parse(widget.list[0]['imgwh'].toString().split(',')[1]);
      if(height > width) {
        pagewidth = pagewidth/2;
        pageheight = getImageWH(widget.list[0]['imgwh'].toString());
      }
      else{
        pageheight = getImageWH(widget.list[0]['imgwh'].toString());
      }
    }

    if(widget.list.length == 2 || widget.list.length == 3){
      pagewidth = pagewidth;
      pageheight = pagewidth / 2;
    }

    if(widget.list.length == 4){
      pagewidth = pagewidth;
      pageheight = pagewidth;
    }

    return Container(
      width: pagewidth,
      height: pageheight,
      child: NinePicture(widget.list, pagewidth: pagewidth,),
    );
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: widget.list,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          scrollDirection: verticalGallery ? Axis.vertical : Axis.horizontal,
        ),
      ),
    );
  }

  double getImageWH(String imgwh){
    double width = double.parse(imgwh.split(',')[0]);
    double height = double.parse(imgwh.split(',')[1]);
    double ratio = width/height;//宽高比
    double retheight = (pagewidth.floor().toDouble()) / ratio;

    return retheight; //图片缩放高度
  }
}

class NinePicture extends StatelessWidget {
  List<Map<String, String>> list = [];
  double pagewidth = 0.0;
  NinePicture(List<Map<String, String>> list, {required this.pagewidth}) {
    this.list = list;
  }

  void showPhoto(BuildContext context, Map<String, String> img, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: list,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          //scrollDirection: verticalGallery ? Axis.vertical : Axis.horizontal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int _crossAxisCount = 1;
    if (list.length == 3) {
      _crossAxisCount = 3;
    } else  {
      _crossAxisCount = 2;
    }

    if(list.length == 1){
      return InkWell(
        onTap: () {
          showPhoto(context, list[0], 0);
        },
        child: Hero(
          tag: list[0]['tag'].toString(),
          child: ClipRRect(
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: '${list[0]['img']}?x-oss-process=image/resize,m_fixed,w_600/sharpen,50/quality,q_80',
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _crossAxisCount,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 5.0,
      padding: const EdgeInsets.all(4.0),
      children: list.asMap().keys.map((index) =>
          InkWell(
            onTap: () {
              showPhoto(context, list[index], index);
            },
            child: Hero(
              tag: list[index]['tag'].toString(),
              child: ClipRRect(
                child: CachedNetworkImage(
                  fit: BoxFit.fitWidth,
                  imageUrl: '${list[index]['img']}?x-oss-process=image/resize,m_fill,w_600/sharpen,50/quality,q_80',
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
      ).toList(),
    );
  }
}
