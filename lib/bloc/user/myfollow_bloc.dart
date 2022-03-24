import 'package:bloc/bloc.dart';
import '../../model/activity.dart';
import '../../model/dynamic.dart';
import '../../model/user.dart';
import '../../service/activity.dart';
import '../../service/userservice.dart';

import '../../bloc/user/event/myfollow_event.dart';
import '../../bloc/user/state/myfollow_state.dart';

export 'event/myfollow_event.dart';
export 'state/myfollow_state.dart';

class MyFollowBloc extends Bloc<MyFollowEvent, MyFollowState> {
  final UserService _userService = new UserService();
  final ActivityService _activityService = new ActivityService();

  MyFollowBloc():super(PostInitial());

  // @override
  // // TODO: implement initialState
  // MyFollowState get initialState => PostInitial();
  List<User> users = [];
  List<Activity> activitys = [];

  @override
  Stream<MyFollowState> mapEventToState(MyFollowEvent event) async* {
    final currentState = state;
    try {
      if (event is PostFetched ) {
        if (currentState is PostInitial) {
          if(event.user == null){
            yield NoLogin();
            return;
          }
          yield PostLoading();
          users = await _userService.getFollowUsers(0, event.user!.uid, event.user!.token!);
          if(users != null &&users.length  > 0) {
            activitys = await _activityService.getActivityListByFollow(0, users);
          }
          yield PostSuccess(users: users, activitys: activitys, hasReachedActivityMax: false,
              hasReachedUserMax: false);
          return;
        }
        //加载更多
      }

      if (event is PostActvityFetched){
        if (currentState is PostSuccess && !currentState.hasReachedActivityMax) {
          int currentindex = 0;
          currentindex += currentState.activitys.length;
          if(currentState.users != null && currentState.users.length > 0) {
            activitys = await _activityService.getActivityListByFollow(currentindex, currentState.users);
          }

          if(activitys.length > 0)
            currentState.activitys.addAll(activitys);
          yield activitys.length == 0
              ? currentState.copyWith(hasReachedActivityMax: true)
              : PostSuccess(
            users: currentState.users,
            activitys: currentState.activitys,
            hasReachedActivityMax: false,
            hasReachedUserMax: currentState.hasReachedUserMax,
            time: DateTime.now().toString()
          );
          return;
        }

      }
      if (event is PostCommunityFetched){
        if (currentState is PostSuccess && !currentState.hasReachedUserMax) {
          int currentindex = 0;
          currentindex += currentState.users.length;

          users = await _userService.getFollowUsers(currentindex,  event.user.uid, event.user.token!);
          if(users!= null && users.length > 0) {
            currentState.users.addAll(users);
            activitys = await _activityService.getActivityListByFollow(0, currentState.users);
            currentState.activitys.clear();
            currentState.activitys.addAll(activitys);
          }
          yield users.length == 0
              ? currentState.copyWith(hasReachedUserMax: true)
              : PostSuccess(
              users: currentState.users,
              activitys: currentState.activitys,
              hasReachedUserMax: false,
              hasReachedActivityMax: currentState.hasReachedActivityMax,
              time: DateTime.now().toString()
          );
          return;

        }

      }

      if (event is Refreshed){
        users = await _userService.getFollowUsers(0, event.user.uid, event.user.token!);
        if(users != null && users.length > 0) {
          activitys = await _activityService.getActivityListByFollow(0, users);
        }
        yield PostSuccess(users: users, activitys: activitys, hasReachedActivityMax: false, hasReachedUserMax: false);
      }
    }
    catch(_){
      yield PostFailure();
    }
  }

  @override
  void onTransition(Transition<MyFollowEvent, MyFollowState> transition) {
    //print(transition);
    super.onTransition(transition);
  }
}

Map<String, List<Dynamic>> groupData(List<Dynamic> myDynamics){
  Map<String, List<Dynamic>> map = new Map.fromIterable(
      myDynamics,
      key: (key) => key.createtime.substring(0, 10),
      value: (value){
        return myDynamics.where((item) => (item.createtime.substring(0, 10) == value.createtime.substring(0, 10))).toList();
      }
  );
  return map;
}