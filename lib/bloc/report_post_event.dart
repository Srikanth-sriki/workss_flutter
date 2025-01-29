part of 'report_post_bloc.dart';

@immutable
sealed class ReportPostEvent  extends Equatable {
  const ReportPostEvent();
  @override
  List<Object> get props => [];
}

typedef CallbackWithMessage = void Function(String message);

class ReportWorkPostEvent extends ReportPostEvent {
  String reason;
  String workId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  ReportWorkPostEvent(
      {required this.onSuccess, required this.onError, required this.reason,required this.workId});
  @override
  List<Object> get props => [onSuccess, onError, reason,workId];
}

class ReportProfessionalEvent extends ReportPostEvent {
  String reason;
  String userId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  ReportProfessionalEvent(
      {required this.onSuccess, required this.onError, required this.reason,required this.userId});
  @override
  List<Object> get props => [onSuccess, onError, reason,userId];
}