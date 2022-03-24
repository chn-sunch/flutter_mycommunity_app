import 'package:bloc/bloc.dart';

import '../../service/activity.dart';
import '../../util/imhelper_util.dart';
import '../../global.dart';
import 'event/activity_data_event.dart';
import 'state/activity_data_state.dart';

export 'event/activity_data_event.dart';
export 'state/activity_data_state.dart';

class ActivityDataBloc extends Bloc<ActivityDataEvent, ActivityDataState> {
  final ActivityService _activityService = new ActivityService();
  final ImHelper _imHelper = new ImHelper();
  List<int> notinteresteduids = [];
  ActivityDataBloc() : super(PostUninitialized());
  int currentlength = 0;

  // @override
  // // TODO: implement initialState
  // ActivityDataState get initialState => PostUninitialized();

  @override
  Stream<ActivityDataState> mapEventToState(ActivityDataEvent event) async* {
    final currentState = state;

    try {
      if(event is Fetch && !_hasReachedMax(currentState)) {
        if (currentState is PostUninitialized) {
          yield PostLoading();
          final activitys = await _activityService.getActivityListByUpdateTime(0);
          if(Global.profile.user != null) {
            notinteresteduids = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
          }
          currentlength = activitys.length;
          yield PostLoaded(activitys: activitys, hasReachedMax: activitys.length < 6 ? true : false, error: false,
              notinteresteduids: notinteresteduids);
          return;
        }
        //加载更多
        if (currentState is PostLoaded ) {
          final activitys = await _activityService.getActivityListByUpdateTime(currentlength);
          if(activitys != null)
            currentlength += activitys.length;
          if(Global.profile.user != null) {
            notinteresteduids = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
          }
          yield activitys.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostLoaded(activitys: currentState.activitys! + activitys, hasReachedMax: false, notinteresteduids: notinteresteduids
          );
        }
      }

      if(event is Refresh){
        if (currentState is PostLoaded) {
          final activitys = await _activityService.getActivityListByUpdateTime(0);
          currentlength = activitys.length;
          if(Global.profile.user != null) {
            notinteresteduids = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
          }
          yield PostLoaded(activitys: activitys, hasReachedMax: activitys.length < 6 ? true : false, error: false, notinteresteduids: notinteresteduids);
        }
        if (currentState is PostUninitedError) {
          yield PostLoading();
          final activitys = await _activityService.getActivityListByUpdateTime(0);
          currentlength = activitys.length;
          if(Global.profile.user != null) {
            notinteresteduids = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
          }
          yield PostLoaded(activitys: activitys, hasReachedMax: activitys.length < 6 ? true : false, error: false, notinteresteduids: notinteresteduids);
        }
        if (currentState is PostUninitialized) {
          yield PostLoading();
          final activitys = await _activityService.getActivityListByUpdateTime(0);
          currentlength = activitys.length;
          if(Global.profile.user != null) {
            notinteresteduids = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
          }
          yield PostLoaded(activitys: activitys, hasReachedMax: activitys.length < 6 ? true : false, error: false, notinteresteduids: notinteresteduids);
        }
      }
    }
    catch(_){
      ///初始化时异常
      if(currentState is PostUninitialized || currentState is PostUninitedError || (currentState is PostLoaded && event is Refresh))
        yield PostUninitedError();
      ///加载更多时异常  注意：state内容一致时不会rebuild
      if((currentState is PostLoaded && event is Fetch)) {
        if(Global.profile.user != null) {
          notinteresteduids = await _imHelper.getNotInteresteduids(Global.profile.user!.uid);
        }
        PostLoaded tem = PostLoaded(activitys: currentState.activitys,
            hasReachedMax: false,
            isRebuild:  currentState.isRebuild! ? false : true,
            error: true, notinteresteduids: notinteresteduids);
        if(tem == currentState){
//          print(111);
        }
        yield tem;
      }
    }
  }

  @override
  void onTransition(Transition<ActivityDataEvent, ActivityDataState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  bool _hasReachedMax(ActivityDataState state) =>
      state is PostLoaded && state.hasReachedMax!;
}