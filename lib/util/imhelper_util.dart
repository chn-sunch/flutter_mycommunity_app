
import 'package:sqflite/sqflite.dart';

import 'common_util.dart';
import 'tablehelper_util.dart';
import '../model/im/grouprelation.dart';
import '../model/im/timelinesync.dart';
import '../model/commentreply.dart';
import '../model/user.dart';
import '../model/follow.dart';
import '../model/activity.dart';
import '../model/grouppurchase/goodpice_model.dart';
import '../model/like.dart';
import '../model/usershared.dart';
import '../model/hissearch.dart';
import '../model/activityevaluate.dart';
import '../global.dart';


class ImHelper{

  TableHelper _sql = TableHelper();

  Future close() async {
    var result = _sql.close();
    return result;
  }

  ///获取最新relation
  ///获取以读索引，未读数量
  Future<int> saveGroupRelation(List<GroupRelation> grouprelations)async{
    var dbClient = await _sql.db;
    var result = 0;
    List<String> timeline_ids = [];

    if(grouprelations.length > 0){
      for(GroupRelation groupRelation in grouprelations) {
        timeline_ids.add(groupRelation.timeline_id);
        if(await isJoinGrid(groupRelation.uid!, groupRelation.timeline_id)){
          int? unreadcount = Sqflite.firstIntValue(await dbClient.rawQuery("SELECT unreadcount FROM ${TableHelper.im_group_relation} "
              "WHERE  timeline_id='${groupRelation.timeline_id}'  "
              "and uid=${Global.profile.user!.uid} "));
          
          if(unreadcount == null) unreadcount = 0; 
          await dbClient.rawUpdate( 'UPDATE ${TableHelper.im_group_relation} SET unreadcount = ?, readindex = ?, group_name1 = ?,clubicon=?,'
              'name =?,newmsgtime=?,newmsg=?,timelineType=?,status=?,locked=?,memberupdatetime=?,source_id=?,goodpriceid=? WHERE timeline_id = ? and uid = ? ',
              [unreadcount + groupRelation.unreadcount, groupRelation.readindex, groupRelation.group_name1,groupRelation.clubicon,
                groupRelation.name, groupRelation.newmsgtime, groupRelation.newmsg, groupRelation.timelineType,groupRelation.status,
                groupRelation.locked, groupRelation.memberupdatetime, groupRelation.source_id, groupRelation.goodpriceid,
                groupRelation.timeline_id,Global.profile.user!.uid]);
          result++;
          if(Global.isInDebugMode){
            print("更新群信息 ------------------------------");
          }
        }
        else{
          await dbClient.insert(
              TableHelper.im_group_relation, groupRelation.toMap());
          result++;
        }
      }
    }
    return result;
  }
  ///订单过期调用，和上面那个类似就是不插入
  Future<int> saveGroupRelationOrderExpiration(List<GroupRelation>? grouprelations)async{
    var dbClient = await _sql.db;
    var result = 0;
    List<String> timeline_ids = [];

    if(grouprelations!= null && grouprelations.length > 0){
      for(GroupRelation groupRelation in grouprelations) {
        timeline_ids.add(groupRelation.timeline_id);
      }
      //服务器与本地群不匹配，这种情况需要把本地群数据删除，可能是用户未付款退出了。标记本地可以删除，用户进入聊天页面后提示无法发消息
      List<GroupRelation>? local_groupRelations = await getGroupRelationByRelationtype(Global.profile.user!.uid.toString(), 0);
      if(local_groupRelations != null && local_groupRelations.length > 0){
        for(GroupRelation local in local_groupRelations){
          if(!timeline_ids.contains(local.timeline_id)){
            await dbClient.rawUpdate( 'UPDATE ${TableHelper.im_group_relation} SET isnotservice=1 WHERE timeline_id = ? and uid = ?',
                [local.timeline_id,Global.profile.user!.uid]);
          }
        }
      }
    }
    return result;
  }

  ///获取群成员
  Future<void> saveGroupMemberRelation(List<User> users, String timeline_id)async{
    var dbClient = await _sql.db;
    var result = 0;

    if(users != null && users.length > 0){
      await dbClient.rawUpdate(
          'delete from ${TableHelper.im_groupandcommunity_member_relation}  where timeline_id = ?',
          [timeline_id]);

      for(User user in users) {
        await dbClient.insert(
            TableHelper.im_groupandcommunity_member_relation, {"timeline_id": timeline_id, "uid": user.uid, "username": user.username,
          "profilepicture": user.profilepicture
        });
      }
    }
  }
  //删除群成员
  Future<void> delGroupMemberRelation(List<User> users, String timeline_id)async{
    var dbClient = await _sql.db;

    if(users != null && users.length > 0){
      for(User user in users) {
        await dbClient.rawUpdate(
            'delete from ${TableHelper.im_groupandcommunity_member_relation}  where timeline_id = ? and uid=?',
            [timeline_id, user.uid]);
      }
    }
  }
  //更新relation
  Future<void> updateGroupRelation(String oldupdatetime, String timeline_id)async{
    var dbClient = await _sql.db;

    await dbClient.rawUpdate( 'UPDATE ${TableHelper.im_group_relation} SET oldmemberupdatetime = ? WHERE timeline_id = ? ',
        [oldupdatetime, timeline_id]);
  }
  //更新relation
  Future<void> updateGroupRelationLock(int locked, String timeline_id)async{
    var dbClient = await _sql.db;

    await dbClient.rawUpdate( 'UPDATE ${TableHelper.im_group_relation} SET locked = ? WHERE timeline_id = ? ',
        [locked, timeline_id]);
  }

  //更新relation
  Future<void> updateGroupRelationIsNotService(String timeline_id)async{
    var dbClient = await _sql.db;

    await dbClient.rawUpdate( 'UPDATE ${TableHelper.im_group_relation} SET isnotservice = 0 WHERE  uid = ? and timeline_id = ? ',
        [Global.profile.user!.uid, timeline_id]);
  }

