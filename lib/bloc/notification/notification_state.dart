part of 'notification_bloc.dart';

@immutable
sealed class NotificationState extends Equatable{
  const NotificationState();
  @override
  List<Object> get props => [];
}

final class NotificationInitial extends NotificationState {}

class FetchNotificationListLoading extends NotificationState {
  const FetchNotificationListLoading();
  @override
  List<Object> get props => [];
}


class NotificationFetchSuccess extends NotificationState {
  List<NotificationModel> notifications = [];

  NotificationFetchSuccess({required this.notifications});

  @override
  List<Object> get props => [notifications];
}

class NotificationFetchFailure extends NotificationState {
  final String message;

  const NotificationFetchFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class NotificationClearSuccess extends NotificationState {
  final String message;

  const NotificationClearSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class NotificationClearAllSuccess extends NotificationState {
  final String message;

  const NotificationClearAllSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class NotificationViewSuccess extends NotificationState {
  final String message;

  const NotificationViewSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class NotificationViewFailed extends NotificationState {
  final String message;

  const NotificationViewFailed({required this.message});

  @override
  List<Object> get props => [message];
}