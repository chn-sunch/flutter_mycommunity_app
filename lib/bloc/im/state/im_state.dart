
import '../../../model/im/sysmessage.dart';
import 'package:equatable/equatable.dart';
import '../../../model/im/grouprelation.dart';
import '../../../model/im/timelinesync.dart';


abstract class ImState  extends Equatable{
  const ImState();

  @override
  List<Object> get props => [];
}

class initImState extends ImState {}

class errorState extends ImState {
  String error = "";
  String errorstatusCode = "";
  errorState({this.error = "", this.errorstatusCode = ""});

  @override
  List<Object> get props => [error, errorstatusCode];

  @override
  String toString() => 'errorState { statusCode: $errorstatusCode ,error: $error }';
}

//获取消息
class PostInitial extends ImState {}
//获取消息失败
class PostFailure extends ImState {}

class PostSuccess extends ImState {
  //消息库
  final List<TimeLineSync>? timeLineSyncs;
  final bool? hasReachedMax;

  const PostSuccess({
    this.timeLineSyncs,
    this.hasReachedMax,
  });

  PostSuccess copyWith({
    List<TimeLineSync>? timeLineSyncs,
    bool? hasReachedMax,
  }) {
    return PostSuccess(
      timeLineSyncs: timeLineSyncs ?? this.timeLineSyncs,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [timeLineSyncs??[], hasReachedMax??false];

  @override
  String toString() =>
      'PostSuccess { posts: ${timeLineSyncs}, hasReachedMax: $hasReachedMax }';
}

class PostLoading extends ImState {}

class NewMessageState extends ImState{

  SysMessage sysMessage;
  List<GroupRelation> groupRelations;
  List<TimeLineSync> msgMessage;


  NewMessageState({required this.sysMessage, required this.groupRelations, required this.msgMessage});

  @override
  List<Object> get props => [sysMessage, groupRelations, msgMessage];
}



