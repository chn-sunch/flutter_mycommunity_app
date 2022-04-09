import 'dart:collection';

import 'package:dio/dio.dart';

import '../util/net_util.dart';
import '../util/imhelper_util.dart';
import '../util/showmessage_util.dart';
import '../model/activity.dart';
import '../model/user.dart';
import '../model/comment.dart';
import '../model/commentreply.dart';
import '../model/usernotice.dart';
import '../model/like.dart';
import '../model/follow.dart';
import '../model/usershared.dart';
import '../model/searchresult.dart';
import '../model/im/grouprelation.dart';
import '../model/order.dart';
import '../model/activityevaluate.dart';
import '../model/evaluateactivity.dart';
import '../model/evaluateactivityreply.dart';
import '../model/report.dart';
import '../global.dart';
import 'userservice.dart';

class ActivityService{
  ImHelper imhelper = new ImHelper();

  //创建活动
  Future<Activity?> createActivity(String token, String province, String city,
      int uid, String content, List<String> actimagespath, String coverimg, String coverimgWH, int startyear,
      int endyear, bool ispublic, String address, String addresstitle, double lat, double lng,
      String goodpriceid, String captchaVerification, int paytype,  Function errorCallBack) async {
    String imageUrls = "";
    for (int i = 0; i < actimagespath.length; i++) {
      imageUrls += actimagespath[i] + ",";
    }
    if (imageUrls.length > 0) {
      imageUrls = imageUrls.substring(0, imageUrls.length - 1);
    }

    Activity? activity;

    FormData formData = FormData.fromMap({
      "token": token,
      "province": province,
      "city": city,
      "uid": uid,
      "content": content,
      "actimagespath": imageUrls,
      "coverimg": coverimg,
      "coverimgWH": coverimgWH,
      "startyear": startyear,
      "endyear": endyear,
      "ispublic": ispublic,
      "address": address,
      "addresstitle": addresstitle,
      "lat": lat,
      "lng": lng,
      "paytype": paytype,
      "goodpriceid": goodpriceid,
      "captchaVerification": captchaVerification
    });

    await NetUtil.getInstance().post(formData, "/Activity/createActivity", (
        Map<String, dynamic> data) {
      activity = Activity.fromJson(data["data"]);
    }, errorCallBack);
    return activity;
  }

  //获取活动详情
  Future<Activity?> getActivityInfo(String actid, Function errorCallBack) async {
    Activity? activity;
    int uid = 0;
    if(Global.profile.user != null){
      uid = Global.profile.user!.uid;
    }
    await NetUtil.getInstance().get("/Activity/getActivity",(Map<String, dynamic> data){
      if (data["data"] != null) {
        activity = Activity.fromJson(data["data"]);
      }
    },params: {"actid": actid, "uid": uid.toString() }, errorCallBack: errorCallBack);
    return activity;
  }

  //获取活动详情
  Future<Activity?> getActivityMember(String actid, Function errorCallBack) async {
    Activity? activity;
    int uid = 0;
    if(Global.profile.user != null){
      uid = Global.profile.user!.uid;
    }
    await NetUtil.getInstance().get("/Activity/getActivityMember",(Map<String, dynamic> data){
      if (data["data"] != null) {
        activity = Activity.fromJson(data["data"]);
      }
    },params: {"actid": actid }, errorCallBack: errorCallBack);
    return activity;
  }

  //获取活动详情
  Future<Activity?> getActivityAndPendingOrder(String actid, int uid, String token, Function errorCallBack) async {
    Activity? activity;
    int uid = 0;
    if(Global.profile.user != null){
      uid = Global.profile.user!.uid;
    }
    await NetUtil.getInstance().get("/Activity/getActivityAndPendingOrder",(Map<String, dynamic> data){
      if (data["data"] != null) {
        activity = Activity.fromJson(data["data"]);
      }
    },params: {"actid": actid, "uid": uid.toString(), "token": token }, errorCallBack: errorCallBack);
    return activity;
  }

