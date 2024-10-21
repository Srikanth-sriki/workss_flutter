part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object> get props => [];
}

class FetchNotificationList extends NotificationEvent {
  const FetchNotificationList();

  @override
  List<Object> get props => [];
}

class FetchNotificationSingleClear extends NotificationEvent {
  final String notificationId;

  const FetchNotificationSingleClear(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}


class FetchNotificationClearAll extends NotificationEvent {
  const FetchNotificationClearAll();

  @override
  List<Object> get props => [];
}
