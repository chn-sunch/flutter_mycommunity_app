import 'package:equatable/equatable.dart';
import '../../../model/user.dart';

abstract class  MyFollowEvent extends Equatable {


  @override
  List<Object> get props => [];
}
///加载更多
class PostFetched extends MyFollowEvent{
  final User? user;
  final List<int>? ids;
  PostFetched({required this.user, this.ids});
}
//加载更多活动
class PostActvityFetched extends MyFollowEvent{
  final User user;
  final List<int>? ids;
  PostActvityFetched({required this.user, this.ids});
}
//加载更多关注社团
class PostCommunityFetched extends MyFollowEvent{
  final User user;
  final List<int>? ids;
  PostCommunityFetched({required this.user, this.ids});
}
///刷新
class Refreshed extends MyFollowEvent{
  final User user;
  final List<int>? ids;

  Refreshed({required this.user, this.ids});
}

