import 'package:equatable/equatable.dart';
import '../../../model/activity.dart';

abstract class CityActivityState extends Equatable {
  const CityActivityState();

  @override
  List<Object> get props => [];
}

class PostInitial extends CityActivityState {}

class PostFailure extends CityActivityState {}

class PostSuccess extends CityActivityState {
  List<Activity>? activitys;
  bool hasReachedMax = false;
  bool isRefreshed = false;
  PostSuccess({
    this.activitys,
    this.hasReachedMax = false,
    this.isRefreshed = false,
  });

  PostSuccess copyWith({
    List<Activity>? posts,
    bool hasReachedMax = false,
    bool isRefreshed = false
  }) {
    return PostSuccess(
      activitys: activitys ?? this.activitys,
      hasReachedMax: hasReachedMax,
      isRefreshed: isRefreshed,

    );
  }

  @override
  List<Object> get props => [activitys??[], hasReachedMax];

  @override
  String toString() =>
      'PostSuccess { posts: ${activitys}, hasReachedMax: $hasReachedMax }';
}

class PostLoading extends CityActivityState {}
