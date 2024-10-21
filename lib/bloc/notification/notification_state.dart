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
  final List<NotificationModel> notifications;

  const NotificationFetchSuccess({required this.notifications});

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