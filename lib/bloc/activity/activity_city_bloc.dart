import 'package:flutter_bloc/flutter_bloc.dart';
import '../../service/activity.dart';
import 'event/activity_city_event.dart';
import 'state/activity_city_state.dart';

export './event/activity_city_event.dart';
export './state/activity_city_state.dart';

class CityActivityDataBloc extends Bloc<PostEvent, CityActivityState> {
  final ActivityService _activityService = new ActivityService();

  CityActivityDataBloc():super(PostInitial());

  //@override
  // TODO: implement initialState
  //CityActivityState get initialState => PostInitial();

  @override
  Stream<CityActivityState> mapEventToState(PostEvent event) async* {
    final currentState = state;
    try {
      if (event is PostFetched && !_hasReachedMax(currentState)) {
        if (currentState is PostInitial || currentState is PostFailure) {
          yield PostLoading();
          final activitys = await _activityService
              .getActivityListByCity(0, event.locationCode);
          yield PostSuccess(activitys: activitys, hasReachedMax: activitys.length < 6 ? true : false, isRefreshed: true);
          return;
        }
        //加载更多
        if (currentState is PostSuccess ) {
          final activitys = await _activityService
              .getActivityListByCity(currentState.activitys!.length, event.locationCode);
          yield activitys.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostSuccess(
            activitys: currentState.activitys! + activitys,
            hasReachedMax: false,
            isRefreshed: false
          );
        }
      }
      if (event is Refreshed){
        yield PostLoading();
        final activitys = await _activityService
            .getActivityListByCity(0, event.locationCode);
        yield PostSuccess(activitys: activitys, hasReachedMax: activitys.length < 6 ? true : false, isRefreshed: true);
        return;
      }
    }
    catch(_){
      yield PostFailure();
    }
  }

  @override
  void onTransition(Transition<PostEvent, CityActivityState> transition) {
    //print(transition);
    super.onTransition(transition);
  }

  bool _hasReachedMax(CityActivityState state) =>
      state is PostSuccess  && state.hasReachedMax;
}
