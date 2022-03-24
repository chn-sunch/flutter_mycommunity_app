import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class TableHelper{


  static const String im_group_relation = "im_group_relation_table";
  static const String t_Comment_Reply = "Comment_Reply_table";//记录用户评论，
  static const String user_config = "user_config";//用户配置记录如，是否点击了已阅不再提示等。
  static const String t_like = "t_like";//记录用户收到的点赞通知
  static const String user_notinteresteduids = "user_notinteresteduids";
  static const String user_goodnotinteresteduids = "user_goodnotinteresteduids";

  static const String user_blacklist = "user_blacklist";

  //点赞类型 0 活动 1 留言 2评价 3bug 4建议t
  static const String sys_config = "sys_config";//系统配置

  static const String t_Follow = "t_Follow";//关注表
  static const String user_member_state_table = "user_member_state_table";
  static const String im_groupandcommunity_member_relation = "im_groupandcommunity_member_relation";//活动群，社团群内的成员列表，本地保存和服务器时间不匹配时更新
  static const String user_friend_state_table = "user_friend_state_table";//收到被加为朋友的通知表
  static const String user_shared_state_table = "user_shared_state_table";//收到朋友的分享
  static const String user_order_state_table = "user_order_state_table";//各种状态订单的数量 0 待付款 1 待确认
  static const String user_orderunevaluate_state_table = "user_orderunevaluate_state_table";//未评价订单数量

  static const String im_user_relation_table = "im_user_relation_table";
  static const String activity_state_table = "activity_state_table";//本地like状态
  static const String bugsuggest_state_table = "bugsuggest_state_table";//本地like状态 0bug 1suggest
  static const String goodprice_state_table = "goodprice_state_table";//本地like状态 goodprice

  static const String activity_collection_state_table = "activity_collection_state_table";//本地collection状态
  static const String product_collection_state_table = "product_collection_state_table";//本地collection状态
  static const String goodprice_collection_state_table = "goodprice_collection_state_table";//本地collection状态

  static const String activity_comment_state_table = "activity_comment_state_table";//本地comment状态是否有点赞
  static const String goodprice_comment_state_table = "goodprice_comment_state_table";//本地goodpricecomment状态是否有点赞

  static const String activity_bugsuggestcomment_state_table = "activity_bugsuggestcomment_state_table";//本地bugcomment状态是否有点赞

  static const String activity_evaluate_state_table = "activity_evaluate_state_table";//本地evaluate状态是否有点赞

  static const String community_follow_state_table = "community_follow_state_table";//本地关注状态
  static const String history_browse_table = "history_browse_table";//历史浏览
  static const String history_search_tablle = "history_search_table";//历史搜索 0 社团 1 活动 2 用户

  static const String unevaluate_activity = "unevaluate_activity";//未进行评论的活动
  static const String im_timeline_sync_relation = "im_timeline_sync_relation";
  static const String tableCatalog = "tablelog";

  final String dropGroupTableShelf = "DROP TABLE IF EXISTS $im_group_relation";
  final String createGroupTableShelf = "CREATE TABLE $im_group_relation (id INTEGER , timeline_id TEXT"
      ",readindex INTEGER,unreadcount INTEGER, group_name1 TEXT, clubicon TEXT, name TEXT, newmsgtime TEXT"
      ", newmsg TEXT, timelineType INTEGER, uid INTEGER, istop INTEGER, isdel INTEGER, relationtype INTEGER, "
      "status INTEGER, locked INTEGER, memberupdatetime TEXT, oldmemberupdatetime TEXT, "
      "isnotservice INTEGER, source_id TEXT, goodpriceid TEXT)";

  final String dropGroupandcommunityMemberTableShelf = "DROP TABLE IF EXISTS $im_groupandcommunity_member_relation";
  final String createGroupandcommunityMemberTableShelf = "CREATE TABLE $im_groupandcommunity_member_relation (timeline_id TEXT"
      ",uid INTEGER, username TEXT, profilepicture TEXT)";


  final String dropCommentReply = "DROP TABLE IF EXISTS $t_Comment_Reply";
  final String createCommentReply = "CREATE TABLE $t_Comment_Reply (replyid INTEGER , actid TEXT, commentid INTEGER"
      ",replycontent TEXT,uid INTEGER, isread INTEGER , replycreatetime TEXT, username TEXT"
      ", profilepicture TEXT, touid INTEGER, type TEXT,ismaster INTEGER, actcontent TEXT, coverimg TEXT, evaluateid INTEGER, imagepaths TEXT)";



  final String dropUserRelationTableShelf = "DROP TABLE IF EXISTS $im_user_relation_table";
  final String createUserRelationTableShelf = "CREATE TABLE $im_user_relation_table (id INTEGER , timeline_id TEXT"
      ",readindex INTEGER,unreadcount INTEGER, group_name1 TEXT, clubicon TEXT, name TEXT, newmsgtime TEXT, "
      " newmsg TEXT,timelineType INTEGER, uid INTEGER)";

  final String dropTimeLineShelf = "DROP TABLE IF EXISTS $im_timeline_sync_relation";
  final String createTableTimeLineShelf = "CREATE TABLE $im_timeline_sync_relation (sequence_id INTEGER , timeline_id TEXT"
      ",conversation INTEGER,send_time TEXT,sender INTEGER,serdername TEXT,serderpicture TEXT,content TEXT,"
      " contenttype INTEGER, uid INTEGER, localpath TEXT, isopen INTEGER, source_id TEXT)";

  final String dropActivityTableShelf = "DROP TABLE IF EXISTS $activity_state_table";
  final String createActivityTableShelf = "CREATE TABLE $activity_state_table (actid TEXT , uid INTEGER)";

  final String dropSysConfigTableShelf = "DROP TABLE IF EXISTS $sys_config";
  final String createSysConfigTableShelf = "CREATE TABLE $sys_config (sysname TEXT , content TEXT)";

  final String dropGoodPriceTableShelf = "DROP TABLE IF EXISTS $goodprice_state_table";
  final String createGoodPriceTableShelf = "CREATE TABLE $goodprice_state_table (goodpriceid TEXT , uid INTEGER , status INTEGER)";//0不赞  1赞

  final String dropBugSuggestTableShelf = "DROP TABLE IF EXISTS $bugsuggest_state_table";
  final String createBugSuggestTableShelf = "CREATE TABLE $bugsuggest_state_table (actid TEXT , uid INTEGER, type INTEGER)";



  final String dropActivityCollectionTableShelf = "DROP TABLE IF EXISTS $activity_collection_state_table";
  final String createActivityCollctionTableShelf = "CREATE TABLE $activity_collection_state_table (actid TEXT, peoplenum INTEGER,femalenum INTEGER, "
      "malenum INTEGER,content TEXT,coverimg TEXT,uid INTEGER,actsex TEXT,actprovince TEXT,actcity TEXT,coverimgwh TEXT, "
      "username TEXT,profilepicture TEXT, lat REAL, lng REAL,cost REAL, localuid INTEGER, maxcost REAL, mincost REAL)";

  final String dropProductCollectionTableShelf = "DROP TABLE IF EXISTS $product_collection_state_table";
  final String createProductCollctionTableShelf = "CREATE TABLE $product_collection_state_table (productid INTEGER , uid INTEGER)";

  final String dropGoodPriceCollectionTableShelf = "DROP TABLE IF EXISTS $goodprice_collection_state_table";
  final String createGoodPriceCollctionTableShelf = "CREATE TABLE $goodprice_collection_state_table (goodpriceid TEXT , title TEXT,content TEXT,"
      "productnum INTEGER,category INTEGER,brand TEXT,totalprice REAL,price REAL,originalprice REAL,discount REAL,endtime TEXT,createtime TEXT,albumpics TEXT,"
      "pic TEXT,collectionnum INTEGER,province TEXT,city TEXT,uid INTEGER,producturl TEXT,likenum INTEGER,unlikenum INTEGER,purchasechannels TEXT,productstatus INTEGER,"
      "satisfactionrate REAL,activitycount INTEGER,lat REAL,lng REAL,address TEXT,addresstitle TEXT,commentnum INTEGER,tag TEXT, username TEXT, "
      "profilepicture TEXT, localuid INTEGER, mincost REAL, maxcost REAL)";

  final String dropActivityCommentTableShelf = "DROP TABLE IF EXISTS $activity_comment_state_table";
  final String createActivityCommentTableShelf = "CREATE TABLE $activity_comment_state_table (commentid TEXT , uid INTEGER)";

  final String dropGoodPriceCommentTableShelf = "DROP TABLE IF EXISTS $goodprice_comment_state_table";
  final String createGoodPriceCommentTableShelf = "CREATE TABLE $goodprice_comment_state_table (commentid TEXT , uid INTEGER)";


  final String dropBugAndSuggestCommentTableShelf = "DROP TABLE IF EXISTS $activity_bugsuggestcomment_state_table";
  //0是bug 1是suggest
  final String createBugAndSuggestCommentTableShelf = "CREATE TABLE $activity_bugsuggestcomment_state_table (commentid TEXT , uid INTEGER, type INTEGER)";

  final String dropLikeTableShelf = "DROP TABLE IF EXISTS $t_like";
  //touid是接收人的uid,就是本地用户
  final String createLikeTableShelf = "CREATE TABLE $t_like (likeid INTEGER , touid INTEGER, liketype INTEGER, contentid TEXT, "
      "uid INTEGER, username TEXT, profilepicture TEXT, isread INTEGER, createtime TEXT)";

  final String dropActivityEvaluateTableShelf = "DROP TABLE IF EXISTS $activity_evaluate_state_table";
  final String createActivityEvaluateTableShelf = "CREATE TABLE $activity_evaluate_state_table (evaluateid TEXT , uid INTEGER)";

  final String dropCommunityFollowTableShelf = "DROP TABLE IF EXISTS $community_follow_state_table";
  final String createCommunityFollowTableShelf = "CREATE TABLE $community_follow_state_table (uid INTEGER , follow INTEGER)";

  final String dropCommunityMemberTableShelf = "DROP TABLE IF EXISTS $user_member_state_table";
  final String createCommunityMemberTableShelf = "CREATE TABLE $user_member_state_table (id INTEGER,"
      " uid INTEGER , touid INTEGER, content TEXT, createtime TEXT, username TEXT, profilepicture TEXT, "
      " status INTEGER,isread INTEGER)";

  final String dropUserFriendStateTableShelf = "DROP TABLE IF EXISTS $user_friend_state_table";
  //保存收到成为朋友的通知
  final String createUserFriendStateTableShelf = "CREATE TABLE $user_friend_state_table (id INTEGER,"
      " uid INTEGER , touid INTEGER,  createtime TEXT, username TEXT, profilepicture TEXT, "
      " status INTEGER,isread INTEGER)";


  final String dropHistoryBrowseTableShelf = "DROP TABLE IF EXISTS $history_browse_table";
  final String createHistoryBrowseTableShelf = "CREATE TABLE $history_browse_table (actid TEXT , browsetime TEXT"
      ", content TEXT, uid INTERGER, coverimgwh TEXT,coverimg TEXT, profilepicture TEXT, username TEXT, actsex TEXT, "
      "femalenum INTERGER,malenum INTERGER, peoplenum INTERGER, mincost REAL, maxcost REAL)";

  final String dropHistorySearchTableShelf = "DROP TABLE IF EXISTS $history_search_tablle";
  final String createHistorySearchTableShelf = "CREATE TABLE $history_search_tablle ( content TEXT"
      ", time TEXT, type INTEGER, uid INTEGER)";

  final String dropFollowTableShelf = "DROP TABLE IF EXISTS $t_Follow";
  final String createFollowTableShelf = "CREATE TABLE $t_Follow (uid INTEGER , profilepicture TEXT"
      ", username TEXT, isread INTEGER, fans INTERGER, createtime TEXT, id INTEGER, type INTERGER)";

  final String dropUnEvaluateActivityTableShelf = "DROP TABLE IF EXISTS $unevaluate_activity";
  final String createUnEvaluateActivityTableShelf = "CREATE TABLE $unevaluate_activity (actevaluateid INTEGER, actid TEXT ,createtime TEXT"
      ", content TEXT, uid INTERGER, coverimgwh TEXT,coverimg TEXT, profilepicture TEXT, username TEXT, "
      "femalenum INTERGER,malenum INTERGER, peoplenum INTERGER, evaluatestatus INTEGER, currentpeoplenum INTERGER, actuid INTEGER)";

  final String dropUserSharedStateTableShelf = "DROP TABLE IF EXISTS $user_shared_state_table";
  final String createUserSharedStateTableShelf = "CREATE TABLE $user_shared_state_table (sharedid INTEGER, uid INTEGER ,fromuid INTEGER, "
      "contentid TEXT, content TEXT, image TEXT, sharedtype INTEGER,createtime TEXT, fromusername TEXT, fromprofilepicture TEXT, mincost REAL,"
      "maxcost REAL,lat REAL, lng REAL, isread INTEGER)";

  final String dropUserOrderStateTableShelf = "DROP TABLE IF EXISTS $user_order_state_table";
  final String createUserOrderStateTableShelf = "CREATE TABLE $user_order_state_table (uid INTEGER ,ordertype INTEGER, ordercount INTEGER)";

  final String dropOrderUNEvaluateStateTableShelf = "DROP TABLE IF EXISTS $user_orderunevaluate_state_table";
  final String createOrderUNEvaluateStateTableShelf = "CREATE TABLE $user_orderunevaluate_state_table (uid INTEGER , orderunevaluatecount INTEGER)";



  final String dropUserConfigTableShelf = "DROP TABLE IF EXISTS $user_config";
  final String createUserConfigStateTableShelf = "CREATE TABLE $user_config (uid INTEGER ,nopromptActRule INTEGER)";

  final String dropUserNotinterestedUidsTableShelf = "DROP TABLE IF EXISTS $user_notinteresteduids";
  final String createUserNotinterestedUidsTableShelf = "CREATE TABLE $user_notinteresteduids (uid INTEGER ,notinteresteduid INTEGER)";

  final String dropGoodPriceUserNotinterestedUidsTableShelf = "DROP TABLE IF EXISTS $user_goodnotinteresteduids";
  final String createGoodPriceUserNotinterestedUidsTableShelf = "CREATE TABLE $user_goodnotinteresteduids (uid INTEGER ,goodpricenotinteresteduid INTEGER)";


  final String dropUserBlacklistTableShelf = "DROP TABLE IF EXISTS $user_blacklist";
  final String createUserBlacklistTableShelf = "CREATE TABLE $user_blacklist (uid INTEGER ,blacklistuid INTEGER)";


  Database? _db;

  Future<Database> get db async{
    if(_db == null){
      _db = await _initDb();
    }
    return _db!;
  }

  _initDb() async{
    String basePath = await getDatabasesPath();
    String path = join(basePath,"read.db");
    Database db = await openDatabase(path,version: 2,onCreate: _onCreate,onUpgrade: _onUpgrade);
    return db;
  }

  Future close() async {
    var result = _db!.close();
    _db = null;
    return result;
  }

  void _onCreate(Database db, int newVersion) async{
    print(newVersion);
    var batch = db.batch();
    batch.execute(dropGroupTableShelf);
    batch.execute(createGroupTableShelf);

    batch.execute(dropGroupandcommunityMemberTableShelf);
    batch.execute(createGroupandcommunityMemberTableShelf);


    batch.execute(dropUserRelationTableShelf);
    batch.execute(createUserRelationTableShelf);

    batch.execute(dropTimeLineShelf);
    batch.execute(createTableTimeLineShelf);

    batch.execute(dropCommentReply);
    batch.execute(createCommentReply);

    batch.execute(dropActivityTableShelf);
    batch.execute(createActivityTableShelf);

    batch.execute(dropGoodPriceTableShelf);
    batch.execute(createGoodPriceTableShelf);

    batch.execute(dropBugSuggestTableShelf);
    batch.execute(createBugSuggestTableShelf);

    batch.execute(dropActivityCollectionTableShelf);
    batch.execute(createActivityCollctionTableShelf);

    batch.execute(dropProductCollectionTableShelf);
    batch.execute(createProductCollctionTableShelf);

    batch.execute(dropActivityCommentTableShelf);
    batch.execute(createActivityCommentTableShelf);

    batch.execute(dropGoodPriceCommentTableShelf);
    batch.execute(createGoodPriceCommentTableShelf);



    batch.execute(dropBugAndSuggestCommentTableShelf);
    batch.execute(createBugAndSuggestCommentTableShelf);

    batch.execute(dropCommunityFollowTableShelf);
    batch.execute(createCommunityFollowTableShelf);

    batch.execute(dropCommunityMemberTableShelf);
    batch.execute(createCommunityMemberTableShelf);

    batch.execute(dropHistoryBrowseTableShelf);
    batch.execute(createHistoryBrowseTableShelf);

    batch.execute(dropHistorySearchTableShelf);
    batch.execute(createHistorySearchTableShelf);

    batch.execute(dropFollowTableShelf);
    batch.execute(createFollowTableShelf);

    batch.execute(dropUnEvaluateActivityTableShelf);
    batch.execute(createUnEvaluateActivityTableShelf);

    batch.execute(dropActivityEvaluateTableShelf);
    batch.execute(createActivityEvaluateTableShelf);

    batch.execute(dropUserFriendStateTableShelf);
    batch.execute(createUserFriendStateTableShelf);

    batch.execute(dropUserSharedStateTableShelf);
    batch.execute(createUserSharedStateTableShelf);

    batch.execute(dropUserOrderStateTableShelf);
    batch.execute(createUserOrderStateTableShelf);

    batch.execute(dropOrderUNEvaluateStateTableShelf);
    batch.execute(createOrderUNEvaluateStateTableShelf);

    batch.execute(dropLikeTableShelf);
    batch.execute(createLikeTableShelf);

    batch.execute(dropUserConfigTableShelf);
    batch.execute(createUserConfigStateTableShelf);

    batch.execute(dropGoodPriceCollectionTableShelf);
    batch.execute(createGoodPriceCollctionTableShelf);

    batch.execute(dropSysConfigTableShelf);
    batch.execute(createSysConfigTableShelf);

    batch.execute(dropUserNotinterestedUidsTableShelf);
    batch.execute(createUserNotinterestedUidsTableShelf);

    batch.execute(dropGoodPriceUserNotinterestedUidsTableShelf);
    batch.execute(createGoodPriceUserNotinterestedUidsTableShelf);

    batch.execute(dropUserBlacklistTableShelf);
    batch.execute(createUserBlacklistTableShelf);

    await batch.commit();
  }

  void _onUpgrade(Database db, int oldVersion,int newVersion)async{
    print("_onUpgrade oldVersion:$oldVersion");
    print("_onUpgrade newVersion:$newVersion");
//    var batch = db.batch();
//    if(oldVersion == 1){
//      batch.execute(dropTableCatalog);
//      batch.execute(createTableCatalog);
//    }
//    await batch.commit();
  }
}