  //已修改成未登录用户根据热度进行排序
  Future<List<Activity>> getActivityListByUpdateTime(int currentIndex) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getActivityListByUpdateTime", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(), "citycode": Global.profile.locationCode}, errorCallBack: errorResponse);
    return activityList;
  }
  //获取用户活动
  Future<List<Activity>> getActivityListByUser(int currentIndex, int uid) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getActivityListByUser", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString()}, errorCallBack: errorResponse);
    return activityList;
  }

  Future<List<Activity>> getActivityListByUserCount5(int currentIndex, int uid, String token) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getActivityListByUserCount5", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return activityList;
  }
  //查询所有我的活动
  Future<List<Activity>> getAllActivityListByUserCount5(int currentIndex, int uid, String token) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getAllActivityListByUserCount5", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return activityList;
  }

  Future<List<Activity>> getActivityFinishListByUserCount5(int currentIndex, int uid, String token) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getActivityFinishListByUserCount5", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return activityList;}

  //获取用户加入的活动
  Future<List<Activity>> getJoinActivityListByUser(int currentIndex, int uid, String token) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getJoinActivityListByUser", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return activityList;
  }

  //获取用户加入的活动数量5
  Future<List<Activity>> getJoinActivityListByUserCount5(int currentIndex, int uid, String token) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getJoinActivityListByUserCount5", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return activityList;
  }

  Future<List<Activity>> getJoinActivityFinishListByUserCount5(int currentIndex, int uid, String token) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getJoinActivityFinishListByUserCount5", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return activityList;
  }

  Future<List<Activity>> getALLJoinActivityListByUserCount5(int currentIndex, int uid, String token) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getALLJoinActivityListByUserCount5", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return activityList;
  }

  //获取用户收藏的活动
  Future<List<Activity>> getCollectionActivityListByUser(int currentIndex, int uid, String token) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getCollectionActivityListByUser", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return activityList;
  }

  //获取用户收藏的活动数量5
  Future<List<Activity>> getCollectionActivityListByUserCount5(int currentIndex, int uid, String token) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getCollectionActivityListByUserCount5", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"uid": uid.toString(), "token": token}, errorCallBack: errorResponse);
    return activityList;
  }

  Future<List<Activity>> getActivityListByCity(int currentIndex, String citycode) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/getActivityListByCity", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"currentIndex": currentIndex.toString(),"citycode": citycode.toString()}, errorCallBack: errorResponse);
    return activityList;
  }

  Future<List<Activity>> getActivityListByFollow(int currentIndex, List<User> users) async {
    List<Activity> activityList = [];
    String ids = "";
    for(int i=0; i<users.length; i++)
    {
      ids += users[i].uid.toString() + ",";
    }
    ids = ids.substring(0, ids.length-1);
    FormData formData = FormData.fromMap({
      "currentIndex": currentIndex,
      "ids": ids,
    });

    await NetUtil.getInstance().post(formData, "/Activity/getActivityFollowList", (Map<String, dynamic> data) async {
      if(data != null){
        if(data["data"] != null){
          for(int i=0; i<data["data"].length; i++){
            activityList.add(Activity.fromJson(data["data"][i]));
          }
        }
      }
    }, (){});

    return activityList;
  }

  Future<List<Activity>> getActivityListByCid(String cid) async {
    List<Activity> activityList = [];
    await NetUtil.getInstance().get("/Activity/selectActivityByCid", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          activityList.add(Activity.fromJson(data["data"][i]));
        }
      }
    },params: {"cid": cid.toString()}, errorCallBack: errorResponse);
    return activityList;
  }

  Future<Map> getLikeCollectionState(String actid, int uid) async{
    Map<String, bool> ret = HashMap();
//    await NetUtil.getInstance().get("/Activity/getLikeCollectionState", (Map<String, dynamic> data){
//      if (data["data"] != null) {
//        ret["islike"] = data["data"]["islike"];
//        ret["iscollection"] = data["data"]["iscollection"];
//      }
//    },params: {"actid": actid.toString(), "uid": uid.toString()}, errorCallBack: errorResponse);
    await imhelper.selActivityState(actid, uid, (List<String> actid){
      if(actid.length > 0)
        ret["islike"] = true;
      else{
        ret["islike"] = false;
      }
    });

    await imhelper.selActivityCollectionState(actid, uid, (List<String> actid){
      if(actid.length > 0)
        ret["iscollection"] = true;
      else{
        ret["iscollection"] = false;
      }
    });
    return ret;
  }

  errorResponse(String statusCode, String msg) {
    ShowMessage.showToast(msg);
  }

  Future<void> getUserLike(int uid, String token) async {
    int count = await imhelper.selActivityStateCount(uid);
    if(count <= 0) {
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(
          formData, "/Activity/getUserLike", (Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String actid = (data["data"][i]);
              await imhelper.delActivityState(actid, uid);
              await imhelper.saveActivityState(actid, uid);
            }
          }
        }
      }, () {});
    }
  }

  Future<void> getUserLikeBug(int uid, String token) async {
    int count = await imhelper.selBugSuggestStateCount(uid, 0);
    if(count <= 0) {
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(
          formData, "/Activity/getUserLikeBug", (Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String actid = (data["data"][i]);
              await imhelper.delBugSuggestState(actid, uid, 0);
              await imhelper.saveBugSuggestState(actid, uid, 0);
            }
          }
        }
      }, () {});
    }
  }

  Future<void> getUserLikeSuggest(int uid, String token) async {
    int count = await imhelper.selBugSuggestStateCount(uid, 1);
    if(count <= 0) {
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(
          formData, "/Activity/getUserLikeSuggest", (Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String actid = (data["data"][i]);
              await imhelper.delBugSuggestState(actid, uid, 1);
              await imhelper.saveBugSuggestState(actid, uid, 1);
            }
          }
        }
      }, () {});
    }
  }

  Future<void> getUserLikeMoment(int uid, String token) async {
    int count = await imhelper.selBugSuggestStateCount(uid, 2);//评价
    if(count <= 0) {
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(
          formData, "/Activity/getUserLikeMoment", (Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String actid = (data["data"][i]);
              await imhelper.delBugSuggestState(actid, uid, 2);
              await imhelper.saveBugSuggestState(actid, uid, 2);
            }
          }
        }
      }, () {});
    }
  }


  Future<void> getUserCollection(int uid, String token) async {
    int count = await imhelper.selActivityCollectionCount(uid);
    if(count <= 0) {
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(formData, "/Activity/getUserCollection", (
          Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              Activity activity = (Activity.fromMapCollection(data["data"][i]));
              await imhelper.delActivityCollectionState(activity.actid, uid);
              await imhelper.saveActivityCollectionState(activity, uid);
            }
          }
        }
      }, () {});
    }
  }

  Future<void> getUserComnnentLike(int uid, String token, int likecomment, int likeevaluate) async {
    int commentcount = await imhelper.selActivityCommentCountState(uid);
    int evaluatecount = await imhelper.selActivityEvaluateCountState(uid);

    if(commentcount <= 0 && likecomment > 0) {
      FormData formData = new FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(formData, "/Activity/getUserComnnentLike", (
          Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String actid = (data["data"][i]);
              await imhelper.delActivityCommentState(actid, uid);
              await imhelper.saveActivityCommentState(actid, uid);
            }
          }
        }
      }, () {});
    }

    if(evaluatecount <= 0 && likeevaluate > 0) {
      FormData formData1 = new FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(formData1, "/Activity/getUserEvaluateLike", (
          Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String evaluateid = (data["data"][i]);
              await imhelper.delActivityEvaluateState(evaluateid, uid);
              await imhelper.saveActivityEvaluateState(evaluateid, uid);
            }
          }
        }
      }, () {});
    }

  }

  Future<void> getUserGoodPriceComnnentLike(int uid, String token, int likecomment) async {
    int commentcount = await imhelper.selGoodPriceCommentCountState(uid);

    if(commentcount <= 0 && likecomment > 0) {
      FormData formData = new FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(formData, "/grouppurchase/getUserGoodPriceComnnentLike", (
          Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String commentid = (data["data"][i]);
              await imhelper.delGoodPriceCommentState(commentid, uid);
              await imhelper.saveGoodPriceCommentState(commentid, uid);
            }
          }
        }
      }, () {});
    }
  }

  Future<void> getUserBugAndSuggestAndMomentComnnentLike(int uid, String token,
      int bugcommentlike, int suggestcommentlike, int momentcommentlike) async {
    int bugcommentcount = await imhelper.selBugAndSuggestCommentCountState(uid, 0);
    int suggestcommentcount = await imhelper.selBugAndSuggestCommentCountState(uid, 1);
    int momentcommentcount = await imhelper.selBugAndSuggestCommentCountState(uid, 2);

    if(bugcommentcount <= 0 && bugcommentlike > 0) {
      FormData formData = new FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(formData, "/Activity/getUserBugComnnentLike", (
          Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String actid = (data["data"][i]);
              await imhelper.delBugAndSuggestCommentState(actid, uid, 0);
              await imhelper.saveBugAndSuggestCommentState(actid, uid, 0);
            }
          }
        }
      }, () {});
    }

    if(suggestcommentcount <= 0 && suggestcommentlike > 0) {
      FormData formData1 = new FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(formData1, "/Activity/getUserSuggestComnnentLike", (
          Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String evaluateid = (data["data"][i]);
              await imhelper.delBugAndSuggestCommentState(evaluateid, uid, 1);
              await imhelper.saveBugAndSuggestCommentState(evaluateid, uid, 1);
            }
          }
        }
      }, () {});
    }

    if(momentcommentcount <=0 && momentcommentlike > 0){
      FormData formData1 = new FormData.fromMap({
        "token": token,
        "uid": uid,
      });
      await NetUtil.getInstance().post(formData1, "/Activity/getUserMomentCommentLike", (
          Map<String, dynamic> data) async {
        if (data != null) {
          if (data["data"] != null) {
            for (int i = 0; i < data["data"].length; i++) {
              String evaluateid = (data["data"][i]);
              await imhelper.delBugAndSuggestCommentState(evaluateid, uid, 2);
              await imhelper.saveBugAndSuggestCommentState(evaluateid, uid, 2);
            }
          }
        }
      }, () {});
    }
  }

  //点赞
  Future<bool> updateLike(String actid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/updateLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate){
      await imhelper.saveActivityState(actid,  uid);
    }

    return isUpdate;
  }
  //取消点赞
  Future<bool> delLike(String actid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/delLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.delActivityState(actid, uid);
    }
    return isUpdate;
  }
  //收藏
  Future<bool> updateCollection(Activity activity, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": activity.actid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/updateCollection", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);

    await imhelper.saveActivityCollectionState(activity, uid);
    return isUpdate;
  }
  //取消收藏
  Future<bool> delCollection(String actid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/delCollection", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    await imhelper.delActivityCollectionState(actid, uid);
    return isUpdate;
  }
  //留言
  Future<int> updateMessage(String actid, int uid, String token, int touid,  String content, String captchaVerification, Function errorCallBack) async{
    int commentid = 0;

    FormData formData = FormData.fromMap({
      "commentid": commentid,
      "token": token,
      "actid": actid,
      "uid": uid,
      "touid": touid,
      "content": content,
      "captchaVerification": captchaVerification
    });
    await NetUtil.getInstance().post(formData, "/Activity/updatecomment", (Map<String, dynamic> data) {
      commentid = int.parse(data["data"].toString());
    }, errorCallBack);
    return commentid;
  }
  //留言回复
  Future<int> updateCommentReply(int commentid, String actid, int uid, String token, int touid,  String content,String captchaVerification, Function errorCallBack) async{
    int isret = 0;

    FormData formData = FormData.fromMap({
      "commentid": commentid,
      "token": token,
      "actid": actid,
      "uid": uid,
      "touid": touid,
      "content": content,
      "captchaVerification": captchaVerification
    });
    await NetUtil.getInstance().post(formData, "/Activity/updatecomment", (Map<String, dynamic> data) {
      isret = int.parse(data["data"].toString());
      }, errorCallBack);
    return isret;
  }
  //取消留言
  Future<bool> delMessage(String token, int uid, int commentid, String actid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "uid": uid,
      "replyid": 0,
      "actid": actid
    });
    await NetUtil.getInstance().post(formData, "/Activity/delcomment", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }
  //取消留言里的回复
  Future<bool> delMessageReply(String token, int uid, int replyid, String actid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": 0,
      "uid": uid,
      "replyid": replyid,
      "actid": actid
    });
    await NetUtil.getInstance().post(formData, "/Activity/delcomment", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }
  //获取留言
  Future<List<Comment>> getCommentList(String actid, int uid, Function errorCallBack) async {
    List<Comment> listComments = [];
    await NetUtil.getInstance().get("/Activity/getcomment", (Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          Comment comment = Comment.fromJson(data["data"][i]);
          listComments.add(comment);
        }
      }
    },params: {"actid": actid.toString(), "uid": uid.toString()}, errorCallBack: errorCallBack);

    if(listComments != null && listComments.length > 0) {
      for (int i = 0; i < listComments.length; i++){
        List<String> actid = await imhelper.selActivityCommentState(listComments[i].commentid.toString(),  uid);
        if(actid.length > 0)
          listComments[i].likeuid = uid;
        else{
          listComments[i].likeuid = 0;
        }
      }
    }

    return listComments;
  }
  //点赞
  Future<bool> updateCommentLike(int commentid, int uid, String token, int likeuid, String actid,Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "uid": uid,
      "likeuid": likeuid,
      "actid": actid
    });
    await NetUtil.getInstance().post(formData, "/Activity/updateCommentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.saveActivityCommentState(commentid.toString(), uid);
    }
    return isUpdate;
  }
  //取消点赞
  Future<bool> delCommentLike(int commentid, int uid, String token, int likeuid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "commentid": commentid,
      "likeuid": likeuid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/delCommentLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.delActivityCommentState(commentid.toString(), uid);
    }
    return isUpdate;
  }
  //点赞
  Future<bool> updateEvaluateLike(int evaluateid, int uid, String token, int likeuid, String actid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "evaluateid": evaluateid,
      "uid": uid,
      "likeuid": likeuid,
      "actid": actid
    });
    await NetUtil.getInstance().post(formData, "/Activity/updateEvaluateLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.saveActivityEvaluateState(evaluateid.toString(), uid);
    }
    return isUpdate;
  }
  //取消点赞
  Future<bool> delEvaluateLike(int evaluateid, int uid, String token, int likeuid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "evaluateid": evaluateid,
      "likeuid": likeuid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/delEvaluateLike", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    if(isUpdate) {
      await imhelper.delActivityEvaluateState(evaluateid.toString(), uid);
    }
    return isUpdate;
  }
  //删除活动
  Future<bool> delActivity(String actid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/delActivity", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }
  //刷新活动时间
  Future<bool> updateActivityTime(String actid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/updateActivityTime", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //编辑活动
  Future<bool> updateActivity(String actid, int uid, String token, String content, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
      "content": content
    });
    await NetUtil.getInstance().post(formData, "/Activity/updateActivity", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }
  //更新活动状态
  Future<bool> updateActivityStatus(String actid, int uid, String token, int status, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
      "status": status
    });
    await NetUtil.getInstance().post(formData, "/Activity/updateActivityStatus", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //更新活动状态
  Future<bool> updateActivityStatusEnd(String actid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/updateActivityStatusEnd", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //参加活动
  Future<GroupRelation?> joinActivity(String actid, int uid, String token, String username, String sex, Function errorCallBack) async{
    GroupRelation? groupRelation;
    FormData formData = FormData.fromMap({
      "token": token,
      "actid": actid,
      "uid": uid,
      "username": username,
    });
    await NetUtil.getInstance().post(formData, "/Activity/joinActivity", (Map<String, dynamic> data) {
      if(data['data'] != null) {
        groupRelation = GroupRelation.fromJson(data['data']);
      }
    }, errorCallBack);
    return groupRelation;
  }
  //退出活动
  Future<int> exitActivity(String actid, int uid, String token, Function errorCallBack) async{
    return 1;
  }
  //是否已经参加活动
  Future<GroupRelation?> getGroupConversation(String actid, int uid, String token, Function errorCallBack) async{
    GroupRelation? groupRelation;
    FormData formData = FormData.fromMap({
      "token": token,
      "timeline_id": actid,
      "uid": uid
    });
    await NetUtil.getInstance().post(formData, "/Activity/getGroupConversation", (Map<String, dynamic> data) {
      if(data['data'] != null)
        groupRelation = GroupRelation.fromJson(data['data']);
    }, errorCallBack);
    return groupRelation;
  }


  //获取指定回复
  Future<CommentReply?> getReply(int replyid, Function errorCallBack) async {
    CommentReply? commentReply;
    await NetUtil.getInstance().get("/Activity/getReply", (Map<String, dynamic> data){
      if (data["data"] != null) {
        commentReply = CommentReply.fromJson(data["data"]);
      }
    },params: {"replyid": replyid.toString()}, errorCallBack: errorCallBack);
    return commentReply;
  }
  //获取未读回复
  Future<List<CommentReply>> getReplyList(  Function errorCallBack) async {
    List<CommentReply> commentReplys = [];
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    int replyid = await imhelper.getMaxReplyid(ReplyMsgType.replymsg);
    if(replyid == null){
      replyid = -1;
    }
    FormData formData = FormData.fromMap({
      "uid": Global.profile.user!.uid,
      "replyid": replyid,
    });

    await NetUtil.getInstance().post(formData, "/Activity/getCommentReplyList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);

    return commentReplys;
  }
  //获取未读评论
  Future<List<CommentReply>> getNewCommentList(  Function errorCallBack) async {
    List<CommentReply> commentReplys = [];
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    int commentid = await imhelper.getMaxReplyid(ReplyMsgType.commentmsg) ;
    if(commentid == null){
      commentid = -1;
    }
    FormData formData = FormData.fromMap({
      "uid": Global.profile.user!.uid,
      "commentid": commentid,
    });

    await NetUtil.getInstance().post(formData, "/Activity/getNewCommentList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);

    return commentReplys;
  }

  Future<List<CommentReply>> getSysNotice(  Function errorCallBack) async {
    List<CommentReply> commentReplys = [];
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    int replyid = await imhelper.getMaxReplyid(ReplyMsgType.sysnotice) ;
    if(replyid == null){
      replyid = -1;
    }
    FormData formData = FormData.fromMap({
      "uid": Global.profile.user!.uid,
      "replyid": replyid,
    });

    await NetUtil.getInstance().post(formData, "/Activity/getSysNotice", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);

    return commentReplys;
  }

  //同步消息通知，评论，回复，系统通知，活动评价
  Future<UserNotice?> syncUserNotice(int uid, String token, Function errorCallBack) async {
    UserNotice? userNotice = null;

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/syncUserNotice", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        userNotice = UserNotice.fromJson(
            data["data"]);
      }
    }, errorCallBack);
    return userNotice;
  }
  //下载未读数据到本地存储
  Future<void> saveLocalStore(
      UserNotice userNotice, String token, int uid,
      Function errorCallBack) async {
    ///同步数据分为
    ///1，必须和服务器保持同步，重装后从服务器下载全部历史数据
    ///2, 不用和服务器保持同步，只同步最新数据，未读数量被重置为0后就不下载历史数据
    if (Global.isInDebugMode) {
      print("unread_comment:${userNotice.unread_comment},readindex:${userNotice.read_commentindex},"
          "unread_reply:${userNotice.unread_reply}, readindex:${userNotice.read_replyindex},"
          "unread_sysnotice:${userNotice.unread_sysnotice},readindex:${userNotice.read_sysnoticeindex}, "
          "unread_evaluate:${userNotice.unread_evaluate},readindex:${userNotice.read_evaluate}");
    }

    //留言消息同步
    if (userNotice.unread_comment > 0) {
      await syncCommentFun(userNotice, uid, token, errorCallBack);
    }
    if(userNotice.unread_reply > 0){
      await syncReplyFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_bugcomment > 0) {
      await syncBugCommentFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_bugreply > 0){
      await syncBugReplyFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_suggestcomment > 0) {
      await syncSuggestCommentFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_suggestreply > 0){
      await syncSuggestReplyFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_momentcomment > 0) {
      await syncMomentCommentFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_momentreply > 0){
      await syncMomentReplyFun(userNotice, uid, token, errorCallBack);
    }


    if(userNotice.unread_goodpricecomment > 0){
      await syncGoodPriceCommentFun(userNotice, uid, token, errorCallBack);
    }
    if(userNotice.unread_goodpricereply > 0){
      await syncGoodPriceReplyFun(userNotice, uid, token, errorCallBack);
    }
    //活动点赞同步
    if (userNotice.unread_actlike > 0) {
      await syncActivityLikeFun(userNotice, uid, token, errorCallBack);
    }
    //bug点赞同步
    if (userNotice.unread_buglike > 0) {
      await syncBugLikeFun(userNotice, uid, token, errorCallBack);
    }
    //建议点赞同步
    if (userNotice.unread_suggestlike > 0) {
      await syncSuggestLikeFun(userNotice, uid, token, errorCallBack);
    }
    //动态点赞同步
    if (userNotice.unread_momentlike > 0) {
      await syncMomentLikeFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_commentlike > 0) {
      await syncActivityCommentLikeFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_goodpricecommentlike > 0) {
      await syncGoodPriceCommentLikeFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_bugcommentlike > 0) {
      await syncBugCommentLikeFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_suggestcommentlike > 0) {
      await syncSuggestCommentLikeFun(userNotice, uid, token, errorCallBack);
    }
    if (userNotice.unread_momentcommentlike > 0) {
      await syncMomentCommentLikeFun(userNotice, uid, token, errorCallBack);
    }


    if (userNotice.unread_evaluatelike > 0) {
      await syncActivityEvaluateLikeFun(userNotice, uid, token, errorCallBack);
    }
    //系统通知消息同步
    if(userNotice.unread_sysnotice > 0){
      await syncSysNoticeFun(userNotice, uid, token, errorCallBack);
    }

    //有新的用户关注
    if(userNotice.unread_follow > 0){
      await syncFollowFun(userNotice, uid, token, errorCallBack);
    }

    //有新的未评论活动，需要和本地的对比，如果未评论数大于本地数再从服务器下载
    //分享和未评价活动都是读取本地数据库，需要保持同步，具体参考未评价活动
    if(userNotice.unevaluate_activity >= 0){
      await syncOrderUnEvaluateUpdateFun(uid, userNotice.unevaluate_activity, errorCallBack);
    }

    //活动评价消息同步
    if(userNotice.unread_evaluate > 0){
      await syncEvaluateFun(userNotice, uid, token, errorCallBack);
    }

    //活动评价回复同步
    if(userNotice.unread_evaluatereply > 0){
      await syncEvaluateReplyFun(userNotice, uid, token, errorCallBack);
    }

    //来自朋友的分享
    if(userNotice.unread_shared > 0){
      await syncSharedFun(userNotice, uid, token, errorCallBack);
    }

    //订单状态有改变,把各种状态的订单数量存入本地数据库，不用设置已读和上面几种不一样，这里只记录数量
    if(userNotice.unread_orderpending >= 0){
      //0是待付款 1是完成付款待确认
      await syncOrderUpdateFun( uid, 0, userNotice.unread_orderpending, token, errorCallBack);
    }

    if(userNotice.unread_orderfinish >= 0){
      await syncOrderUpdateFun( uid, 1, userNotice.unread_orderfinish, token, errorCallBack);
    }
  }

  Future<void> syncCommentFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    //读取消息是否成功  issuccess
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    List<CommentReply> commentReplys = [];
    int sequence_id = userNotice.read_commentindex;
    if(Global.isInDebugMode){
      print("load activity Comment... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.commentmsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_commentindex)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "commentid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getNewCommentList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      await imhelper.saveReplys(commentReplys, ReplyMsgType.commentmsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.commentmsg, uid, token, errorCallBack);
    }
  }

  Future<void> syncBugCommentFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    //bug评论同步
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    List<CommentReply> commentReplys = [];
    int sequence_id = userNotice.read_bugcomment;
    if(Global.isInDebugMode){
      print("load activity Comment... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.bugcommentmsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_bugcomment)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "commentid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/IM/getNewBugCommentList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      await imhelper.saveReplys(commentReplys, ReplyMsgType.bugcommentmsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.bugcommentmsg, uid, token, errorCallBack);
    }
  }
  //建议评论同步
  Future<void> syncSuggestCommentFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    //bug评论同步
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    List<CommentReply> commentReplys = [];
    int sequence_id = userNotice.read_suggestcomment;
    if(Global.isInDebugMode){
      print("load activity Comment... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.suggestcommentmsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_suggestcomment)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "commentid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/IM/getNewSuggestCommentList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      await imhelper.saveReplys(commentReplys, ReplyMsgType.suggestcommentmsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.suggestcommentmsg, uid, token, errorCallBack);
    }
  }
  //动态评论同步
  Future<void> syncMomentCommentFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    //moment评论同步
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    List<CommentReply> commentReplys = [];
    int sequence_id = userNotice.read_momentcomment;
    if(Global.isInDebugMode){
      print("load moment Comment... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.momentcommentmsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_momentcomment)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "commentid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/IM/getNewMomentCommentList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      await imhelper.saveReplys(commentReplys, ReplyMsgType.momentcommentmsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.momentcommentmsg, uid, token, errorCallBack);
    }
  }

  //优惠评论同步
  Future<void> syncGoodPriceCommentFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    //读取消息是否成功  issuccess
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    List<CommentReply> commentReplys = [];
    int sequence_id = userNotice.read_goodpricecommentindex;
    if(Global.isInDebugMode){
      print("load activity Comment... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.goodpricecommentmsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_goodpricecommentindex)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "commentid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/grouppurchase/getNewCommentList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      await imhelper.saveReplys(commentReplys, ReplyMsgType.goodpricecommentmsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.goodpricecommentmsg, uid, token, errorCallBack);
    }
  }

  Future<void> syncActivityLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据

    int sequence_id = userNotice.read_actlike;
    if(Global.isInDebugMode){
      print("load activity like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(0);//0是活动的点赞
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_actlike)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getActivityLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      int count = await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(0, uid, token, errorCallBack);
    }
  }

  Future<void> syncBugLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据

    int sequence_id = userNotice.read_buglike;
    if(Global.isInDebugMode){
      print("load bug like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(3);//3bug
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_buglike)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getBugLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      int count = await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(3, uid, token, errorCallBack);
    }
  }

  Future<void> syncSuggestLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据

    int sequence_id = userNotice.read_suggestlike;
    if(Global.isInDebugMode){
      print("load bug like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(4);//0是活动的点赞
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_suggestlike)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getSuggestLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      int count = await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(4, uid, token, errorCallBack);
    }
  }

  Future<void> syncMomentLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据

    int sequence_id = userNotice.read_momentlike;
    if(Global.isInDebugMode){
      print("load moment like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(8);//0是活动的点赞
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_momentlike)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getMomentLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(8, uid, token, errorCallBack);
    }
  }

  Future<void> syncActivityCommentLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_commentlike;
    if(Global.isInDebugMode){
      print("load activity like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(1);//0是活动的点赞
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_commentlike)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getActivityCommentLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(1, uid, token, errorCallBack);
    }
  }

  Future<void> syncGoodPriceCommentLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_goodpricecommentlike;
    if(Global.isInDebugMode){
      print("load activity like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(7);//7是goodprice点赞
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_goodpricecommentlike)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/grouppurchase/getGoodPriceCommentLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(7, uid, token, errorCallBack);
    }
  }

  Future<void> syncActivityEvaluateLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_evaluatelike;
    if(Global.isInDebugMode){
      print("load activity like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(2);//0是活动的点赞
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_evaluate)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getEvaluateLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(2, uid, token, errorCallBack);
    }
  }

  Future<void> syncBugCommentLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_bugcommentlike;
    if(Global.isInDebugMode){
      print("load activity like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(5);//5是bugcomment点赞
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_bugcommentlike)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getBugCommentLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(5, uid, token, errorCallBack);
    }
  }

  Future<void> syncSuggestCommentLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_suggestcommentlike;
    if(Global.isInDebugMode){
      print("load activity like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(6);//5是bugcomment点赞
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_suggestcommentlike)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getSuggestCommentLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(6, uid, token, errorCallBack);
    }
  }

  Future<void> syncMomentCommentLikeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Like> likes = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_momentcommentlike;
    if(Global.isInDebugMode){
      print("load momentcomment like... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxLikeID(9);//5是momentcomment点赞
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_momentcommentlike)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "likeid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getMomentCommentLikeList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          likes.add(Like.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(likes != null && likes.isNotEmpty){
      await imhelper.saveActivityLike(likes);
    }
    if(issuccess){
      await postReadLike(9, uid, token, errorCallBack);
    }
  }

  Future<void> syncFollowFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<Follow> follows = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_follow;
    if(Global.isInDebugMode){
      print("load myFollow... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxFollowid();
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_follow)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "id": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/user/follwerInfo", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          follows.add(Follow.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(follows != null && follows.isNotEmpty){
      int count = await imhelper.saveFollow(follows);
      if(count > 0){
        UserService userService = UserService();
        await userService.getUserInfo(uid, errorCallBack);
      }
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.newfollowed, uid, token, errorCallBack);
    }
  }

  Future<void> syncReplyFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<CommentReply> commentReplys = [];//留言，评价，回复共同使用一个类型
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_replyindex;
    if(Global.isInDebugMode){
      print("load CommentReply... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.replymsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_replyindex)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "replyid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getCommentReplyList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      int count = await imhelper.saveReplys(commentReplys, ReplyMsgType.replymsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.replymsg, uid, token, errorCallBack);
    }
  }

  Future<void> syncGoodPriceReplyFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<CommentReply> commentReplys = [];//留言，评价，回复共同使用一个类型
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_goodpricereplyindex;
    if(Global.isInDebugMode){
      print("load CommentReply... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.goodpricereplymsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_goodpricereplyindex)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "replyid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/grouppurchase/getCommentReplyList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      int count = await imhelper.saveReplys(commentReplys, ReplyMsgType.goodpricereplymsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.goodpricereplymsg, uid, token, errorCallBack);
    }
  }

  Future<void> syncBugReplyFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<CommentReply> commentReplys = [];//留言，评价，回复共同使用一个类型
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_bugreply;
    if(Global.isInDebugMode){
      print("load CommentReply... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.bugreplymsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_bugreply)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "replyid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/IM/getNewBugReplyList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      int count = await imhelper.saveReplys(commentReplys, ReplyMsgType.bugreplymsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.bugreplymsg, uid, token, errorCallBack);
    }
  }

  Future<void> syncSuggestReplyFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<CommentReply> commentReplys = [];//留言，评价，回复共同使用一个类型
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_suggestreply;
    if(Global.isInDebugMode){
      print("load CommentReply... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.suggestreplymsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_suggestreply)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "replyid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/IM/getNewSuggestReplyList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      int count = await imhelper.saveReplys(commentReplys, ReplyMsgType.suggestreplymsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.suggestreplymsg, uid, token, errorCallBack);
    }
  }

  Future<void> syncMomentReplyFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<CommentReply> commentReplys = [];//留言，评价，回复共同使用一个类型
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.unread_momentreply;
    if(Global.isInDebugMode){
      print("load CommentReply... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.momentreplymsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.unread_momentreply)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "replyid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/IM/getNewMomentReplyList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      await imhelper.saveReplys(commentReplys, ReplyMsgType.momentreplymsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.momentreplymsg, uid, token, errorCallBack);
    }
  }

  Future<void> syncSysNoticeFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<CommentReply> commentReplys = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_sysnoticeindex;
    if(Global.isInDebugMode){
      print("load sysnotice...");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.sysnotice);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_sysnoticeindex)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "replyid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getSysNotice", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      int count = await imhelper.saveReplys(commentReplys, ReplyMsgType.sysnotice);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.sysnotice, uid, token, errorCallBack);
    }
  }

  Future<void> syncSharedFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<UserShared> userShareds = [];
    int sequence_id = userNotice.read_shared;
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    if(Global.isInDebugMode){
      print("load shared...");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var id = await imhelper.getMaxUserSharedId();
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (id != null && id > userNotice.read_shared)
      sequence_id = id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "readindex": sequence_id, //服务器已读的
    });

    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/user/getUserShared", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          userShareds.add(UserShared.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(userShareds != null && userShareds.isNotEmpty){
      await imhelper.saveUserSharedJoin(userShareds);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.sharedReaded, uid, token, errorCallBack);
    }
  }
  //获取未评价的订单
  Future<List<Order>> getUnEvaluateOrderList(int uid, String token,  Function errorCallBack) async {
    List<Order> unevaluateorderlist = [];
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
    });

    ///获取未评论活动
    await NetUtil.getInstance().post(formData, "/Activity/getUnEvaluateOrderList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        for(int i=0; i<data["data"].length; i++){
          unevaluateorderlist.add(Order.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);

    return unevaluateorderlist;
  }

  Future<void> syncUnActivityEvaluateFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<EvaluateActivityReply> evaluateActivityReplys = [];
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int unnum = userNotice.unevaluate_activity;

    ///判断服务器未评论活动是否大于本地
    List<ActivityEvaluate>? activitys = await imhelper.getUnEvaluateActivity(
        0, 10000, 0);
    ///确保本地数据是最新的
    if ((activitys != null && userNotice.unevaluate_activity > 0) ||
        ((activitys == null || activitys.length == 0) && userNotice.evaluate_activity > 0)  ||
        ((activitys == null || activitys.length == 0) && userNotice.unevaluate_activity > 0) ) {
      if(Global.isInDebugMode){
        print("load activityEvaluates....");
      }
      List<ActivityEvaluate> activityEvaluates = [];
      FormData formData = FormData.fromMap({
        "uid": uid,
        "token": token,
        "readindex": 0
      });

      ///获取未评论活动
      await NetUtil.getInstance().post(formData, "/Activity/getUnActvityEvaluateList", (
          Map<String, dynamic> data){
        if (data["data"] != null) {
          issuccess = true;
          for(int i=0; i<data["data"].length; i++){
            activityEvaluates.add(ActivityEvaluate.fromJson(data["data"][i]));
          }
        }
      }, errorCallBack);
      if(activityEvaluates != null && activityEvaluates.length > 0){
        int count = await imhelper.saveUnEvaluateActivity(activityEvaluates, Global.profile.user!.uid);
      }
      if(issuccess){
        await postReadMessage(ReplyMsgType.evaluateactivity, uid, token, errorCallBack);
      }
    }
  }

  Future<void> syncUnActivityEvaluateFunReadIndex(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<EvaluateActivityReply> evaluateActivityReplys = [];
    int sequence_id = userNotice.evaluate_activity;
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    if(Global.isInDebugMode){
      print("load shared...");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var id = await imhelper.getMaxUnEvaluateActivityid();
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (id != null && id > userNotice.evaluate_activity)
      sequence_id = id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "readindex": sequence_id, //服务器已读的
    });
    ///判断服务器未评论活动是否大于本地
    List<ActivityEvaluate> activityEvaluates = [];


    ///获取为评论活动
    await NetUtil.getInstance().post(formData, "/Activity/getUnActvityEvaluateList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          activityEvaluates.add(ActivityEvaluate.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(activityEvaluates != null && activityEvaluates.length > 0){
      int count = await imhelper.saveUnEvaluateActivity(activityEvaluates, Global.profile.user!.uid);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.evaluateactivity, uid, token, errorCallBack);
    }
  }


  Future<void> syncEvaluateFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<CommentReply> commentReplys = [];//留言，评价，回复共同使用一个类型
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_evaluate;
    if(Global.isInDebugMode){
      print("load activity Comment... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.evaluatemsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_evaluate)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "evaluateid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getNewEvaluateList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      int count = await imhelper.saveReplys(commentReplys, ReplyMsgType.evaluatemsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.evaluatemsg, uid, token, errorCallBack);
    }
  }

  Future<void> syncEvaluateReplyFun(UserNotice userNotice, uid, token, Function errorCallBack) async {
    List<CommentReply> commentReplys = [];//留言，评价，回复共同使用一个类型
    bool issuccess = false;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
    int sequence_id = userNotice.read_evaluatereply;
    if(Global.isInDebugMode){
      print("load read_evaluatereply reply... ");
    }
    ///服务器获取的已读数据和本地缓存的对比，使用最新的
    var temsequence_id = await imhelper.getMaxReplyid(
        ReplyMsgType.evaluatereplymsg);
    ///如果本地已储存的数据大于服务器则使用本地最新数据id
    if (temsequence_id != null && temsequence_id > userNotice.read_evaluatereply)
      sequence_id = temsequence_id;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "replyid": sequence_id, //服务器已读的
    });
    ///通过自增的已读ID获取未读消息
    await NetUtil.getInstance().post(formData, "/Activity/getNewEvaluateReplyList", (
        Map<String, dynamic> data){
      if (data["data"] != null) {
        issuccess = true;//正常从服务器返回就标记为已读,避免数据删除后一直从服务器拉取数据
        for(int i=0; i<data["data"].length; i++){
          commentReplys.add(CommentReply.fromJson(data["data"][i]));
        }
      }
    }, errorCallBack);
    if(commentReplys != null && commentReplys.isNotEmpty){
      int count = await imhelper.saveReplys(commentReplys, ReplyMsgType.evaluatereplymsg);
    }
    if(issuccess){
      await postReadMessage(ReplyMsgType.evaluatereplymsg, uid, token, errorCallBack);
    }
  }

  Future<void> syncOrderUpdateFun(int uid, int ordertype, int count, String token, Function errorCallBack) async {
    await imhelper.saveUserOrder(uid, ordertype, count);
  }

  Future<void> syncOrderUnEvaluateUpdateFun(int uid, int count, Function errorCallBack) async {
    await imhelper.saveOrderUnEvaluate(uid, count);
  }



  Future<void> syncOrderExpirationFun(int uid, String token, Function errorCallBack) async {
    List<GroupRelation>? grouprelationlist = await syncActivityRelationInit(uid, token, errorCallBack);
    await imhelper.saveGroupRelationOrderExpiration(grouprelationlist);
    await postReadMessage(ReplyMsgType.orderexpiration, uid, token, errorCallBack);
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

  //已读的通知（评论，回复，系统通知）
  Future<bool> postReadMessage(ReplyMsgType replyMsgType,  int uid, String token, Function errorCallBack) async {
    bool ret = false;
    int? readindex = null;
    if(replyMsgType == ReplyMsgType.newmember){
      readindex = await imhelper.getMaxMemberId();
    }
    else if(replyMsgType == ReplyMsgType.newfollowed){
      readindex = await imhelper.getMaxFollowid();
    }
    else if(replyMsgType == ReplyMsgType.newfriend){
      readindex = await imhelper.getMaxFriendId();
    }
    else if(replyMsgType == ReplyMsgType.updatefriend){
      readindex = 0;
    }
    else if(replyMsgType == ReplyMsgType.sharedReaded){
      readindex = await imhelper.getMaxUserSharedId();
    }
    else if(replyMsgType == ReplyMsgType.evaluateactivity){
      readindex = await imhelper.getMaxUnEvaluateActivityid();
    }
    else if(replyMsgType == ReplyMsgType.orderexpiration){
      readindex = 0;
    }
    else
      readindex = await imhelper.getMaxReplyid(replyMsgType);

    if(readindex!=null){
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
        "type": replyMsgType.toString(),
        "readindex": readindex, //已经下载的消息索引，下载后标记为已经读取到本地
      });

      await NetUtil.getInstance().post(formData, "/Activity/noticeAlready", (
          Map<String, dynamic> data){
        ret = true;
      }, errorCallBack);
    }
    return ret;
  }
  //已读的点赞
  Future<bool> postReadLike(int likeType,  int uid, String token, Function errorCallBack) async {
    //点赞类型 0 活动 1 留言 2评价 3bug 4建议 5bug评价 6建议评价 7goodprice 8动态 9动态评价

    bool ret = false;
    int readindex = 0;
    if(likeType == 0){
      readindex = await imhelper.getMaxLikeID(0);
    }
    else if(likeType == 1){
      readindex = await imhelper.getMaxLikeID(1);
    }
    else if(likeType == 2){
      readindex = await imhelper.getMaxLikeID(2);
    }
    else if(likeType == 3){
      readindex = await imhelper.getMaxLikeID(3);
    }
    else if(likeType == 4){
      readindex = await imhelper.getMaxLikeID(4);
    }
    else if(likeType == 5){
      readindex = await imhelper.getMaxLikeID(5);
    }
    else if(likeType == 6){
      readindex = await imhelper.getMaxLikeID(6);
    }
    else if(likeType == 7){
      readindex = await imhelper.getMaxLikeID(7);
    }
    else if(likeType == 8){
      readindex = await imhelper.getMaxLikeID(8);
    }

    if(readindex!=null){
      FormData formData = FormData.fromMap({
        "token": token,
        "uid": uid,
        "likeType": likeType.toString(),
        "readindex": readindex, //已经下载的消息索引，下载后标记为已经读取到本地
      });

      await NetUtil.getInstance().post(formData, "/Activity/noticeAllike", (
          Map<String, dynamic> data){
        ret = true;
      }, errorCallBack);
    }
    return ret;
  }

  //搜索活动时出现的关键只推荐
  Future<List<SearchResult>> getRecommendSearchActivity(String content,
      Function errorCallBack) async {
    List<SearchResult> searchResults = [];
    FormData formData = FormData.fromMap({
      "content": content,
    });
    await NetUtil.getInstance().post(formData, "/Activity/getRecommendSearchActivity", (
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

  //获取社团热门搜索
  Future<List<SearchResult>> hotsearchActivity() async {
    List<SearchResult> searchResults = [];

    await NetUtil.getInstance().get(
        "/Activity/hotsearchActivity", (Map<String, dynamic> data) {
      if (data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          SearchResult searchResult = SearchResult.fromJson(data["data"][i]);
          searchResults.add(searchResult);
        }
      }
    }, params: {},
        errorCallBack: errorResponse);

    return searchResults;
  }

  //搜索活动
  Future<List<Activity>> searchActivity(String ordertype, String citycode, int currentIndex, bool isAllCity,String content, Function errorCallBack) async {
    List<Activity> activitys = [];
    FormData formData = FormData.fromMap({
      "content": content,
      "ordertype": ordertype,
      "citycode": citycode,
      "currentIndex": currentIndex,
      "isAllCity": isAllCity ? "1" : "0"
    });
    await NetUtil.getInstance().post(formData, "/Activity/searchActivity", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          Activity searchResult = Activity.fromJson(data["data"][i]);
          activitys.add(searchResult);
        }
      }
    }, errorCallBack);

    return activitys;
  }
  //搜索相识活动
  Future<List<Activity>> searchMoreLikeActivity(String citycode, int currentIndex, String content, String actid,Function errorCallBack) async {
    List<Activity> activitys = [];
    FormData formData = FormData.fromMap({
      "content": content,
      "citycode": citycode,
      "currentIndex": currentIndex,
    });
    await NetUtil.getInstance().post(formData, "/Activity/searchMoreLikeActivity", (
        Map<String, dynamic> data) {
      if (data["data"] != null) {
        for (int i = 0; i < data["data"].length; i++) {
          Activity searchResult = Activity.fromJson(data["data"][i]);
          if(searchResult.actid != actid)
            activitys.add(searchResult);
        }
      }
    }, errorCallBack);

    return activitys;
  }

  //评价活动
  Future<bool> evaluateActivity(int uid, String token,  String content, String orderid, String imagepaths, int liketype,  Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "content": content,
      "orderid": orderid,
      "imagepaths": imagepaths,
      "liketype": liketype,
    });
    await NetUtil.getInstance().post(formData, "/Activity/saveEvaluateInActivity", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);

    await imhelper.updateUnEvaluateOrder();

    return isUpdate;
  }

  Future<bool> evaluateReply(int evaluateid, int uid, String token, int touid,  String content, Function errorCallBack) async{
    bool isUpdate = false;

    FormData formData = FormData.fromMap({
      "evaluateid": evaluateid,
      "token": token,
      "uid": uid,
      "touid": touid,
      "content": content,
    });
    await NetUtil.getInstance().post(formData, "/Activity/saveEvaluateReply", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);
    return isUpdate;
  }

  //删除并退出活动
  Future<bool> delQuiteActivity(String actid, int uid, String token, Function errorCallBack) async{
    bool isUpdate = false;
    ShowMessage.showCenterToast("退出活动");
    FormData formData = FormData.fromMap({
      "actid": actid,
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/delQuiteActivity", (Map<String, dynamic> data) {
      ShowMessage.cancel();
      isUpdate = true;
    }, errorCallBack);

    return isUpdate;
  }

  //删除并退出活动
  Future<bool> delActivityOrder(String actid, int uid, String token, String orderid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "actid": actid,
      "token": token,
      "uid": uid,
      "orderid": orderid
    });
    await NetUtil.getInstance().post(formData, "/Activity/delActivityOrder", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);

    return isUpdate;
  }

  //退款
  Future<bool> refundActivityOrder(String actid, int uid, String token, String orderid, Function errorCallBack) async{
    bool isUpdate = false;
    FormData formData = FormData.fromMap({
      "actid": actid,
      "token": token,
      "uid": uid,
      "orderid": orderid
    });
    await NetUtil.getInstance().post(formData, "/Activity/refundActivityOrder", (Map<String, dynamic> data) {
      isUpdate = true;
    }, errorCallBack);

    return isUpdate;
  }


  //删除并退出活动
  Future<bool> manageDelQuiteActivity(String actid, int uid, String token, String uids, Function errorCallBack) async{
    bool isUpdate = false;
    ShowMessage.showCenterToast("移除成员");
    FormData formData = FormData.fromMap({
      "actid": actid,
      "token": token,
      "uid": uid,
      "uids": uids
    });
    await NetUtil.getInstance().post(formData, "/Activity/manageDelQuiteActivity", (Map<String, dynamic> data) {
      ShowMessage.cancel();
      isUpdate = true;
    }, errorCallBack);

    return isUpdate;
  }

  //确定转账
  Future<bool> activityFundTransfer(String actid, int uid, String token, String orderid, Function errorCallBack) async{
    bool isUpdate = false;
    ShowMessage.showCenterToast("付款中");
    FormData formData = FormData.fromMap({
      "actid": actid,
      "token": token,
      "uid": uid,
      "orderid": orderid
    });
    await NetUtil.getInstance().post(formData, "/Activity/activityFundTransfer", (Map<String, dynamic> data) {
      ShowMessage.cancel();
      isUpdate = true;
    }, errorCallBack);

    return isUpdate;
  }


  //获取评价列表
  Future<List<EvaluateActivity>> getEvaluateActivityList(String actid, int uid, int currentIndex,  Function errorCallBack) async{
    List<EvaluateActivity> evaluateActivities = [];

    FormData formData = FormData.fromMap({
      "actid": actid,
      "uid": uid,
      "currentIndex": currentIndex,
    });
    await NetUtil.getInstance().post(formData, "/Activity/getEvaluateActivity", (Map<String, dynamic> data) {
      for (int i = 0; i < data["data"].length; i++) {
        EvaluateActivity evaluateActivity = EvaluateActivity.fromJson(data["data"][i]);
        evaluateActivities.add(evaluateActivity);
      }
    }, errorCallBack);

    if(evaluateActivities != null && evaluateActivities.length > 0) {
      for (int i = 0; i < evaluateActivities.length; i++){
        List<String> evaluateid = await imhelper.selActivityEvaluateState(evaluateActivities[i].evaluateid.toString(),
            Global.profile.user!.uid);
        if(evaluateid.length > 0)
          evaluateActivities[i].likeuid = Global.profile.user!.uid;
        else{
          evaluateActivities[i].likeuid = 0;
        }
//        print("aaa:" + evaluateActivities[i].likeuid.toString());
//        print("bbb:" + evaluateActivities[i].likenum.toString());
      }
    }

    return evaluateActivities;
  }
  //获取评价回复列表
  Future<List<EvaluateActivityReply>> getEvaluateReplyList(int evaluateid,  Function errorCallBack) async{
    List<EvaluateActivityReply> evaluateReplys = [];

    FormData formData = FormData.fromMap({
      "evaluateid": evaluateid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/getEvaluateReplyList", (Map<String, dynamic> data) {
      for (int i = 0; i < data["data"].length; i++) {
        EvaluateActivityReply reply = EvaluateActivityReply.fromJson(data["data"][i]);
        evaluateReplys.add(reply);
      }
    }, errorCallBack);

    return evaluateReplys;
  }

  //获取评价回复列表
  Future<EvaluateActivity?> getEvaluateActivityByEvaluateid(int evaluateid) async{
    EvaluateActivity? evaluateActivity;

    FormData formData = FormData.fromMap({
      "evaluateid": evaluateid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/getEvaluateActivityByEvaluateid", (Map<String, dynamic> data) {
      evaluateActivity = EvaluateActivity.fromJson(data["data"]);

    }, errorResponse);

    return evaluateActivity;
  }

  //获取支付宝用户信息
  Future<String> updateAliPayInfo(int uid,  String token,  String auth_code, Function errorCallBack) async {
    String aliuserid = "";
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "auth_code": auth_code
    });

    await NetUtil.getInstance().post(formData, "/AliPay/updateAliPayInfo", (Map<String, dynamic> data) {
      aliuserid = data["data"];
    }, errorCallBack);
    return aliuserid;
  }



  //获取order信息
  Future<Map<dynamic, dynamic>?> getActivityOrder(int uid,  String token,  String actid, String goodpriceid, String specsid,
      int productnum, String orderid, int paymenttype, String speacename, Function errorCallBack) async {
    Map<dynamic, dynamic>? orderinfo = null;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "actid": actid,
      "goodpriceid": goodpriceid,
      "specsid": specsid,
      "productnum": productnum,
      "orderid": orderid,
      "paymenttype": paymenttype,
      "speacename": speacename
    });

    await NetUtil.getInstance().post(formData, "/Activity/getActivityOrder", (Map<String, dynamic> data) {
      if(paymenttype == 0) {
        //支付宝
        orderinfo = Map();
        orderinfo!.addAll({'data':data['data']});
      }

      if(paymenttype == 1){
        //微信
        orderinfo  = data['data'] as Map;
      }
    }, errorCallBack);

    return orderinfo;
  }

  //获取用户活动待付款订单
  Future<Order?> getActivityPendingOrder(int uid,  String token,  String actid, Function errorCallBack) async {
    Order? order;
    FormData formData = FormData.fromMap({
      "uid": uid,
      "token": token,
      "actid": actid
    });

    await NetUtil.getInstance().post(formData, "/Activity/getActivityPendingOrder", (Map<String, dynamic> data) {
      order = Order.fromJson( data["data"]);
    }, errorCallBack);
    return order;
  }




  //举报活动
  Future<String> reportActivity(int uid,  int touid, String token,  String actid, int reporttype, String reportcontent,
      String images, int imagetype, int sourcetype, String captchaVerification, Function errorCallBack) async {
    String ret = "";
    FormData formData = FormData.fromMap({
      "uid": uid,
      "touid": touid,
      "token": token,
      "actid": actid,
      "reporttype": reporttype,
      "reportcontent": reportcontent,
      "images": images,
      "imagetype": imagetype,
      "sourcetype": sourcetype,
      "captchaVerification": captchaVerification
    });

    await NetUtil.getInstance().post(formData, "/Activity/reportActivity", (Map<String, dynamic> data) {
      ret = data["data"];
    }, errorCallBack);
    return ret;
  }

  //获取我的举报
  Future<List<Report>> getMyReport(int uid, String token, Function errorCallBack) async{
    List<Report> myReports = [];

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
    });
    await NetUtil.getInstance().post(formData, "/Activity/getMyReport", (Map<String, dynamic> data) {
      for (int i = 0; i < data["data"].length; i++) {
        Report myReport = Report.fromJson(data["data"][i]);
        myReports.add(myReport);
      }    }, errorCallBack);
    return myReports;
  }

  //获取我的举报详情
  Future<Report?> getMyReportInfo(int uid, String token, String reportid, int sourcetype, Function errorCallBack) async{
    Report? myReport = null;

    FormData formData = FormData.fromMap({
      "token": token,
      "uid": uid,
      "reportid": reportid,
      "sourcetype": sourcetype
    });
    await NetUtil.getInstance().post(formData, "/Activity/getMyReportInfo", (Map<String, dynamic> data) {
      myReport = Report.fromJson(data["data"]);
    }, errorCallBack);
    return myReport;
  }
}