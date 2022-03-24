import 'package:equatable/equatable.dart';


abstract class  ActivityDataEvent extends Equatable {
  ActivityDataEvent();

  @override
  List<Object> get props => [];
}
///加载更多
class Fetch extends ActivityDataEvent{
}
///刷新
class Refresh extends ActivityDataEvent{
}