import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class MyPhotoViewGallery extends StatefulWidget {
  List<Map<String, String>> list;
  MyPhotoViewGallery({required this.list});

  @override
  _MyPhotoViewGalleryState createState() => _MyPhotoViewGalleryState();
}

class _MyPhotoViewGalleryState extends State<MyPhotoViewGallery> {
  bool verticalGallery = false;
  @override
  Widget build(BuildContext context) {
    int imgCount = (widget.list.length / 2).ceil();
    double pagewidth = MediaQuery.of(context).size.width-20;
    double height = (pagewidth-20);
    if(widget.list.length > 1){
      height = height/2+10;
    }
    height = imgCount * height;

    return Container(
      height: height,
      child: NinePicture(widget.list),
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
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder? loadingBuilder;
  final Decoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<Map<String, String>> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex = 0;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration as BoxDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "${currentIndex + 1}/${widget.galleryItems.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  decoration: null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final  Map<String, String> item = widget.galleryItems[index];
    return item['img'] != null
        ? PhotoViewGalleryPageOptions.customChild(
      child: Container(
        width: 300,
        height: 300,
        child: CachedNetworkImage(
          imageUrl: item['img']!,
        ),
      ),
      childSize: const Size(300, 300),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 1.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item['tag']!),
    )
        : PhotoViewGalleryPageOptions(
      imageProvider: AssetImage(item['img']!),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 1.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item['tag']!),
    );
  }
}

class NinePicture extends StatelessWidget {
  List<Map<String, String>> list = [];

  NinePicture(List<Map<String, String>> list) {
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
    double pagewidth = MediaQuery.of(context).size.width-20;

    if (list.length == 1) {
      _crossAxisCount = 1;
    } else  {
      _crossAxisCount = 2;
    }
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: _crossAxisCount,
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
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
                  fit: BoxFit.cover,
                  imageUrl: '${list[index]['img']}?x-oss-process=image/resize,m_fill,w_800/sharpen,50/quality,q_80',
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
      ).toList(),
    );
  }
}