  Future<List<User>?> getGroupMemberRelation( String timeline_id)async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.im_groupandcommunity_member_relation} "
        "where  timeline_id='${timeline_id}'");
    if (maps == null || maps.length == 0) {
      return null;
    }

    List<User> users = [];
    maps.forEach((it ){
      users.add(User.fromJson(it as Map<String, dynamic>));
    });

    return users;
  }

  ///保存安全活动规范
  Future<void> saveInitMessage(String timeline_id) async{
    var dbClient = await _sql.db;
    var tem = Sqflite.firstIntValue(await dbClient.rawQuery(
        "SELECT COUNT(*) FROM ${TableHelper.im_timeline_sync_relation} "
            "WHERE uid=${Global.profile.user!.uid} and timeline_id='${timeline_id}' and content='@安全活动规范@'"));

    tem == null ? tem = 0 : tem;
    if(tem <= 0) {
      await dbClient.insert(TableHelper.im_timeline_sync_relation,
          {
            "sequence_id": 0,
            "timeline_id": timeline_id,
            "conversation": Global.profile.user!.uid,
            "sender": 0,
            "content": "@安全活动规范@",
            "uid": Global.profile.user!.uid,
            "contenttype": 0,
            "send_time": CommonUtil.getCustomTime(
                DateTime.now().add(Duration(seconds: 1))),
            "serdername": "system"
          });
    }
  }
  ///获取最新未读数据timeline
  ///更新timeline表
  Future<int> saveMessage( List<TimeLineSync> timelinesync) async {
    var dbClient = await _sql.db;
    var result = 0;
    //初始化一条安全交易规范提示
    if(timelinesync != null && timelinesync.length > 0) {
      for (TimeLineSync timelinesync in timelinesync) {
        var tem = Sqflite.firstIntValue(await dbClient.rawQuery(
            "SELECT COUNT(*) FROM ${TableHelper.im_timeline_sync_relation} "
                "WHERE sequence_id=${timelinesync.sequence_id} and uid=${Global
                .profile.user!.uid} and timeline_id='${timelinesync
                .timeline_id}'"));
        if (tem == null || tem == 0)
          if (await dbClient.insert(
              TableHelper.im_timeline_sync_relation, timelinesync.toMap()) >
              0) {
            result++;
          }
      }
    }

    return result;
  }
  ///获取最新未读数据timeline，联系客服专用
  Future<int> saveMessageCustomer( List<TimeLineSync> timelinesync) async {
    var dbClient = await _sql.db;
    var result = 0;
    //初始化一条安全交易规范提示
    if(timelinesync != null && timelinesync.length > 0) {
      for (TimeLineSync timelinesync in timelinesync) {
        timelinesync.sequence_id = - new DateTime.now().millisecondsSinceEpoch;;

        if (await dbClient.insert(
            TableHelper.im_timeline_sync_relation, timelinesync.toMap()) >
            0) {
          result++;
        }
      }
    }

    return result;
  }
  ///如果发送人是自己
  Future<int> saveSelfMessage(TimeLineSync timelinesync) async {
    var dbClient = await _sql.db;
    var result = 0;

    result = await dbClient.insert(
        TableHelper.im_timeline_sync_relation, timelinesync.toMap());

    return result;
  }
  ///删除message
  Future<int> delMessage( TimeLineSync timelinesync) async {
    var dbClient = await _sql.db;
    var result = 0;
    //初始化一条安全交易规范提示
    if(timelinesync != null) {
      result = await dbClient.rawUpdate(
          'delete from ${TableHelper.im_timeline_sync_relation}  where timeline_id = ? and sequence_id=?  and uid=? and content=?',
          [timelinesync.timeline_id, timelinesync.sequence_id, Global
              .profile.user!.uid, timelinesync.content]);
    }

    if(result == null)
      return result;

    return result;
  }
  ///撤回message
  Future<int> recallMessage( String source_id) async {
    var dbClient = await _sql.db;
    var result = 0;

    if(source_id != null) {
      //0文本 1 系统 2 图片 3声音 4地图 5分享
      result = await dbClient.rawUpdate(
          'UPDATE ${TableHelper.im_timeline_sync_relation} set content="你撤回了一条消息",sender=0,contenttype=0 where source_id=?',
          [source_id]);
    }

    if(result == null)
      return result;

    return result;
  }


    ///撤回message
  Future<int> recallMessageToUid( String source_id,String content) async {
    var dbClient = await _sql.db;
    var result = 0;

    if(source_id != null) {
      //0文本 1 系统 2 图片 3声音 4地图 5分享
      result = await dbClient.rawUpdate(
          'UPDATE ${TableHelper.im_timeline_sync_relation} set content=?,sender=0,contenttype=0 where source_id=?',
          [content, source_id]);
    }

    if(result == null)
      return result;

    return result;
  }
  ///撤回im_group_relation
  Future<int> recallGroupRelation(String source_id, String content) async {
    var dbClient = await _sql.db;
    var result = 0;

    if(source_id != null) {
      result = await dbClient.rawUpdate(
          'UPDATE ${TableHelper.im_group_relation} set newmsg=? where source_id=?',
          [content, source_id]);
    }

    if(result == null)
      return result;

    return result;
  }

  ///获取聊天关系中最大的sequence_id
  Future<int> getMaxsequence_id(String timeline_id) async {
    var dbClient = await _sql.db;
    int? result = Sqflite.firstIntValue(await dbClient.rawQuery("SELECT sequence_id FROM im_timeline_sync_relation WHERE timeline_id=? "
        "and uid=${Global.profile.user!.uid} "
        "ORDER BY sequence_id desc LIMIT 1", [timeline_id]));

    return result == null ?0 : result;
  }
  ///查询GroupRelation
  Future<List<GroupRelation>> getGroupRelation(String uid) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.im_group_relation} where  uid=${uid} and isdel=0 order by istop desc,newmsgtime desc");
    if (maps == null || maps.length == 0) {
      return [];
    }
    List<GroupRelation> list = [];
    maps.forEach((it){
      list.add(GroupRelation.fromMap(it as Map<String, dynamic>));
    });

    return list;

  }
  ///查询GroupRelation,分类
  Future<List<GroupRelation>?> getGroupRelationByRelationtype(String uid, int relationtype) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.im_group_relation} "
        "where  uid=${uid} and isdel=0 and relationtype=${relationtype} order by istop desc,newmsgtime desc");
    if (maps == null || maps.length == 0) {
      return null;
    }

    List<GroupRelation> list = [];
    maps.forEach((it){
      list.add(GroupRelation.fromMap(it as Map<String, dynamic>));
    });

    return list;

  }
  //获取群聊关系
  Future<GroupRelation?> getGroupRelationByGroupid(int uid, String timeline_id) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.im_group_relation} WHERE  timeline_id='${timeline_id}'  "
        "and uid=${Global.profile.user!.uid} ");
    if (maps == null || maps.length == 0) {
      return null;
    }

    GroupRelation? groupRelation;
    maps.forEach((it){
      groupRelation =GroupRelation.fromMap(it as Map<String, dynamic>);
    });

    return groupRelation;

  }
  //当前用户是否加入群聊
  Future<bool> isJoinGrid(int uid,  String timeline_id) async {
    var dbClient = await _sql.db;

    int? result = Sqflite.firstIntValue(await dbClient.rawQuery("SELECT COUNT(*) FROM ${TableHelper.im_group_relation} WHERE  timeline_id='${timeline_id}'  "
        "and uid=${Global.profile.user!.uid} "));
    if(result == null)
      result = 0;
    return result > 0;
  }
  //查询timeLineSync
  Future<List<TimeLineSync>> getTimeLineSync(int uid, int current, int offset, String timeline_id) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.im_timeline_sync_relation} where  uid=${uid} and timeline_id='${timeline_id}' "
        "order by send_time desc limit ${current},${offset}");
    if (maps == null || maps.length == 0) {
      return [];
    }

    List<TimeLineSync> list = [];
    maps.forEach((it){
      list.add(TimeLineSync.fromMap(it as Map<String, dynamic>));
    });

    return list;

  }
  //更新群关系中未读数量，变成0
  Future<int> updateAlready(String timeline_id) async {
    var dbClient = await _sql.db;
    int readindex = await getMaxsequence_id(timeline_id);
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.im_group_relation} SET unreadcount = ?, readindex = ? WHERE timeline_id = ? and uid=?',
        [0, readindex, timeline_id, Global.profile.user!.uid]);

    if(Global.isInDebugMode){
      print('im timeline_id read ${count}');
    }

    return count;
  }
  //更新群关系中聊天状态 status=1正常 2拉黑
  Future<int> updateRelationStatus(String timeline_id, int status) async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.im_group_relation} SET status = ? WHERE timeline_id = ? and uid=?',
        [status, timeline_id, Global.profile.user!.uid]);

    if(Global.isInDebugMode){
      print('block user${count}');
    }

    return count;
  }
  //将指定群聊置顶
  Future<int> updateTop(String timeline_id, int uid) async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.im_group_relation} SET istop = ? WHERE timeline_id = ? and uid=?',
        [1, timeline_id, uid]);

    if(Global.isInDebugMode){
      print(count);
    }

    return count;
  }
  //取消群置顶
  Future<int> updateTopCancel(String timeline_id, int uid) async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.im_group_relation} SET istop = ? WHERE timeline_id = ? and uid=?',
        [0, timeline_id, uid]);

    if(Global.isInDebugMode){
      print(count);
    }

    return count;
  }
  //删除群聊
  Future<int> delGroupRelation(String timeline_id, int uid) async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'delete from ${TableHelper.im_group_relation}  where timeline_id = ? and uid=?',
        [timeline_id, uid]);

    if(Global.isInDebugMode){
      print(count);
    }
    if(count != null)
      return count;
    else{
      return 0;
    }

    return count;
  }
  //删除聊天记录

  Future<void> delTimeLineSync(int uid, String timeline_id) async{
    var dbClient = await _sql.db;
    await dbClient.rawQuery("delete FROM ${TableHelper.im_timeline_sync_relation} where  uid=${uid} and timeline_id='${timeline_id}' ");
  }
  //获取所有回复提醒
  Future<List<CommentReply>?> getCommentReplys(int current, int offset ) async {
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.t_Comment_Reply} where  "
        "touid=${Global.profile.user!.uid} and  (type = '${ReplyMsgType.commentmsg.toString()}' or"
        " type = '${ReplyMsgType.replymsg.toString()}' or type='${ReplyMsgType.evaluatemsg.toString()}'  "
        " or type='${ReplyMsgType.evaluatereplymsg.toString()}' or type='${ReplyMsgType.bugcommentmsg.toString()}' "
        " or type='${ReplyMsgType.suggestcommentmsg.toString()}' or type='${ReplyMsgType.bugreplymsg.toString()}' "
        " or type='${ReplyMsgType.suggestreplymsg.toString()}' or type='${ReplyMsgType.goodpricecommentmsg.toString()}'"
        " or type='${ReplyMsgType.goodpricereplymsg.toString()}' or type='${ReplyMsgType.momentcommentmsg.toString()}' or type='${ReplyMsgType.momentreplymsg.toString()}')"
        " order by replycreatetime desc limit ${current},${offset}");
    if (maps == null || maps.length == 0) {
      return null;
    }

    List<CommentReply> list = [];
    maps.forEach((it){
      list.add(CommentReply.fromMap(it as Map<String, dynamic>));
    });

    return list;
  }
  //获取所有关注
  Future<List<Follow>> getFollows(int current, int offset ) async {
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.t_Follow} where  "
        "uid=${Global.profile.user!.uid} order by createtime desc limit ${current},${offset}");
    if (maps == null || maps.length == 0) {
      return [];
    }

    List<Follow> list = [];
    maps.forEach((it){
      list.add(Follow.fromMap(it as Map<String, dynamic>));
    });

    return list;
  }

  //获取所有系统提醒
  Future<List<CommentReply>?> getSysNotice(int current, int offset ) async {
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.t_Comment_Reply} where  "
        "touid=${Global.profile.user!.uid} and isread=0 and type = '" + ReplyMsgType.sysnotice.toString() + "'"
        " order by touid asc, replycreatetime desc limit ${current},${offset}");
    if (maps == null || maps.length == 0) {
      return null;
    }

    List<CommentReply> list = [];
    maps.forEach((it){
      list.add(CommentReply.fromMap(it as Map<String, dynamic> ));
    });

    return list;
  }
  //保存音频文件
  Future<int> saveSoundFile(TimeLineSync timelinesync) async {
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.im_timeline_sync_relation} SET localpath = ? WHERE sequence_id = ? and timeline_id = ? and uid=?',
        [timelinesync.localpath, timelinesync.sequence_id, timelinesync.timeline_id, Global.profile.user!.uid]);
    if(Global.isInDebugMode){
      print(result);
    }
    return result;
  }
  //更新红包已经打开
  Future<int> updateReceiveRedPacket(String content, String timeline_id) async {
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.im_timeline_sync_relation} SET isopen = ? WHERE timeline_id = ? and content = ? and uid=?',
        [1, timeline_id, content, Global.profile.user!.uid]);
    if(Global.isInDebugMode){
      print(result);
    }
    return result;
  }
  //保存like
  Future<int> saveActivityState(String actid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.activity_state_table, {"actid": actid, "uid": uid});
    if(Global.isInDebugMode)
      print('ActivityLike num ${result}');
    return result;
  }
  //删除like
  Future<int> delActivityState(String actid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.activity_state_table} "
        " WHERE actid = ? and uid= ?", [actid, uid]);
    print(result);
    return result;
  }
  //查询like
  Future<int> selActivityState(String actid, int uid, Function fun) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.activity_state_table}"
        " where  uid=${uid} and actid='${actid}' ");
    List<String> actids = [];
    if(maps != null){
      maps.forEach((element) {
        actids.add(element["actid"]);
      });
      fun(actids);
    }
    return 1;
  }
  //保存GoodPricelike
  Future<int> saveGoodPriceState(String goodpriceid, int uid, int status) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.goodprice_state_table, {"goodpriceid": goodpriceid, "uid": uid, "status": status});
    if(Global.isInDebugMode)
      print('GoodPriceLike num ${result}');
    return result;
  }
  //删除like
  Future<int> delGoodPriceState(String goodpriceid, int uid, int status) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.goodprice_state_table} "
        " WHERE goodpriceid = ? and uid= ? and status = ?", [goodpriceid, uid, status]);
    return result;
  }
  //查询like
  Future<bool> selGoodPriceState(String goodpriceid, int uid, int status) async{
    bool ret = false;
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.goodprice_state_table}"
        " where  uid=${uid} and goodpriceid='${goodpriceid}' and status=${status} ");
    List<String> goodpriceids = [];
    if(maps != null){
      maps.forEach((element) {
        goodpriceids.add(element["goodpriceid"]);
        ret = true;
      });
    }
    return ret;
  }

  //查询like0bug, 1suggest, 2moment
  Future<int> selBugAndSuggestState(String actid, int uid, int type, Function fun) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.bugsuggest_state_table}"
        " where  uid=${uid} and actid='${actid}' and type=${type} ");
    List<String> actids = [];
    if(maps != null){
      maps.forEach((element) {
        actids.add(element["actid"]);
      });
      fun(actids);
    }
    return 1;
  }

  //保存like0bug, 1suggest, 2moment
  Future<int> saveBugSuggestState(String actid, int uid, int type) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.bugsuggest_state_table, {"actid": actid, "uid": uid, "type": type});
    if(Global.isInDebugMode)
      print('ActivityLike num ${result}');
    return result;
  }
  //删除like0bug, 1suggest, 2moment
  Future<int> delBugSuggestState(String actid, int uid, int type) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.bugsuggest_state_table} "
        " WHERE actid = ? and uid= ? and type = ?", [actid, uid, type]);
    print(result);
    return result;
  }
  //查询like
  Future<int> selBugSuggestState(String actid, int uid, int type, Function fun) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.bugsuggest_state_table}"
        " where  uid=${uid} and actid='${actid}' and type=${type}");
    List<String> actids = [];
    if(maps != null){
      maps.forEach((element) {
        actids.add(element["actid"]);
      });
      fun(actids);
    }
    return 1;
  }

  //查询like
  Future<int> selBugSuggestStateCount(int uid, int type) async{
    var dbClient = await _sql.db;
    var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.bugsuggest_state_table}"
        " where  uid=${uid} and type=${type}"));

    if(tem == null || tem == 0 ){
      return 0;
    }
    else{
      return tem;
    }
  }


  //查询like
  Future<int> selActivityStateCount(int uid) async{
    var dbClient = await _sql.db;
    var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.activity_state_table}"
        " where  uid=${uid}"));
    if(tem == null || tem == 0 ){
      return 0;
    }
    else{
      return tem;
    }
  }


  //保存collection
  Future<int> saveActivityCollectionState(Activity activity, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;

    result = await dbClient.insert(TableHelper.activity_collection_state_table, {"actid": activity.actid, "peoplenum":activity.peoplenum,
    "content": activity.content, "coverimg": activity.coverimg,
    "uid": activity.user!.uid, "actprovince": activity.actprovince, "actcity": activity.actcity,
    "coverimgwh": activity.coverimgwh, "username": activity.user!.username, "profilepicture": activity.user!.profilepicture,
    "mincost": activity.goodPiceModel == null ? activity.mincost : activity.goodPiceModel!.mincost,
      "lat": activity.lat, "lng": activity.lng, "maxcost": activity.goodPiceModel == null ? activity.maxcost : activity.goodPiceModel!.maxcost,
      "localuid": uid});
    if(Global.isInDebugMode)
      print('ActivityCollection num ${result}');
    return result;
  }

  //查询我的收藏
  Future<List<Activity>> selActivityCollectionByUid(int uid) async{
    var dbClient = await _sql.db;

    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.activity_collection_state_table}"
        " where  localuid=${uid}");
    List<Activity> activitys = [];
    if(maps != null){
      maps.forEach((element) {
        activitys.add(Activity.fromMapCollectionTable(element as Map<String, dynamic>));
      });
    }
    return activitys;
  }

  //查询like
  Future<int> selActivityCollectionCount(int uid) async{
    var dbClient = await _sql.db;
    var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.activity_collection_state_table}"
        " where  localuid=${uid}"));
    if(tem == null || tem == 0 ){
      return 0;
    }
    else{
      return tem;
    }
  }

  //删除collection
  Future<int> delActivityCollectionState(String actid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.activity_collection_state_table} "
        " WHERE actid = ? and localuid= ?", [actid, uid]);
    print(result);
    return result;
  }

  //保存collection
  Future<int> saveProductCollectionState(int productid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.product_collection_state_table, {"productid": productid, "uid": uid});
    if(Global.isInDebugMode)
      print('ProductCollection num ${result}');
    return result;
  }
  //删除collection
  Future<int> delProductCollectionState(int productid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.product_collection_state_table} "
        " WHERE productid = ? and uid= ?", [productid, uid]);
    print(result);
    return result;
  }
  //查询productcollection
  Future<int> selProductCollectionState(int productid, int uid, Function fun) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.product_collection_state_table}"
        " where  uid=${uid} and productid=${productid}");
    List<int> productids = [];
    if(maps != null){
      maps.forEach((element) {
        productids.add(element["productid"]);
      });
      fun(productids);
    }
    return 1;
  }
  //保存GoodPricecollection
  Future<int> saveGoodPriceCollectionState(GoodPiceModel goodPiceModel, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.goodprice_collection_state_table, {"goodpriceid": goodPiceModel.goodpriceid,
      "title": goodPiceModel.title,"content": goodPiceModel.content, "category": goodPiceModel.category,
      "brand": goodPiceModel.brand,"mincost": goodPiceModel.mincost, "maxcost": goodPiceModel.maxcost,
      "discount": goodPiceModel.discount, "endtime": goodPiceModel.endtime, "createtime": goodPiceModel.createtime,
      "albumpics": goodPiceModel.albumpics,
      "pic": goodPiceModel.pic, "collectionnum": goodPiceModel.collectionnum, "province": goodPiceModel.province, "city": goodPiceModel.city,
      "uid": goodPiceModel.uid,  "likenum": goodPiceModel.likenum, "unlikenum": goodPiceModel.unlikenum,
      "productstatus": goodPiceModel.productstatus, "satisfactionrate": goodPiceModel.satisfactionrate,
      "activitycount": goodPiceModel.activitycount, "lat": goodPiceModel.lat, "lng": goodPiceModel.lng, "address": goodPiceModel.address,
      "addresstitle": goodPiceModel.addresstitle, "commentnum": goodPiceModel.commentnum, "tag": goodPiceModel.tag, "username": goodPiceModel.username,
      "profilepicture": goodPiceModel.profilepicture,
      "localuid": uid});
    if(Global.isInDebugMode)
      print('goodprice_collection_state_table num ${result}');
    return result;
  }
  //删除GoodPricecollection
  Future<int> delGoodPriceCollectionState(String goodpriceid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.goodprice_collection_state_table} "
        " WHERE goodpriceid = ? and localuid= ?", [goodpriceid, uid]);
    if(Global.isInDebugMode)
      print(result);
    return result;
  }
  //查询productcollection
  Future<String> selGoodPriceCollectionState(String goodpriceid, int uid, Function fun) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.goodprice_collection_state_table}"
        " where  localuid=${uid} and goodpriceid='${goodpriceid}'");
    List<String> goodpriceids = [];
    if(maps != null){
      maps.forEach((element) {
        goodpriceids.add(element["goodpriceid"]);
      });
      fun(goodpriceids);
    }
    return "";
  }
  Future<int> selGoodPriceCollectionStateByUid(int uid) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.goodprice_collection_state_table}"
        " where  localuid=${uid}");
    List<String> goodpriceids = [];
    if(maps != null){
      maps.forEach((element) {
        goodpriceids.add(element["goodpriceid"]);
      });
    }
    if(maps != null)
      return maps.length;
    else{
      return 0;
    }
  }
  Future<List<GoodPiceModel>> selGoodPriceCollectionByUid(int uid) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.goodprice_collection_state_table}"
        " where  localuid=${uid}");
    List<GoodPiceModel> goodpriceids = [];
    if(maps != null){
      maps.forEach((element) {
        goodpriceids.add(GoodPiceModel.fromMap(element as Map<String, dynamic>));
      });
    }
    return goodpriceids;
  }

  //查询productcollection
  Future<int> selProductCollectionCountState(int uid) async{
    var dbClient = await _sql.db;
    var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT * FROM ${TableHelper.product_collection_state_table}"
        " where  uid=${uid} "));
    if(tem == null || tem == 0 ){
      return 0;
    }
    else{
      return tem;
    }

  }
  //查询collection
  Future<int> selActivityCollectionState(String actid, int uid, Function fun) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.activity_collection_state_table}"
        " where  localuid=${uid} and actid='${actid}' ");
    List<String> actids = [];
    if(maps != null){
      maps.forEach((element) {
        actids.add(element["actid"]);
      });
      fun(actids);
    }
    return 1;
  }

  //保存CommentState
  Future<int> saveActivityCommentState(String commentid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.activity_comment_state_table, {"commentid": commentid, "uid": uid});
    if(Global.isInDebugMode)
      print('save comment num ${result}');
    return result;
  }
  //查询CommentState
  Future<int> selActivityCommentCountState(int uid) async{
    var dbClient = await _sql.db;
    var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.activity_comment_state_table}"
        " where  uid=${uid} "));
    if(tem == null || tem == 0 ){
      return 0;
    }
    else{
      return tem;
    }

  }
  //删除CommentState
  Future<int> delActivityCommentState(String commentid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.activity_comment_state_table} "
        " WHERE commentid = ? and uid= ?", [commentid, uid]);
    if(Global.isInDebugMode)
      print('delete comment num ${result}');
    return result;
  }
  //查询CommentState
  Future<List<String>> selActivityCommentState(String commentid, int uid) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.activity_comment_state_table}"
        " where  uid=${uid} and commentid=${commentid} ");
    List<String> actids = [];
    if(maps != null){
      maps.forEach((element) {
        actids.add(element["commentid"]);
      });
    }
    return actids;
  }

  //保存CommentState
  Future<int> saveGoodPriceCommentState(String commentid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.goodprice_comment_state_table, {"commentid": commentid, "uid": uid});
    if(Global.isInDebugMode)
      print('save comment num ${result}');
    return result;
  }
  //查询CommentState
  Future<int> selGoodPriceCommentCountState(int uid) async{
    var dbClient = await _sql.db;
    var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.goodprice_comment_state_table}"
        " where  uid=${uid} "));
    if(tem == null || tem == 0 ){
      return 0;
    }
    else{
      return tem;
    }

  }
  //删除CommentState
  Future<int> delGoodPriceCommentState(String commentid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.goodprice_comment_state_table} "
        " WHERE commentid = ? and uid= ?", [commentid, uid]);
    if(Global.isInDebugMode)
      print('delete comment num ${result}');
    return result;
  }
  //查询CommentState
  Future<List<String>> selGoodPriceCommentState(String commentid, int uid) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.goodprice_comment_state_table}"
        " where  uid=${uid} and commentid=${commentid} ");
    List<String> actids = [];
    if(maps != null){
      maps.forEach((element) {
        actids.add(element["actid"]);
      });
    }
    return actids;
  }

  //保存CommentState
  Future<int> saveBugAndSuggestCommentState(String commentid, int uid, int type) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.activity_bugsuggestcomment_state_table, {"commentid": commentid, "uid": uid, "type": type});
    if(Global.isInDebugMode)
      print('save comment num ${result}');
    return result;
  }
  //查询CommentState
  Future<int> selBugAndSuggestCommentCountState(int uid, int type) async{
    var dbClient = await _sql.db;
    var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.activity_bugsuggestcomment_state_table}"
        " where  uid=${uid} and type=${type}"));
    if(tem == null || tem == 0 ){
      return 0;
    }
    else{
      return tem;
    }

  }
  //删除CommentState0 bug 1suggest 2moment
  Future<int> delBugAndSuggestCommentState(String commentid, int uid, int type) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.activity_bugsuggestcomment_state_table} "
        " WHERE commentid = ? and uid= ? and type=?", [commentid, uid, type]);
    if(Global.isInDebugMode)
      print('delete comment num ${result}');
    return result;
  }
  //查询CommentState0 bug 1suggest 2moment
  Future<List<String>> selBugAndSuggestCommentState(String commentid, int uid, int type) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.activity_bugsuggestcomment_state_table}"
        " where  uid=${uid} and commentid=${commentid} and type=${type} ");
    List<String> actids = [];
    if(maps != null){
      maps.forEach((element) {
        actids.add(element["commentid"]);
      });
    }
    return actids;
  }

  //保存活动评价点赞
  Future<int> saveActivityEvaluateState(String evaluateid, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.activity_evaluate_state_table, {"evaluateid": evaluateid, "uid": uid});
    if(Global.isInDebugMode)
      print('save evaluateid num ${result}');
    return result;
  }
  //查询CommentState
  Future<int> selActivityEvaluateCountState(int uid) async{
    var dbClient = await _sql.db;
    var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.activity_evaluate_state_table}"
        " where  uid=${uid} "));
    if(tem == null || tem == 0 ){
      return 0;
    }
    else{
      return tem;
    }
  }

  //删除ActivityEvaluate
  Future<int> delActivityEvaluateState(String v, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.activity_evaluate_state_table} "
        " WHERE evaluateid = ? and uid= ?", [v, uid]);
    if(Global.isInDebugMode)
      print('delete evaluateid num ${result}');
    return result;
  }
  //查询ActivityEvaluateState
  Future<List<String>> selActivityEvaluateState(String evaluateid, int uid) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.activity_evaluate_state_table}"
        " where  uid=${uid} and evaluateid=${evaluateid} ");
    List<String> actids = [];
    if(maps != null){
      maps.forEach((element) {
        actids.add(element["evaluateid"]);
      });
    }
    return actids;
  }

  Future<int> delAllActivityState(int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.activity_state_table} "
        " WHERE  uid= ?", [uid]);
    return result;
  }


  //保存回复内容
  Future<int> saveReplys( List<CommentReply> commentreplys, ReplyMsgType type) async {
    var dbClient = await _sql.db;
    var result = 0;

    for(CommentReply commentReply in commentreplys) {
      var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT COUNT(*) FROM ${TableHelper.t_Comment_Reply} "
          "WHERE replyid=${commentReply.replyid} and touid=${Global.profile.user!.uid} and type='${type.toString()}'" ));
      if(tem == 0 )
        if(await dbClient.insert(
            TableHelper.t_Comment_Reply, commentReply.toMap(type)) > 0){
          result++;
        }
    }

    return result;
  }

  //保存活动点赞内容
  Future<int> saveActivityLike( List<Like> likes) async {
    var dbClient = await _sql.db;
    var result = 0;

    for(Like like in likes) {
      var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT COUNT(*) FROM ${TableHelper.t_like} "
          "WHERE likeid=${like.likeid} and touid=${Global.profile.user!.uid} and liketype=${like.liketype}" ));
      if(tem == 0 )
        if(await dbClient.insert(
            TableHelper.t_like, like.toMap()) > 0){
          result++;
        }
    }

    return result;
  }

  ///获取所有未读点赞通知
  Future<int> getLikeNoticeCount() async {
    var dbClient = await _sql.db;

    if(Global.profile.user != null) {
      int? result = await Sqflite.firstIntValue(
          await dbClient.rawQuery("SELECT count(*) FROM t_like WHERE  "
              " touid=${Global.profile.user!.uid} and isread=0 "));
      if (result != null)
        return result;
      else
        return 0;
    }
    return 0;
  }

  //获取所有点赞
  Future<List<Like>> getThumbUps(int current, int offset ) async {
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.t_like} where  "
        "touid=${Global.profile.user!.uid} order by createtime desc limit ${current},${offset}");
    if (maps == null || maps.length == 0) {
      return [];
    }

    List<Like> list = [];
    maps.forEach((it){
      list.add(Like.fromMap(it as Map<String, dynamic>));
    });

    return list;
  }

  ///获取聊天关系中最大的sequence_id
  Future<int> getMaxReplyid(ReplyMsgType type) async {
    var dbClient = await _sql.db;
    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT replyid FROM Comment_Reply_table WHERE  "
        " touid=${Global.profile.user!.uid} and type='${type.toString()}' "
        "ORDER BY replyid desc LIMIT 1"));

    return result == null ? 0 : result;
  }

  ///获取聊天关系中最大的sequence_id
  Future<int> getMaxLikeID(int type) async {
    var dbClient = await _sql.db;
    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT likeid FROM t_like WHERE  "
        " touid=${Global.profile.user!.uid} and liketype=${type} "
        "ORDER BY likeid desc LIMIT 1"));
    return result == null ? 0 : result;
  }

  ///获取未读关注
  Future<int> getMaxFollowid() async {
    var dbClient = await _sql.db;
    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT id FROM t_Follow WHERE  "
        " uid=${Global.profile.user!.uid} "
        "ORDER BY id desc LIMIT 1"));
    return result == null ? 0 : result;
  }
  //保存未读关注
  Future<int> saveFollow(List<Follow> follows) async {
    var dbClient = await _sql.db;
    var result = 0;

    for(Follow follow in follows) {
      var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT COUNT(*) FROM ${TableHelper.t_Follow} "
          "WHERE id=${follow.id} and uid=${Global.profile.user!.uid} " ));
      if(tem == 0 )
        if(await dbClient.insert(
            TableHelper.t_Follow, follow.toMap(follow)) > 0){
          result++;
        }
    }
    if(Global.isInDebugMode)
      print("follow save : ${result}" );
    return result;

  }

  ///获取本地未读留言与回复
  Future<int> getCommentReplysCount() async {
    var dbClient = await _sql.db;
    if(Global.profile.user != null) {
      int? result = await Sqflite.firstIntValue(await dbClient.rawQuery(
          "SELECT count(*) FROM Comment_Reply_table WHERE  "
              " touid=${Global.profile.user!.uid} and isread=0 "));
      return result == null ? 0 : result;
    }
    return 0;
  }


  ///获取新的关注通知
  Future<int> getNewFollowCount() async {
    var dbClient = await _sql.db;
    if(Global.profile.user != null) {
      int? result = await Sqflite.firstIntValue(
          await dbClient.rawQuery("SELECT count(*) FROM t_Follow WHERE  "
              " uid=${Global.profile.user!.uid} and isread=0 "));

      return result == null ? 0 : result;

    }
    return 0;
  }
  ///获取新的待评价活动通知
  Future<int> getActivityEvaluateCount(int evaluatestatus) async {
    var dbClient = await _sql.db;

    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM unevaluate_activity WHERE  "
        " uid=${Global.profile.user!.uid} and actuid <> ${Global.profile.user!.uid} and evaluatestatus= " + evaluatestatus.toString()));

    if(result != null)
      return result;
    else
      return 0;

  }

  //获取本地未读系统通知
  Future<int> getSysNoticeCount(ReplyMsgType replyMsgType, { Function? callBack }) async {
    var dbClient = await _sql.db;
    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM Comment_Reply_table WHERE  "
        " touid=${Global.profile.user!.uid} and type='" + replyMsgType.toString() + "' and isread=0 "));
    if(result != null && result > 0 && callBack != null){
      callBack(result);
    }
    return 0;
  }
  //获取本地未读系统通知
  Future<int> getFollowCount( { Function? callBack }) async {
    var dbClient = await _sql.db;
    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.t_Follow}"
        " where  uid=${Global.profile.user!.uid} and isread=0  "));
    if(result != null && result > 0 && callBack != null){
      callBack(result);
    }
    return 0;
  }
  //回复评论通知标记成已读
  Future<int> updateReplyCommentNoticeRead(ReplyMsgType replyMsgType) async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.t_Comment_Reply} SET isread=1 WHERE type = ? and touid=?',
        [replyMsgType.toString(), Global.profile.user!.uid]);

    if(Global.isInDebugMode){
      print(count);
    }

    return count;
  }
  //查询关注情况
  Future<List<int>> selFollowState(int follow, int uid) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.community_follow_state_table}"
        " where  uid=${uid} and follow=${follow} ");
    List<int> uids = [];
    if(maps != null){
      maps.forEach((element) {
        uids.add(element["follow"]);
      });
    }
    return uids;
  }
  //查询关注情况
  Future<List<int>> selMyFollowState(int uid) async{
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.community_follow_state_table}"
        " where  uid=${uid}");
    List<int> actids = [];
    if(maps != null){
      maps.forEach((element) {
        actids.add(element["follow"]);
      });
    }
    return actids;
  }
  //保存Follow
  Future<int> saveFollowState(int follow, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.insert(TableHelper.community_follow_state_table, {"follow": follow, "uid": uid});
    if(Global.isInDebugMode)
      print('save num ${result}');
    return result;
  }
  //删除Follow
  Future<int> delFollowState(int follow, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate("delete from ${TableHelper.community_follow_state_table} "
        " WHERE follow = ? and uid= ?", [follow, uid]);
    if(Global.isInDebugMode)
      print('del follow num ${result}');
    return result;
  }

  //本地回复标记成已读
  Future<int> updateNewMemberNoticeRead() async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.user_member_state_table} SET isread=1 WHERE touid=?',
        [ Global.profile.user!.uid]);

    if(Global.isInDebugMode){
      print(count);
    }

    return count;
  }

  //本地回复标记成已读
  Future<int> updateNewFriendNoticeRead() async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.user_friend_state_table} SET isread=1 WHERE uid=?',
        [ Global.profile.user!.uid]);

    if(Global.isInDebugMode){
      print(count);
    }

    return count;
  }

  //本地关注标记成已读
  Future<int> updateFollowedNoticeRead() async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.t_Follow} SET isread=1 WHERE uid=?',
        [ Global.profile.user!.uid]);

    if(Global.isInDebugMode){
      print(count);
    }

    return count;
  }
  ///获取社团成员加入验证通知中最大的sequence_id
  Future<int> getMaxMemberId() async {
    var dbClient = await _sql.db;
    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT id FROM ${TableHelper.user_member_state_table} WHERE  "
        " touid=${Global.profile.user!.uid} "
        "ORDER BY id desc LIMIT 1"));
    if(result == null)
      return 0;
    return result;
  }
  //获取好友表最大的sequence_id
  Future<int> getMaxFriendId() async {
    var dbClient = await _sql.db;
    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT id FROM ${TableHelper.user_friend_state_table} WHERE  "
        " uid=${Global.profile.user!.uid} "
        "ORDER BY id desc LIMIT 1"));
    if(Global.isInDebugMode){
      print("getMAXFriendid ${result}");
    }

    if(result == null)
      result = 0;
    return result;
  }


  //获取最大id,来自朋友的分享
  Future<int> getMaxUserSharedId() async {
    var dbClient = await _sql.db;
    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT sharedid FROM ${TableHelper.user_shared_state_table}   "
        "WHERE uid=${Global.profile.user!.uid} "
        "ORDER BY sharedid desc LIMIT 1"));

    if(result == null)
      result = 0;
    if(Global.isInDebugMode){
      print("max shared ${result}");
    }
    return result;
  }

  Future<int> getUserSharedCount() async {
    var dbClient = await _sql.db;

    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT COUNT(*) FROM ${TableHelper.user_shared_state_table} "
        "WHERE uid=${Global.profile.user!.uid} and isread=0" ));
    if(result != null)
      return result;
    else
      return 0;
  }

  //保存来自朋友的分享
  Future<int> saveUserSharedJoin( List<UserShared> userShareds) async {
    var dbClient = await _sql.db;
    var result = 0;

    for(UserShared usershared in userShareds) {
      var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT COUNT(*) FROM ${TableHelper.user_shared_state_table} "
          "WHERE contentid='${usershared.contentid}' and uid=${Global.profile.user!.uid} " ));

      if(tem == 0 )
        if(await dbClient.insert(
            TableHelper.user_shared_state_table, usershared.toMap()) > 0){
          result++;
        }
    }

    if(Global.isInDebugMode){
      print("savefriend ${result}");
    }

    return result;
  }

  Future<int> updateUserSharedRead() async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.user_shared_state_table} SET isread=1 WHERE uid=?',
        [ Global.profile.user!.uid]);

    if(Global.isInDebugMode){
      print(count);
    }

    return count;
  }
  //点赞已读
  Future<int> updateUserLikeRead() async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.t_like} SET isread=1 WHERE touid=?',
        [ Global.profile.user!.uid]);

    if(Global.isInDebugMode){
      print(count);
    }

    return count;
  }

  //获取好友分享
  Future<List<UserShared>?> getSharedFriend(int current, int offset ) async {
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.user_shared_state_table} where  "
        "uid=${Global.profile.user!.uid} order by createtime desc limit ${current},${offset}");
    if (maps == null || maps.length == 0) {
      return null;
    }
    List<UserShared> list = [];
    if(maps != null){
      for(int i = 0; i <maps.length; i++){
        list.add(UserShared.fromMap(maps[i] as Map<String, dynamic>));
      }
    }
    return list;
  }

  //好友分享已读
  Future<void> updateSharedFriendRead() async {
    var dbClient = await _sql.db;
    int count = await dbClient.rawUpdate(
        'UPDATE ${TableHelper.user_shared_state_table} SET isread=? WHERE uid=?',
        [ 1,Global.profile.user!.uid]);

    if(Global.isInDebugMode){
      print(count);
    }
  }


  Future<int> updateFriendMember(List<User> friends) async{
    var dbClient = await _sql.db;
    var result = 0;
    for(User user in friends){
      var tem = await Sqflite.firstIntValue(await dbClient.rawQuery("update  ${TableHelper.user_friend_state_table}  set username = '${user.username}',"
          " profilepicture='${user.profilepicture}'"
          " WHERE touid=${user.uid} and uid=${Global.profile.user!.uid} " ));

      result++;
    }
    return result;
  }

  //更新记录
  Future<int> updateCommunityMember(int id) async {
    var dbClient = await _sql.db;
    var result = 0;
    result = await dbClient.rawUpdate( 'UPDATE ${TableHelper.user_member_state_table} SET status = ? where id=? ',
        [1, id]);

    return result;
  }
  //保存浏览记录
  Future<int> saveBrowseHistory(String actid, String content, String coverimg, String coverimgwh, String profilepicture, String username,
      int peoplenum, double mincost, double maxcost) async{
    var dbClient = await _sql.db;
    var result = 0;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.history_browse_table}"
        " where  actid='${actid}' and uid=${Global.profile.user!.uid} ");
    if(maps.length == 0){
      result = await dbClient.insert(TableHelper.history_browse_table, {"actid": actid, "browsetime": CommonUtil.getTime(),
        "content": content, "coverimg": coverimg==null?'':coverimg,  "uid": Global.profile.user!.uid, "coverimgwh": coverimgwh, "profilepicture":profilepicture,
        "username":username, "peoplenum": peoplenum, "mincost": mincost, "maxcost": maxcost
      });
      if(Global.isInDebugMode)
        print('save comment num ${result}');
    }
    return result;
  }
  //获取历史浏览记录
  Future<List<Activity>> getBrowseHistory(int current, int offset ) async {
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.history_browse_table} where  "
        "uid=${Global.profile.user!.uid} order by browsetime desc limit ${current},${offset}");
    if (maps == null || maps.length == 0) {
      return [];
    }

    List<Activity> list = [];
    maps.forEach((it){
      list.add(Activity.fromMap(it as Map<String, dynamic>));
    });

    return list;
  }
  //历史浏览数
  Future<int> countBrowseHistory() async{
    var dbClient = await _sql.db;
    int? result  = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.history_browse_table}"
        " where   uid=${Global.profile.user!.uid} "));
    if(result == null)
      return 0;
    return result;
  }
  //获取历史搜索记录 //0 社团 1 活动 2商品
  Future<List<HisSearch>?> getSearchHistory(int type) async {
    var dbClient = await _sql.db;
    List<Map> maps;
    if(Global.profile.user != null) {
      maps = await dbClient.rawQuery(
          "SELECT * FROM ${TableHelper.history_search_tablle} where  "
              " uid=${Global.profile.user!.uid} and type=${type} order by time desc limit 10");
    }
    else{
      maps = await dbClient.rawQuery(
          "SELECT * FROM ${TableHelper.history_search_tablle} where  "
              " type=${type} order by time desc limit 10");
    }
    if (maps == null || maps.length == 0) {
      return null;
    }

    List<HisSearch> list = [];
    maps.forEach((it){
      list.add(HisSearch.fromMap(it as Map<String, dynamic>));
    });

    return list;
  }

  //获取历史搜索记录 //0 社团 1 活动 2商品
  Future<int> saveSearchHistory(int type, String content) async {
    var dbClient = await _sql.db;
    int result = 0;
    List<Map> maps;
    if(Global.profile.user != null) {
      maps = await dbClient.rawQuery(
          "SELECT * FROM ${TableHelper.history_search_tablle}"
              " where  type='${type}' and uid=${Global.profile.user!.uid} and content='${content}'");
    }
    else{
      maps = await dbClient.rawQuery(
          "SELECT * FROM ${TableHelper.history_search_tablle}"
              " where  type='${type}' and content='${content}'");
    }
    if(maps.length == 0) {
      result = await dbClient.insert(TableHelper.history_search_tablle,
          {
            "content": content,
            "time": DateTime.now().toString(),
            "type": type,
            "uid": Global.profile.user != null ? Global.profile.user!.uid : 0
          });
    }
    if(Global.isInDebugMode)
      print('save num ${result}');

    return result;
  }

  //保存未评论活动,如果有未评论的需要全部取回
  Future<int> saveUnEvaluateActivity(List<ActivityEvaluate> activityEvaluates, int uid) async{
    var dbClient = await _sql.db;
    var result = 0;
    //先删除所有的活动,activity中的status是isevaluate的状态
    result = await dbClient.rawUpdate("delete from ${TableHelper.unevaluate_activity} "
        " WHERE  uid= ?", [uid]);

    for(int i = 0; i < activityEvaluates.length; i++){
      ActivityEvaluate activityEvaluate = activityEvaluates[i];
      result = await dbClient.insert(TableHelper.unevaluate_activity, {"actevaluateid": activityEvaluate.actevaluateid,
        "actid": activityEvaluate.activity!.actid, "createtime": activityEvaluate.activity!.createtime,
        "content": activityEvaluate.activity!.content,
        "coverimg": activityEvaluate.activity!.coverimg==null?'':activityEvaluate.activity!.coverimg,
        "uid": Global.profile.user!.uid,
        "coverimgwh": activityEvaluate.activity!.coverimgwh, "profilepicture":activityEvaluate.activity!.user!.profilepicture,
        "username": activityEvaluate.activity!.user!.username,
        "evaluatestatus": activityEvaluate.evaluatestatus, "currentpeoplenum": activityEvaluate.activity!.currentpeoplenum,
        "actuid": activityEvaluate.activity!.user!.uid
      });
      if(Global.isInDebugMode)
        print('save evaluate_activity num ${result}');
    }

    return result;
  }
  ///获取评论数量
  Future<int> getUnEvaluateActivityCount() async {
    var dbClient = await _sql.db;
    int? result = 0;
    if(Global.profile.user != null)
      result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT count(*) FROM ${TableHelper.unevaluate_activity} WHERE  "
          " uid=${Global.profile.user!.uid} "));
    if(result != null)
      return result;
    else
      return 0;
  }
  Future<int> getMaxUnEvaluateActivityid() async {
    var dbClient = await _sql.db;
    int? result = await Sqflite.firstIntValue(await dbClient.rawQuery("SELECT actevaluateid FROM ${TableHelper.unevaluate_activity} WHERE  "
        " uid=${Global.profile.user!.uid} "
        "ORDER BY actevaluateid desc LIMIT 1"));
    if(result == null)
      return 0;
    return result;
  }
  //获取为评论活动
  Future<List<ActivityEvaluate>?> getUnEvaluateActivity(int current, int offset , int evaluatestatus) async {
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.unevaluate_activity} where  "
        "uid=${Global.profile.user!.uid} and evaluatestatus=${evaluatestatus} order by createtime desc limit ${current},${offset}");
    if (maps == null || maps.length == 0) {
      return null;
    }

    List<ActivityEvaluate> list = [];
    maps.forEach((it){
      list.add(ActivityEvaluate.fromMap(it as Map<String, dynamic>));
    });

    return list;
  }
  //更新未评价活动状态
  Future<int> updateUnEvaluateActivity(int actevaluateid) async{
    var dbClient = await _sql.db;
    var result = 0;
    //先删除所有的活动,activity中的status是isevaluate的状态
    result = await dbClient.rawUpdate( 'UPDATE ${TableHelper.unevaluate_activity} SET evaluatestatus = ? where actevaluateid=? and uid=? ',
        [1, actevaluateid, Global.profile.user!.uid]);

      if(Global.isInDebugMode)
        print('update evaluate_activity status=1');

    return result;
  }
  //获取未评价活动
  Future<ActivityEvaluate?> getUnEvaluateActivityByActid(String actid) async {
    var dbClient = await _sql.db;
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.unevaluate_activity} where  "
        "uid=${Global.profile.user!.uid} and actid='${actid}'");
    if (maps == null || maps.length == 0) {
      return null;
    }

    List<ActivityEvaluate> list = [];
    maps.forEach((it){
      list.add(ActivityEvaluate.fromMap(it as Map<String, dynamic>));
    });

    return list[0];
  }

  //更新用户订单表，先删除再插入
  Future<int> saveUserOrder( int uid, int ordertype, int count) async {
    var dbClient = await _sql.db;
    var result = 0;

    await dbClient.rawUpdate(
        'delete from ${TableHelper.user_order_state_table}  where uid = ? and ordertype = ?', [uid,ordertype]);

    result = await dbClient.insert(
        TableHelper.user_order_state_table, {"uid": uid, "ordertype": ordertype, "ordercount": count});

    return result;
  }

  //更新用户未评价的订单，先删除再插入
  Future<int> saveOrderUnEvaluate( int uid, int count) async {
    var dbClient = await _sql.db;
    var result = 0;

    await dbClient.rawUpdate(
        'delete from ${TableHelper.user_orderunevaluate_state_table}  where uid = ?', [uid]);

    result = await dbClient.insert(
        TableHelper.user_orderunevaluate_state_table, {"uid": uid, "orderunevaluatecount": count});

    return result;
  }


  //0待支付 1待确认
  Future<int> getUserOrder(int ordertype) async {
    var dbClient = await _sql.db;
    int? result = 0;
    if(ordertype >= 0) {
      result = await Sqflite.firstIntValue(await dbClient.rawQuery(
          "SELECT ordercount FROM ${TableHelper.user_order_state_table} "
              " WHERE uid=${Global.profile.user!.uid} and ordertype=${ordertype}"));
    }
    else{
      result = await Sqflite.firstIntValue(await dbClient.rawQuery(
          "SELECT sum(ordercount) FROM ${TableHelper.user_order_state_table} "
              " WHERE uid=${Global.profile.user!.uid} "));
    }
    if(result != null)
      return result;
    else
      return 0;
  }
  //未评价的订单
  Future<int> getUserUnEvaluateOrder() async {
    var dbClient = await _sql.db;
    int? result = 0;
    result = await Sqflite.firstIntValue(await dbClient.rawQuery(
        "SELECT orderunevaluatecount FROM ${TableHelper.user_orderunevaluate_state_table} "
            " WHERE uid=${Global.profile.user!.uid} "));

    if(result != null && result != -1)
      return result;
    else
      return 0;
  }

  //未评价订单数量-1
  Future<int> updateUnEvaluateOrder() async {
    var dbClient = await _sql.db;
    int result = 0;
    result = await dbClient.rawUpdate( 'UPDATE ${TableHelper.user_orderunevaluate_state_table} SET orderunevaluatecount = '
        'orderunevaluatecount-1 where uid=? ',
        [Global.profile.user!.uid]);

    if(result != null)
      return result;
    else
      return 0;
  }

  //临时更新订单数量，服务端已经更新，待确认没有推送到本地
  Future<int> updateUserOrder(int ordertype) async {
    var dbClient = await _sql.db;
    int result = 0;
    if(ordertype >= 0) {
      result = await dbClient.rawUpdate( 'UPDATE ${TableHelper.user_order_state_table} SET ordercount = ordercount-1 where ordertype=? and uid=? ',
          [ordertype,  Global.profile.user!.uid]);
    }

    if(result != null)
      return result;
    else
      return 0;
  }

  //保存不感兴趣
  Future<int> saveNotInteresteduids( int uid, int notinteresteduid) async {
    var dbClient = await _sql.db;
    var result = 0;

    result = await dbClient.insert(
        TableHelper.user_notinteresteduids, {"uid": uid, "notinteresteduid": notinteresteduid});

    return result;
  }
  //取消不感兴趣
  Future<int> delNotInteresteduids( int uid, int notinteresteduid) async {
    var dbClient = await _sql.db;
    var result = 0;

    await dbClient.rawUpdate(
        'delete from ${TableHelper.user_notinteresteduids}  where uid = ? and notinteresteduid = ?', [uid,notinteresteduid]);

    return result;
  }
  //查询不感兴趣
  Future<List<int>> getNotInteresteduids(int uid) async {
    var dbClient = await _sql.db;
    List<int> list = [];

    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.user_notinteresteduids} where  "
        "uid=${uid}");
    if (maps == null || maps.length == 0) {
      return list;
    }

    maps.forEach((it){
      list.add(it["notinteresteduid"]);
    });

    return list;
  }

  //保存不感兴趣
  Future<int> saveGoodPriceNotInteresteduids( int uid, int goodpricenotinteresteduid) async {
    var dbClient = await _sql.db;
    var result = 0;

    result = await dbClient.insert(
        TableHelper.user_goodnotinteresteduids, {"uid": uid, "goodpricenotinteresteduid": goodpricenotinteresteduid});

    return result;
  }
  //取消不感兴趣
  Future<int> delGoodPriceNotInteresteduids( int uid, int goodpricenotinteresteduid) async {
    var dbClient = await _sql.db;
    var result = 0;

    await dbClient.rawUpdate(
        'delete from ${TableHelper.user_goodnotinteresteduids}  where uid = ? and goodpricenotinteresteduid = ?', [uid,goodpricenotinteresteduid]);

    return result;
  }
  //查询不感兴趣
  Future<List<int>> getGoodPriceNotInteresteduids(int uid) async {
    var dbClient = await _sql.db;
    List<int> list = [];

    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.user_goodnotinteresteduids} where  "
        "uid=${uid}");
    if (maps == null || maps.length == 0) {
      return list;
    }

    maps.forEach((it){
      list.add(it["goodpricenotinteresteduid"]);
    });

    return list;
  }

  //保存黑名单
  Future<int> saveBlacklistUid( int uid, int blacklistuid) async {
    var dbClient = await _sql.db;
    var result = 0;

    result = await dbClient.insert(
        TableHelper.user_blacklist, {"uid": uid, "blacklistuid": blacklistuid});

    return result;
  }
  //取消黑名单
  Future<int> delBlacklistUid( int uid, int blacklistuid) async {
    var dbClient = await _sql.db;
    var result = 0;

    await dbClient.rawUpdate(
        'delete from ${TableHelper.user_blacklist}  where uid = ? and blacklistuid = ?', [uid,blacklistuid]);

    return result;
  }
  //查询黑名单
  Future<List<int>> getBlacklistUid(int uid) async {
    var dbClient = await _sql.db;
    List<int> list = [];

    List<Map> maps = await dbClient.rawQuery("SELECT * FROM ${TableHelper.user_blacklist} where  "
        "uid=${uid}");
    if (maps == null || maps.length == 0) {
      return list;
    }

    maps.forEach((it){
      list.add(it["blacklistuid"]);
    });

    return list;
  }

}
