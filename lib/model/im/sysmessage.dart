class SysMessage{
  int commentreply_count = 0;//评论和回复的消息
  int follow_count = 0;//新的关注数量
  int activityevalute_count = 0;//新的待评价活动
  int neworderpending_count = 0;//新的待付款订单
  int neworderfinish_count = 0;//新的待确认订单
  int newlithumbup_count = 0;//新的点赞数量
  int newImMode = 0;//消息模块的通知数量 imcount + follow_count+commentreply_count+newlithumbup_count
  int newMyMode = 0;//我的待处理的通知 activityevalute_count+neworderpending_count + neworderfinish_count
  SysMessage(this.commentreply_count,  this.follow_count, this.activityevalute_count, this.neworderpending_count, this.neworderfinish_count,
      this.newlithumbup_count, this.newImMode, this.newMyMode);


}