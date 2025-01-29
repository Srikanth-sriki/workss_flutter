part of 'report_post_bloc.dart';

@immutable
sealed class ReportPostState extends Equatable {
  const ReportPostState();
  @override
  List<Object> get props => [];
}

final class ReportPostInitial extends ReportPostState {}

class ReportWorkPostFailed extends ReportPostState {
  String message;
  ReportWorkPostFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ReportWorkPostSuccess extends ReportPostState {
  String message;
  ReportWorkPostSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class ReportWorkPostLoading extends ReportPostState {
  const ReportWorkPostLoading();
  @override
  List<Object> get props => [];
}
