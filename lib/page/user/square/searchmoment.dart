import 'package:flappy_search_bar_ns/flappy_search_bar_ns.dart';
import 'package:flappy_search_bar_ns/scaled_tile.dart';
import 'package:flappy_search_bar_ns/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/service/imservice.dart';

import '../../../model/searchresult.dart';
import '../../../model/hissearch.dart';
import '../../../util/imhelper_util.dart';
import '../../../widget/my_divider.dart';
import '../../../global.dart';

class Post {
  final String title;
  final String body;

  Post(this.title, this.body);
}

class SearchMoment extends StatefulWidget {
  Object? arguments;
  String contentDef = "动态内容";
  SearchMoment({this.arguments}){
    if(arguments != null && (arguments as Map)["content"] != null)
      contentDef =  (arguments as Map)["content"];
  }

  @override
  _SearchMomentState createState() => _SearchMomentState();
}

class _SearchMomentState extends State<SearchMoment> {
  ImHelper _imHelper = ImHelper();
  final SearchBarController<SearchResult> _searchBarController = SearchBarController();
  ImService _imService = new ImService();
  bool isReplay = false;
  List<Widget> hotSearchs = [];
  List<Widget> hisSearchs = [];
  String content = "";

  Future<List<SearchResult>> _getALlPosts(String? text) async {
    content =text!;
    if(Global.isInDebugMode){
      print(text);
    }
    List<SearchResult> searchResults = [];
    if(text.isNotEmpty) {
      searchResults = await _imService.getRecommendSearchMoment(text,  () {});
    }
    return searchResults;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hotSearchs.add(SizedBox.shrink());
    hisSearchs.add(SizedBox.shrink());
    getHostSearch();
    getHisSearchs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SearchBar<SearchResult>(
          textInputType: TextInputType.text,
          minimumChars: 1,
          isCustList: true,
          isShowSearch: widget.contentDef != "搜索内容",
          searchBarStyle: SearchBarStyle(
              padding: EdgeInsets.all(5)
          ),
          searchBarPadding: EdgeInsets.only(top: 9),
          headerPadding: EdgeInsets.symmetric(horizontal: 10),
          listPadding: EdgeInsets.symmetric(horizontal: 10),
          onSearch: _getALlPosts,
          hintText: '搜索内容',
          text: widget.contentDef == '搜索内容'?'':widget.contentDef,
          textStyle: TextStyle(color: Colors.black87, fontSize: 14),
          searchBarController: _searchBarController,
          placeHolder: buildSearchRecommend(),
          cancellationWidget: Text("搜索"),
//          emptyWidget: Text('111111'),
          indexedScaledTileBuilder: (int index) => ScaledTile.count(1, index.isEven ? 2 : 1),
          onCancelled: () {
            if(content.isEmpty){
              content = widget.contentDef;
            }
            _imHelper.saveSearchHistory(2, content);
            Navigator.pushNamed(context, '/SearchMomentResultPage', arguments: {"content": content});
          },
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          crossAxisCount: 1,
          onItemFound: (searchResult, int index) {
            return  Column(
              children: [
                ListTile(
                  isThreeLine: false,
                  title: Text(searchResult!.content!),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/SearchMomentResultPage', arguments: {"content": searchResult.content});
                  },
                ),
                MyDivider()
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildSearchRecommend(){
    return Padding(
      padding: EdgeInsets.only(left: 10,top: 5,bottom: 10,right: 10),
      child: Column(
        children: [
          buildHistorySearch()
        ],
      ),
    );
  }

  Widget buildHistorySearch(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('历史搜索', style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),),
        SizedBox(height: 10,),
        Wrap(
          children: hisSearchs,
        ),
        SizedBox(height: 20,),
        Text('热门搜索', style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 10,),
        Wrap(
          children: hotSearchs,
        ),
      ],
    );
  }

  getHostSearch() async {
    List<SearchResult> searchResults = await _imService.hotsearchMoment();
    if(searchResults != null && searchResults.length > 0){
      for(int i=0; i < searchResults.length; i++){
        hotSearchs.add(
          InkWell(
            child: Container(
              margin: EdgeInsets.only(right: 10, bottom: 15),
              child: Container(
                margin: EdgeInsets.all(10),
                child: Text(searchResults[i].content!, style: TextStyle(color: Colors.black54, fontSize: 13),),
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/SearchMomentResultPage', arguments: {"content": searchResults[i].content});
            },
          )
        );
      }
      if (mounted) {
        setState(() {

        });
      }
    }
  }

  getHisSearchs() async {
    List<HisSearch>? hissearch = await _imHelper.getSearchHistory(2);
    if(hissearch != null && hissearch.length > 0){
      for(int i=0; i < hissearch.length; i++){
        hisSearchs.add(
          InkWell(
            child:  Container(
              margin: EdgeInsets.only(right: 10, bottom: 15),
              child: Container(
                margin: EdgeInsets.all(5),
                child: Text(hissearch[i].content!, style: TextStyle(color: Colors.black54, fontSize: 13),),
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onTap: (){
              Navigator.pushNamed(context, '/SearchMomentResultPage', arguments: {"content": hissearch[i].content});
            },
          )
        );
      }
      if (mounted) {
        setState(() {

        });
      }
    }
  }
}

class Detail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text("Detail"),
          ],
        ),
      ),
    );
  }
}