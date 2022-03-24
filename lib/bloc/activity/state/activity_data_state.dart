import 'package:equatable/equatable.dart';
import '../../../model/activity.dart';

abstract class ActivityDataState extends Equatable {
  const ActivityDataState();

  @override
  List<Object> get props => [];
}
///初始化
class PostUninitialized extends ActivityDataState {}

///获取数据中
class PostLoading extends ActivityDataState {}
///获取更多数据
class PostLoaded extends ActivityDataState {
  final List<Activity>? activitys;
  final List<int>? notinteresteduids;
  final bool? hasReachedMax;
  final bool? error;
  final bool? isRebuild;
  PostLoaded({
    this.activitys,
    this.hasReachedMax,
    this.error,
    this.notinteresteduids,
    this.isRebuild = true//2次的状态不同才会rebuild
  }){

    List<Activity> emptyList = [];
    activitys!.forEach((e) {
      emptyList.add(e);
    });

    emptyList.forEach((e) {
      if(notinteresteduids != null && notinteresteduids!.contains(e.user!.uid)){
        activitys!.remove(e);
      }
    });
  }

  PostLoaded copyWith({
    List<Activity>? activitys,
    bool? hasReachedMax,
  }) {
    return PostLoaded(
      activitys: activitys ?? this.activitys,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [activitys??"", hasReachedMax??false, error??"", isRebuild??false];

  @override
  String toString() =>
      'PostLoaded { posts: ${activitys}, hasReachedMax: $hasReachedMax, error: $error } }';
}
///获取数据异常初始化
class PostUninitedError extends ActivityDataState {

  String error;
  String errorstatusCode;
  PostUninitedError({this.error = "", this.errorstatusCode = ""});

  @override
  List<Object> get props => [error, errorstatusCode];

}
///更新首页
class UpdateHome  extends ActivityDataState {
  UpdateHome();
}