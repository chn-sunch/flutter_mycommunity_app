import 'package:dio/dio.dart';
import 'package:flutter_app/model/searchresult.dart';


import '../util/imhelper_util.dart';
import '../util/net_util.dart';
import '../util/showmessage_util.dart';
import '../model/comment.dart';
import '../model/im/imreport.dart';
import '../model/user.dart';
import '../model/im/grouprelation.dart';
import '../model/im/timelinesync.dart';
import '../model/im/redpacket.dart';
import '../model/im/redpacketdetail.dart';
import '../model/bugsuggestion/bug.dart';
import '../model/bugsuggestion/suggest.dart';
import '../model/bugsuggestion/moment.dart';
import '../model/im/community.dart';
import '../global.dart';


class ImService {
  ImHelper imhelper = new ImHelper();


  Future<void> saveLocalStore(
      List<GroupRelation> grouprelationlist, String token, int uid,
      Function errorCallBack) async {
    if (await imhelper.saveGroupRelation(grouprelationlist) > 0) {
      for (GroupRelation groupRelation in grouprelationlist) {
        //如果有未读消息，链接服务器获取
        if (groupRelation.unreadcount > 0) {
          if (Global.isInDebugMode) {
            print("groupname:${groupRelation
                .group_name1},timeline_id:${groupRelation
                .timeline_id},unread:${groupRelation.unreadcount},"
                "readindex:${groupRelation.readindex}");
          }
          int sequence_id = groupRelation.readindex!;

          ///服务器获取的已读数据和本地缓存的对比，使用最新的
          var temsequence_id = await imhelper.getMaxsequence_id(
              groupRelation.timeline_id);

          ///如果本地已储存的数据大于服务器则使用本地最新数据id
          if (temsequence_id != null && temsequence_id > sequence_id) {
            sequence_id = temsequence_id;
          }

          FormData formData = FormData.fromMap({
            "token": token,
            "uid": uid,
            "timeline_id": groupRelation.timeline_id,//取消唯一ID，可以批量获取数据，暂时不使用
            "sequence_id": sequence_id, //服务器已读的
          });

          ///通过自增的已读ID获取未读消息.活动
          if(groupRelation.relationtype == 0 || groupRelation.relationtype == 3) {
            await NetUtil.getInstance().post(formData, "/IM/getGroupConversationTimelineId", (Map<String, dynamic> data) async {
              List<TimeLineSync> timelinesynclist = [];
              for (int i = 0; i < data["data"].length; i++) {
                TimeLineSync timeLineSync = TimeLineSync.fromMapByServer(
                    data["data"][i]);
                timelinesynclist.add(timeLineSync);
              }
              var count = await imhelper.saveMessage(timelinesynclist);
              if (count > 0) {
                await postReadMessage(groupRelation.timeline_id, token, uid, errorCallBack);
              }
              else if(temsequence_id > groupRelation.readindex!){
                //本地大于服务器将服务器重新设置为0
                await postReadMessage(groupRelation.timeline_id, token, uid, errorCallBack);
              }

              if (Global.isInDebugMode)
                print("save timelinesync_table count: ${count}");
            }, errorCallBack);
          }
          //社团
          if(groupRelation.relationtype == 1){
            await NetUtil.getInstance().post(
                formData, "/IM/getCommunityConversationTimelineId", (
                Map<String, dynamic> data) async {
              List<TimeLineSync> timelinesynclist = [];
              for (int i = 0; i < data["data"].length; i++) {
                TimeLineSync timeLineSync = TimeLineSync.fromMapByServer(
                    data["data"][i]);
                timelinesynclist.add(timeLineSync);
                if(Global.profile.communitys == null ){
                  await getMyCommunityListByUser(0, uid);
                }
                else{
                  if(!Global.profile.communitys!.contains(timeLineSync.timeline_id)){
                    await getMyCommunityListByUser(0, uid);
                  }
                }
              }
              var count = await imhelper.saveMessage(timelinesynclist);
              if (count > 0) {
                await postCommunityReadMessage(
                    groupRelation.timeline_id, token, uid, errorCallBack);
              }
              else if(temsequence_id > groupRelation.readindex!){
                //本地大于服务器将服务器重新设置为0
                await postReadMessage(groupRelation.timeline_id, token, uid, errorCallBack);
              }
              if (Global.isInDebugMode)
                print("save timelinesync_table count: ${count}");
            }, errorCallBack);
          }
          //私聊
          if(groupRelation.relationtype == 2){
            await NetUtil.getInstance().post(
                formData, "/IM/getSingleConversationTimelineId", (
                Map<String, dynamic> data) async {
              List<TimeLineSync> timelinesynclist = [];
              for (int i = 0; i < data["data"].length; i++) {
                TimeLineSync timeLineSync = TimeLineSync.fromMapByServer(
                    data["data"][i]);
                timelinesynclist.add(timeLineSync);
              }
              var count = await imhelper.saveMessage(timelinesynclist);
              if (count > 0) {
                await postSingleReadMessage(
                    groupRelation.timeline_id, token, uid, errorCallBack);
              }
              else if(temsequence_id > groupRelation.readindex!){
                //本地大于服务器将服务器重新设置为0
                await postReadMessage(groupRelation.timeline_id, token, uid, errorCallBack);
              }
              if (Global.isInDebugMode)
                print("save timelinesync_table count: ${count}");
            }, errorCallBack);
          }

        }
      }
    }
  }

  //保存消息
  Future<bool> saveTimeLineSync(TimeLineSync timeLineSync,  token, uid, errorCallBack) async {
    List<TimeLineSync> tem = [];
    tem.add(timeLineSync);
    var count = await imhelper.saveMessage(tem);
    if (count > 0) {
      await postReadMessage(
          timeLineSync.timeline_id!, token, uid, errorCallBack);
    }
    return true;
  }
  //保存消息
  Future<bool> saveCommunityTimeLineSync(TimeLineSync timeLineSync,  token, uid, errorCallBack) async {
    List<TimeLineSync> tem = [];
    tem.add(timeLineSync);
    var count = await imhelper.saveMessage(tem);
    if (count > 0) {
      await postCommunityReadMessage(
          timeLineSync.timeline_id!, token, uid, errorCallBack);
    }

    return true;
  }
  //保存消息
  Future<bool> saveSingleTimeLineSync(TimeLineSync timeLineSync,  token, uid, errorCallBack) async {
    List<TimeLineSync> tem = [];
    tem.add(timeLineSync);
    var count = await imhelper.saveMessage(tem);
    if (count > 0) {
      await postSingleReadMessage(
          timeLineSync.timeline_id!, token, uid, errorCallBack);
    }

    return true;
  }
  //同步群聊关系，活动群，社团群，私聊群
  Future<List<GroupRelation>?> syncRelation(int uid, String token, Function errorCallBack) async {
    List<GroupRelation>? grouprelationlist = null;
    //如果本地没有数据，并且
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/listMyGroupConversations", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        grouprelationlist = [];
        for (int i = 0; i < data["data"].length; i++) {
          GroupRelation groupRelation = GroupRelation.fromJson(
              (data["data"][i]));
          grouprelationlist!.add(groupRelation);
        }
      }
    }, errorCallBack);
    return grouprelationlist;
  }
  //同步群聊关系，活动群
  Future<List<GroupRelation>?> syncActivityRelation(int uid, String token, Function errorCallBack) async {
    List<GroupRelation>? grouprelationlist = null;

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/listActivityGroupConversations", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        grouprelationlist = [];
        for (int i = 0; i < data["data"].length; i++) {
          GroupRelation groupRelation = GroupRelation.fromJson(
              (data["data"][i]));
          grouprelationlist!.add(groupRelation);
        }
      }
    }, errorCallBack);
    return grouprelationlist;
  }
  //同步群聊关系，活动群，获取所有记录包括已读的
  Future<List<GroupRelation>?> syncActivityRelationInit(int uid, String token, Function errorCallBack) async {
    List<GroupRelation>? grouprelationlist = null;

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/listActivityGroupConversationsInit", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        grouprelationlist = [];
        for (int i = 0; i < data["data"].length; i++) {
          GroupRelation groupRelation = GroupRelation.fromJson(
              (data["data"][i]));
          grouprelationlist!.add(groupRelation);
        }
      }
    }, errorCallBack);
    return grouprelationlist;
  }
  //同步群聊关系，社团群
  Future<List<GroupRelation>?> syncCommunityRelation(int uid, String token, Function errorCallBack) async {
    List<GroupRelation>? grouprelationlist = null;

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/listCommunityGroupConversations", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        grouprelationlist =  [];
        for (int i = 0; i < data["data"].length; i++) {
          GroupRelation groupRelation = GroupRelation.fromJson(
              (data["data"][i]));
          grouprelationlist!.add(groupRelation);
        }
      }
    }, errorCallBack);
    return grouprelationlist;
  }
  //同步私聊关系，私聊
  Future<List<GroupRelation>?> syncSingleRelation(int uid, String token, Function errorCallBack) async {
    List<GroupRelation>? grouprelationlist = null;

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/listSingleGroupConversations", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        grouprelationlist = [];
        for (int i = 0; i < data["data"].length; i++) {
          GroupRelation groupRelation = GroupRelation.fromJson(
              (data["data"][i]));
          grouprelationlist!.add(groupRelation);
        }
      }
    }, errorCallBack);
    return grouprelationlist;
  }
  //获取群聊成员
  Future<List<User>> getGroupAllUsers(String timeline_id, String token, int uid, Function errorCallBack) async {
    List<User> users= [];
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "timeline_id": timeline_id,
    });

    await NetUtil.getInstance().post(formData, "/IM/getGroupAllUsers", (
        Map<String, dynamic> data){
      if(data["data"] != null){
        for(int i=0; i<data["data"].length; i++){
          users.add(User.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    return users;
  }
//获取用户所在社团,当前用户调用，因为要保存到本地
  Future<List<Community>> getMyCommunityListByUser(int currentIndex,
      int uid) async {
    List<Community> communitys = [];
    List<Community> sortlists = [];

    List<String> listcommunity = [];

    await NetUtil.getInstance().get(
        "/Community/getCommunityListByUser", (Map<String, dynamic> data) {
      if (data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          Community community = Community.fromJson(data["data"][i]);
          if (community.uid == uid) {
            communitys.add(community);
          }
          else {
            sortlists.add(community);
          }
          listcommunity.add(community.cid);
        }
        communitys.addAll(sortlists);
        if (Global.profile.user!.uid == uid) {
          Global.profile.communitys = listcommunity;
          Global.saveProfile();
        }
      }
    }, params: {"currentIndex": currentIndex.toString(), "uid": uid.toString()},
        errorCallBack: (String statusCode, String msg) {
          ShowMessage.showToast(msg);
        });
    return communitys;
  }
  //已读消息，活动关系消息已读
  Future<bool> postReadMessage(String timeline_id, String token, int uid, Function errorCallBack) async {
    bool ret = false;
    int readindex = await imhelper.getMaxsequence_id(timeline_id);
    if(readindex!=null){
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
        "timeline_id": timeline_id,
        "sequence_id": readindex, //已经下载的消息索引，下载后标记为已经读取到本地
      });

      await NetUtil.getInstance().post(formData, "/IM/updateGroupMessageAlready", (
          Map<String, dynamic> data){
        ret = true;
      }, errorCallBack);
    }
    return ret;
  }
  //已读消息，个人私聊消息已读
  Future<bool> postSingleReadMessage(String timeline_id, String token, int uid, Function errorCallBack) async {
    bool ret = false;
    int readindex = await imhelper.getMaxsequence_id(timeline_id);
    if(readindex!=null){
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
        "timeline_id": timeline_id,
        "sequence_id": readindex, //已经下载的消息索引，下载后标记为已经读取到本地
      });

      await NetUtil.getInstance().post(formData, "/IM/postSingleReadMessage", (
          Map<String, dynamic> data){
        ret = true;
      }, errorCallBack);
    }
    return ret;
  }
  //已读消息，社团关系消息已读
  Future<bool> postCommunityReadMessage(String timeline_id, String token, int uid, Function errorCallBack) async {
    bool ret = false;
    int readindex = await imhelper.getMaxsequence_id(timeline_id);
    if(readindex!=null){
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
        "timeline_id": timeline_id,
        "sequence_id": readindex, //已经下载的消息索引，下载后标记为已经读取到本地
      });

      await NetUtil.getInstance().post(formData, "/IM/updateCommunityMessageAlready", (
          Map<String, dynamic> data){
        ret = true;
      }, errorCallBack);
    }
    return ret;
  }
  //消息已经下载
  Future<bool> LoadedMessage(String timeline_id, String token, int uid, Function errorCallBack) async {
    bool ret = false;
    int readindex = await imhelper.getMaxsequence_id(timeline_id);
    if(readindex!=null){
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
        "timeline_id": timeline_id,
        "sequence_id": readindex, //服务器已读的
      });

      await NetUtil.getInstance().post(formData, "/IM/LoadedMessage", (
          Map<String, dynamic> data){
        ret = true;
      }, errorCallBack);
    }


    return ret;
  }
  //发送群聊消息
  Future<String> postSendMessage(String timeline_id, String token, int uid, String content, int contenttype,
      int relationtype, String captchaVerification, Function errorCallBack) async {
    String ret = "";
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "timeline_id": timeline_id,
      "content": content,
      "contenttype": contenttype,
      "captchaVerification": captchaVerification
    });

    if(relationtype == 0 || relationtype == 3) {//拼玩和团购
      await NetUtil.getInstance().post(
          formData, "/IM/sendGroupMessage", (Map<String, dynamic> data) {
        ret = data["data"];
      }, errorCallBack);
      return ret;
    }
    else if (relationtype == 1){
      await NetUtil.getInstance().post(
          formData, "/IM/sendCommunityMessage", (Map<String, dynamic> data) {
        ret = data["data"];
      }, errorCallBack);
      return ret;
    }
    else if (relationtype == 2){
      await NetUtil.getInstance().post(
          formData, "/IM/sendSingleMessage", (Map<String, dynamic> data) {
        ret = data["data"];
      }, errorCallBack);
      return ret;
    }

    return ret;
  }
  //撤回消息
  Future<bool> recallMessage(String timeline_id, String token, int uid, String username, String source_id,
      int relationtype, Function errorCallBack) async {
    bool ret = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "timeline_id": timeline_id,
      "username": username,
      "source_id": source_id,
      "relationtype": relationtype
    });

    await NetUtil.getInstance().post(
        formData, "/IM/recallMessage", (Map<String, dynamic> data) {
      ret = true;
    }, errorCallBack);
    return ret;
  }
  //获取订单详情
  Future<String> getActivityInfo(String actid, String token, int uid, Function errorCallBack) async {
    String retmsg = "";
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "actid": actid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/orderActivityVerify", (
        Map<String, dynamic> data){
      retmsg = data["data"];
    }, errorCallBack);

    return retmsg;
  }

  //更新活动状态准备就绪
  Future<String> updateActivityLocked(String actid, int uid, String token, int locked, Function errorCallBack) async{
    String retmsg = "-1";
    if(locked == 0) {
      ShowMessage.showCenterToast("开始中");
    }
    else{
      ShowMessage.showCenterToast("取消中");
    }
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/updateActivityLocked", (Map<String, dynamic> data) {
      ShowMessage.cancel();
      retmsg = data["data"];
    }, errorCallBack);
    return retmsg;
  }

  //聊天中拉黑用户
  Future<bool> updateBlockUser(String timeline_id, String token, int uid, int relationtype, Function errorCallBack) async {
    bool ret = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "timeline_id": timeline_id,
    });
    if(relationtype == 2) {
      await NetUtil.getInstance().post(
          formData, "/IM/updateBlockUser", (Map<String, dynamic> data) {
        ret = true;
      }, errorCallBack);
    }
    else if(relationtype == 0 || relationtype == 3){
      await NetUtil.getInstance().post(
          formData, "/IM/updateBlockActivity", (Map<String, dynamic> data) {
        ret = true;
      }, errorCallBack);
    }
    else if(relationtype == 1){
      await NetUtil.getInstance().post(
          formData, "/IM/updateBlockCommunity", (Map<String, dynamic> data) {
        ret = true;
      }, errorCallBack);
    }
    return ret;
  }

  //聊天中取消拉黑用户
  Future<bool> updateCancelBlockUser(String timeline_id, String token, int uid, int relationtype, Function errorCallBack) async {
    bool ret = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "timeline_id": timeline_id,
    });
    if(relationtype == 2) {
      await NetUtil.getInstance().post(
          formData, "/IM/updateCancelBlockUser", (Map<String, dynamic> data) {
        ret = true;
      }, errorCallBack);
    }
    else if (relationtype == 0 || relationtype == 3) {
      await NetUtil.getInstance().post(
          formData, "/IM/updateCancelBlockActivity", (Map<String, dynamic> data) {
        ret = true;
      }, errorCallBack);
    }
    else if (relationtype == 1) {
      await NetUtil.getInstance().post(
          formData, "/IM/updateCancelBlockCommunity", (Map<String, dynamic> data) {
        ret = true;
      }, errorCallBack);
    }
    return ret;
  }

  //
  //举报聊天群
  Future<String> reportOtherIm(int uid,  String token,  String timeline_id, int reporttype, String reportcontent,
      String images, Function errorCallBack) async {
    String ret = "";
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "timeline_id": timeline_id,
      "reporttype": reporttype,
      "reportcontent": reportcontent,
      "images": images,
    });

    await NetUtil.getInstance().post(formData, "/IM/reportOtherIm", (Map<String, dynamic> data) {
      ret = data["data"];
    }, errorCallBack);
    return ret;
  }

  //获取我的举报详情
  Future<ImReport?> getMyReportInfo(int uid, String token, String reportid, Function errorCallBack) async{
    ImReport? myReport = null;

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "reportid": reportid
    });
    await NetUtil.getInstance().post(formData, "/IM/getMyImReportInfo", (Map<String, dynamic> data) {
      myReport = ImReport.fromJson(data["data"]);
    }, errorCallBack);
    return myReport;
  }

  //获取我的举报
  Future<List<ImReport>?> getMyReport(int uid, String token, Function errorCallBack) async{
    List<ImReport> myReports = [];

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/getMyImReport", (Map<String, dynamic> data) {
      for (int i = 0; i < data["data"].length; i++) {
        ImReport myReport = ImReport.fromJson(data["data"][i]);
        myReports.add(myReport);
      }    }, errorCallBack);
    return myReports;
  }

  //举报BUG
  Future<String> reportBUG(int uid,  String token, String reportcontent,
      String images, String captchaVerification, Function errorCallBack) async {
    String ret = "";
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "reportcontent": reportcontent,
      "images": images,
      "captchaVerification": captchaVerification
    });

    await NetUtil.getInstance().post(formData, "/IM/reportBUG", (Map<String, dynamic> data) {
      ret = data["data"];
    }, errorCallBack);
    return ret;
  }

  //举报BUG
  Future<String> reportSuggest(int uid,  String token, String reportcontent,
      String images, String captchaVerification, Function errorCallBack) async {
    String ret = "";
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "reportcontent": reportcontent,
      "images": images,
      "captchaVerification": captchaVerification

    });

    await NetUtil.getInstance().post(formData, "/IM/reportSuggest", (Map<String, dynamic> data) {
      ret = data["data"];
    }, errorCallBack);
    return ret;
  }

  //发布moment
  Future<String> reportMoment(int uid,  String token, String content, String voice,
      String images, String coverimgwh, String category, String captchaVerification, Function errorCallBack) async {
    String ret = "";
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "content": content,
      "voice": voice,
      "category": category,
      "images": images,
      "coverimgwh": coverimgwh,
      "captchaVerification": captchaVerification
    });

    await NetUtil.getInstance().post(formData, "/IM/reportMoment", (Map<String, dynamic> data) {
      ret = data["data"];
    }, errorCallBack);
    return ret;
  }

  //删除moment
  Future<bool> delMoment(String token, int uid,  String momentid, Function errorCallBack) async {
    bool ret = false;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "momentid": momentid,
    });

    await NetUtil.getInstance().post(formData, "/IM/delMoment", (Map<String, dynamic> data) {
      ret = true;
    }, errorCallBack);

    return ret;
  }


  //获取suggest列表
  Future<List<Bug>> getBugList(int uid,  String token, int currIndex, Function errorCallBack) async {
    List<Bug> bugs = [];
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "currIndex": currIndex,
    });

    await NetUtil.getInstance().post(formData, "/IM/getBugList", (Map<String, dynamic> data) {
      for (int i = 0; i < data["data"].length; i++) {
        Bug bug = Bug.fromJson(data["data"][i]);
        bugs.add(bug);
      }
    }, errorCallBack);
    return bugs;
  }

  Future<Bug?> getBugInfo(int uid,  String token, String bugid, Function errorCallBack) async {
    Bug? bug;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "bugid": bugid,
    });

    await NetUtil.getInstance().post(formData, "/IM/getBugInfo", (Map<String, dynamic> data) {
      bug = Bug.fromJson(data["data"]);
    }, errorCallBack);
    return bug;
  }

  //获取suggest列表
  Future<List<Suggest>> getSuggestList(int uid,  String token, int currIndex, Function errorCallBack) async {
    List<Suggest> suggests = [];
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "currIndex": currIndex,
    });

    await NetUtil.getInstance().post(formData, "/IM/getSuggestList", (Map<String, dynamic> data) {
      for (int i = 0; i < data["data"].length; i++) {
        Suggest suggest = Suggest.fromJson(data["data"][i]);
        suggests.add(suggest);
      }
    }, errorCallBack);
    return suggests;
  }

  Future<Suggest?> getSuggestInfo(int uid,  String token, String suggestid, Function errorCallBack) async {
    Suggest? suggest;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "suggestid": suggestid,
    });

    await NetUtil.getInstance().post(formData, "/IM/getSuggestInfo", (Map<String, dynamic> data) {
      suggest = Suggest.fromJson(data["data"]);
    }, errorCallBack);
    return suggest;
  }

  //获取moment列表
  Future<List<Moment>> getMomentList(int currIndex, String subject, Function errorCallBack) async {
    List<Moment> moments = [];
    FormData formData = FormData.fromMap({
      "currIndex": currIndex,
      "subject" : subject
    });

    await NetUtil.getInstance().post(formData, "/IM/getMomentList", (Map<String, dynamic> data) {
      for (int i = 0; i < data["data"].length; i++) {
        Moment moment = Moment.fromJson(data["data"][i]);
        moments.add(moment);
      }
    }, errorCallBack);
    return moments;
  }

  Future<Moment?> getMomentInfo(String momentid, Function errorCallBack) async {
    Moment? moment;
    FormData formData = FormData.fromMap({
      "momentid": momentid,
    });

    await NetUtil.getInstance().post(formData, "/IM/getMomentInfo", (Map<String, dynamic> data) {
      moment = Moment.fromJson(data["data"]);
    }, errorCallBack);
    return moment;
  }

  Future<List<Moment>> getMomentListByUser(int uid, Function errorCallBack) async {
    List<Moment> moments = [];
    FormData formData = FormData.fromMap({
      "uid" :  uid,
    });

    await NetUtil.getInstance().post(formData, "/IM/getMomentListByUser", (Map<String, dynamic> data) {
      for (int i = 0; i < data["data"].length; i++) {
        Moment moment = Moment.fromJson(data["data"][i]);
        moments.add(moment);
      }
    }, errorCallBack);
    return moments;
  }


  //BUG点赞
  Future<bool> updateBugLike(String bugid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "bugid": bugid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/updateBugLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate){
      await imhelper.saveBugSuggestState(bugid,  uid, 0);
    }

    return isUpdate;
  }

  //取消点赞
  Future<bool> delBugLike(String bugid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "bugid": bugid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/delBugLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.delBugSuggestState(bugid, uid, 0);
    }
    return isUpdate;
  }

  //BUG点赞
  Future<bool> updateSuggestLike(String suggestid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "suggestid": suggestid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/updateSuggestLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate){
      await imhelper.saveBugSuggestState(suggestid,  uid, 1);
    }

    return isUpdate;
  }

  //取消点赞
  Future<bool> delSuggestLike(String suggestid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "suggestid": suggestid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/delSuggestLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.delBugSuggestState(suggestid, uid, 1);
    }
    return isUpdate;
  }

  //moment点赞
  Future<bool> updateMomentLike(String momentid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "momentid": momentid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/updateMomentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate){
      await imhelper.saveBugSuggestState(momentid,  uid, 2);
    }

    return isUpdate;
  }

  //取消点赞
  Future<bool> delMomentLike(String momentid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "momentid": momentid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/delMomentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.delBugSuggestState(momentid, uid, 2);
    }
    return isUpdate;
  }

  //留言
  Future<int> updateBugMessage(String bugid, int uid, String token, int touid, String content,  String captchaVerification, Function errorCallBack) async{
    int commentid = 0;

    FormData formData = FormData.fromMap({
      "commentid": commentid,
      "token": token,
      "bugid": bugid,
      "uid": uid,
      "touid": touid,
      "content": content,
      "captchaVerification": captchaVerification
    });
    await NetUtil.getInstance().post(formData, "/IM/updateBugComment", (Map<String, dynamic> data) {
      commentid = int.parse(data["data"].toString());
    }, errorCallBack);
    return commentid;
  }

  //留言回复
  Future<int> updateBugCommentReply(int commentid, String bugid, int uid, String token, int touid,  String content,
      String captchaVerification, Function errorCallBack) async{
    int isret = 0;

    FormData formData = FormData.fromMap({
      "commentid": commentid,
      "token": token,
      "bugid": bugid,
      "uid": uid,
      "touid": touid,
      "content": content,
      "captchaVerification": captchaVerification
    });
    await NetUtil.getInstance().post(formData, "/IM/updateBugComment", (Map<String, dynamic> data) {
      isret = int.parse(data["data"].toString());
    }, errorCallBack);
    return isret;
  }

  //留言
  Future<int> updateSuggestMessage(String suggestid, int uid, String token, int touid,  String content, String captchaVerification,
      Function errorCallBack) async{
    int commentid = 0;

    FormData formData = FormData.fromMap({
      "commentid": commentid,
      "token": token,
      "suggestid": suggestid,
      "uid": uid,
      "touid": touid,
      "content": content,
      "captchaVerification": captchaVerification

    });
    await NetUtil.getInstance().post(formData, "/IM/updateSuggestComment", (Map<String, dynamic> data) {
      commentid = int.parse(data["data"].toString());
    }, errorCallBack);
    return commentid;
  }
  //留言回复
  Future<int> updateSuggestCommentReply(int commentid, String suggestid, int uid, String token, int touid,
      String content, String captchaVerification,Function errorCallBack) async{
    int isret = 0;

    FormData formData = FormData.fromMap({
      "commentid": commentid,
      "token": token,
      "suggestid": suggestid,
      "uid": uid,
      "touid": touid,
      "content": content,
      "captchaVerification": captchaVerification

    });
    await NetUtil.getInstance().post(formData, "/IM/updateSuggestComment", (Map<String, dynamic> data) {
      isret = int.parse(data["data"].toString());
    }, errorCallBack);
    return isret;
  }

  Future<int> updateMomentMessage(String momentid, int uid, String token, int touid, String content,  String captchaVerification, Function errorCallBack) async{
    int commentid = 0;

    FormData formData = FormData.fromMap({
      "commentid": commentid,
      "token": token,
      "momentid": momentid,
      "uid": uid,
      "touid": touid,
      "content": content,
      "captchaVerification": captchaVerification
    });
    await NetUtil.getInstance().post(formData, "/IM/updateMomentComment", (Map<String, dynamic> data) {
      commentid = int.parse(data["data"].toString());
    }, errorCallBack);
    return commentid;
  }

  //留言回复
  Future<int> updateMomentCommentReply(int commentid, String momentid, int uid, String token, int touid,  String content,
      String captchaVerification, Function errorCallBack) async{
    int isret = 0;

    FormData formData = FormData.fromMap({
      "commentid": commentid,
      "token": token,
      "momentid": momentid,
      "uid": uid,
      "touid": touid,
      "content": content,
      "captchaVerification": captchaVerification
    });
    await NetUtil.getInstance().post(formData, "/IM/updateMomentComment", (Map<String, dynamic> data) {
      isret = int.parse(data["data"].toString());
    }, errorCallBack);
    return isret;
  }

  //删除留言
  //取消留言
  Future<bool> delMessage(String token, int uid, int commentid, String bugid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "uid": uid,
      "replyid": 0,
      "bugid": bugid
    });
    await NetUtil.getInstance().post(formData, "/IM/delBugComment", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  Future<bool> delMessageReply(String token, int uid, int replyid, String bugid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": 0,
      "uid": uid,
      "replyid": replyid,
      "bugid": bugid
    });
    await NetUtil.getInstance().post(formData, "/IM/delBugComment", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  Future<bool> delMessageSuggest(String token, int uid, int commentid, String suggestid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "uid": uid,
      "replyid": 0,
      "suggestid": suggestid
    });
    await NetUtil.getInstance().post(formData, "/IM/delSuggestComment", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  Future<bool> delMessageReplySuggest(String token, int uid, int replyid, String suggestid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": 0,
      "uid": uid,
      "replyid": replyid,
      "suggestid": suggestid
    });
    await NetUtil.getInstance().post(formData, "/IM/delSuggestComment", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  Future<bool> delMomentMessage(String token, int uid, int commentid, String momentid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "uid": uid,
      "replyid": 0,
      "momentid": momentid
    });
    await NetUtil.getInstance().post(formData, "/IM/delMomentComment", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  Future<bool> delMomentMessageReply(String token, int uid, int replyid, String momentid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": 0,
      "uid": uid,
      "replyid": replyid,
      "momentid": momentid
    });
    await NetUtil.getInstance().post(formData, "/IM/delMomentComment", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }


  //获取留言
  Future<List<Comment>> getBugCommentList(String bugid, int uid, Function errorCallBack) async {
    List<Comment> listComments = [];
    await NetUtil.getInstance().get("/IM/getBugComment", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          Comment comment = Comment.fromJson(data["data"][i]);
          listComments.add(comment);
        }
      }
    },params: {"bugid": bugid.toString(), "uid": uid.toString()}, errorCallBack: errorCallBack);

    if(listComments != null && listComments.length > 0) {
      for (int i = 0; i < listComments.length; i++){
        List<String> actid = await imhelper.selBugAndSuggestCommentState(listComments[i].commentid.toString(),  uid, 0);
        if(actid.length > 0)
          listComments[i].likeuid = uid;
        else{
          listComments[i].likeuid = 0;
        }
      }
    }

    return listComments;
  }

  //获取留言
  Future<List<Comment>> getSuggestCommentList(String actid, int uid, Function errorCallBack) async {
    List<Comment> listComments = [];
    await NetUtil.getInstance().get("/IM/getSuggestComment", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          Comment comment = Comment.fromJson(data["data"][i]);
          listComments.add(comment);
        }
      }
    },params: {"suggestid": actid.toString(), "uid": uid.toString()}, errorCallBack: errorCallBack);

    if(listComments != null && listComments.length > 0) {
      for (int i = 0; i < listComments.length; i++){
        List<String> actid = await imhelper.selBugAndSuggestCommentState(listComments[i].commentid.toString(),  uid, 1);
        if(actid.length > 0)
          listComments[i].likeuid = uid;
        else{
          listComments[i].likeuid = 0;
        }
      }
    }

    return listComments;
  }

  //获取动态留言
  Future<List<Comment>> getMomentCommentList(String momentid, Function errorCallBack) async {
    List<Comment> listComments = [];
    await NetUtil.getInstance().get("/IM/getMomentComment", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          Comment comment = Comment.fromJson(data["data"][i]);
          listComments.add(comment);
        }
      }
    },params: {"momentid": momentid.toString()}, errorCallBack: errorCallBack);
    if(Global.profile.user != null) {
      if (listComments != null && listComments.length > 0) {
        for (int i = 0; i < listComments.length; i++) {
          List<String> actid = await imhelper.selBugAndSuggestCommentState(
              listComments[i].commentid.toString(), Global.profile.user!.uid, 2);
          if (actid.length > 0)
            listComments[i].likeuid = Global.profile.user!.uid;
          else {
            listComments[i].likeuid = 0;
          }
        }
      }
    }

    return listComments;
  }
  //留言点赞
  Future<bool> updateBugCommentLike(int commentid, int uid, String token, int likeuid, String bugid,Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "uid": uid,
      "likeuid": likeuid,
      "bugid": bugid
    });
    await NetUtil.getInstance().post(formData, "/IM/updateBugCommentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      //0是bug 1是suggest
      await imhelper.saveBugAndSuggestCommentState(commentid.toString(), uid, 0);
    }
    return isUpdate;
  }
  //取消点赞
  Future<bool> delBugCommentLike(int commentid, int uid, String token, int likeuid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "likeuid": likeuid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/delBugCommentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.delBugAndSuggestCommentState(commentid.toString(), uid, 0);
    }
    return isUpdate;
  }
  //留言点赞
  Future<bool> updateSuggestCommentLike(int commentid, int uid, String token, int likeuid, String actid,Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "uid": uid,
      "likeuid": likeuid,
      "suggestid": actid
    });
    await NetUtil.getInstance().post(formData, "/IM/updateSuggestCommentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.saveBugAndSuggestCommentState(commentid.toString(), uid, 1);
    }
    return isUpdate;
  }
  //取消点赞
  Future<bool> delSuggestCommentLike(int commentid, int uid, String token, int likeuid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "likeuid": likeuid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/delSuggestCommentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.delBugAndSuggestCommentState(commentid.toString(), uid, 1);
    }
    return isUpdate;
  }
  //留言点赞
  Future<bool> updateMomentCommentLike(int commentid, int uid, String token, int likeuid, String momentid,Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "uid": uid,
      "likeuid": likeuid,
      "momentid": momentid
    });
    await NetUtil.getInstance().post(formData, "/IM/updateMomentCommentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      //0是bug 1是suggest
      await imhelper.saveBugAndSuggestCommentState(commentid.toString(), uid, 2);
    }
    return isUpdate;
  }
  //取消点赞
  Future<bool> delMomentCommentLike(int commentid, int uid, String token, int likeuid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "likeuid": likeuid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/IM/delMomentCommentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.delBugAndSuggestCommentState(commentid.toString(), uid, 2);
    }
    return isUpdate;
  }

  //创建现金红包
  Future<String> createRedPacketOrder(int uid,  String token,  String timeline_id, double amount, int redpackettype,
      int redpacketnum, String content, int timeline_type, Function errorCallBack) async {
    String orderinfo = "";
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "timeline_id": timeline_id,
      "amount": amount,
      "redpacketnum": redpacketnum,
      "redpackettype": redpackettype,
      "timeline_type": timeline_type,
      "content": content
    });

    await NetUtil.getInstance().post(formData, "/user/createRedPacketOrder", (Map<String, dynamic> data) {
      orderinfo = data["data"];
    }, errorCallBack);
    return orderinfo;
  }

  //验证红包是否成功
  Future<String> payredpacketsuccess(int uid,  String token,  String result, String sign, Function errorCallBack) async {
    String redpacketid = "";
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "result": result,
      "sign": sign
    });

    await NetUtil.getInstance().post(formData, "/AliPay/payredpacketsuccess", (Map<String, dynamic> data) {
      redpacketid = data["data"];
    }, errorCallBack);
    return redpacketid;
  }

  //获取红包详情
  Future<RedPacketModel?> getRedPacket(int uid,  String token,  String redpacketid, Function errorCallBack) async {
    RedPacketModel? redPacketModel;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "redpacketid": redpacketid,
    });

    await NetUtil.getInstance().post(formData, "/IM/getUserRedPacketByRedpacketid", (Map<String, dynamic> data) {
      if(data != null){
        redPacketModel = RedPacketModel.fromJson(data["data"]);
      }
    }, errorCallBack);
    return redPacketModel;
  }

  //领取红包
  Future<double> receiveRedPacket(int uid,  String token,  String redpacketid, Function errorCallBack) async {
    double receiveMoney = 0;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "redpacketid": redpacketid,
    });

    await NetUtil.getInstance().post(formData, "/IM/receiveRedPacket", (Map<String, dynamic> data) {
      if(data != null){
        receiveMoney = double.parse(data["data"].toString());

      }
    }, errorCallBack);
    return receiveMoney;
  }

  //获取红包领用情况
  Future<List<RedPacketDetail>> getRedPacketDetail(int uid,  String token,  String redpacketid, Function errorCallBack) async {
    List<RedPacketDetail> redPacketDetails = [];
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "redpacketid": redpacketid,
    });

    await NetUtil.getInstance().post(formData, "/IM/getRedPacketDetailList", (Map<String, dynamic> data) {
      if(data != null){
        for(int i=0; i<data["data"].length; i++){
          redPacketDetails.add(RedPacketDetail.fromJson(data["data"][i]));
        }

      }
    }, errorCallBack);
    return redPacketDetails;
  }

  Future<Community?> createCommunity(String token, int uid, String communityname, String province, String city,  String clubicon,
      String notice,  String joinrule, List<int> members, List<String> membernames, Function errorCallBack) async {

    String temMember = "";
    String temMemberName = "";
    members.forEach((element) {
      temMember += ",${element}";
    });

    membernames.forEach((element) {
      temMemberName += ",${element}";
    });

    if(temMember.isNotEmpty){
      temMember = temMember.substring(1, temMember.length);
    }

    if(temMemberName.isNotEmpty){
      temMemberName = temMemberName.substring(1, temMemberName.length);
    }


    Community? community = null;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "communityname": communityname,
      "province": province,
      "city": city,
      "clubicon": clubicon,
      "notice": notice,
      "joinrule": joinrule,
      "members": temMember,
      "membernames": temMemberName
    });
    await NetUtil.getInstance().post(formData, "/Community/createCommunity", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        community = Community.fromJson(data["data"]);
      }
    }, errorCallBack);
    return community;
  }

  //更新社团图片
  Future<bool> updateCommunityPicture(String token, int uid, String cid,
      String imgpath, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "cid": cid,
      "path": imgpath,
    });
    await NetUtil.getInstance().post(formData, "/Community/updateCommunityPicture", (
        Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //获取社团成员列表
  Future<List<User>> getCommunityMemberList(String cid,
      int currentIndex) async {
    List<User> userList = [];

    FormData formData = FormData.fromMap({
      "cid": cid,
      "currentIndex": currentIndex,
    });

    await NetUtil.getInstance().post(formData, "/Community/getCommunityMember", (
        Map<String, dynamic> data) async {
      if (data != null) {
        if (data["data"] != null) {
          for (int i = 0; i < data["data"].length; i++) {
            userList.add(User.fromJson(data["data"][i]));
          }
        }
      }
    }, () {});

    return userList;
  }

  //删除群成员
  Future<bool> delCommunityMember(String token, int uid, String cid,
      int memberid, Function errorCallBack) async {
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "cid": cid,
      "memberid": memberid,
    });
    await NetUtil.getInstance().post(formData, "/Community/delCommunityMember", (
        Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //删除并退出活动
  Future<bool> delQuitCommunity(String cid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    ShowMessage.showCenterToast("退出中...");

    FormData formData = FormData.fromMap({
      "cid": cid,
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Community/delQuiteCommunity", (Map<String, dynamic> data) {
      ShowMessage.cancel();
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //邀请好友加入群聊
  Future<bool> joinCommunity(String token, int uid, List<int> members, String oldmembers, String timeline_id, List<String>  membernames, Function errorCallBack) async {
    bool ret = false;
    String temMember = "";
    members.forEach((element) {
      temMember += "${element},";
    });
    String temmembernames = "";
    membernames.forEach((element) {
      temmembernames += "${element},";
    });

    temMember = temMember.substring(0, temMember.length -1);
    temmembernames = temmembernames.substring(0, temmembernames.length -1);
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "timeline_id": timeline_id,
      "members": temMember,
      "oldmembers": oldmembers,
      "membernames": temmembernames,
    });
    await NetUtil.getInstance().post(formData, "/Community/joinCommunity", (
        Map<String, dynamic> data) {
      ret = true;
    }, errorCallBack);
    return ret;
  }

  //
  Future<List<SearchResult>> hotsearchMoment() async {
    List<SearchResult> searchResults = [];
    FormData formData = FormData.fromMap({

    });
    await NetUtil.getInstance().post(formData,
        "/IM/hotsearchMoment", (Map<String, dynamic> data) {
      if (data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          SearchResult searchResult = SearchResult.fromJson(data["data"][i]);
          searchResults.add(searchResult);
        }
      }
    }, errorResponse);

    return searchResults;
  }

  //搜索时出现的关键字推荐
  Future<List<SearchResult>> getRecommendSearchMoment(String content,
      Function errorCallBack) async {
    List<SearchResult> searchResults = [];
    FormData formData = FormData.fromMap({
      "content": content,
    });
    await NetUtil.getInstance().post(formData, "/IM/getRecommendSearchMoment", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          SearchResult searchResult = SearchResult.fromJson(data["data"][i]);
          searchResults.add(searchResult);
        }
      }
    }, errorCallBack);

    return searchResults;
  }

  //搜索动态
  Future<List<Moment>> searchMoment(int currentIndex, String content, Function errorCallBack) async {
    List<Moment> moments = [];
    FormData formData = FormData.fromMap({
      "content": content,
      "currentIndex": currentIndex,
    });
    await NetUtil.getInstance().post(formData, "/IM/searchMoment", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          Moment searchResult = Moment.fromJson(data["data"][i]);
          moments.add(searchResult);
        }
      }
    }, errorCallBack);

    return moments;
  }

  errorResponse(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }

}

