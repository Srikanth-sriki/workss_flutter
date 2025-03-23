// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';
//
// import '../../dao/home_dao.dart';
// import '../../models/notification_list_model.dart';
//
// part 'notification_event.dart';
// part 'notification_state.dart';
//
// class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
//   late HomeDao homeDao;
//   NotificationBloc() : super(NotificationInitial()) {
//     homeDao = HomeDao();
//     on<NotificationEvent>((event, emit) {
//       // TODO: implement event handler
//     });
//   }
// }


import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../components/global_handle.dart';
import '../../dao/home_dao.dart';
import '../../models/notification_list_model.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  late HomeDao homeDao;

  NotificationBloc() : super(NotificationInitial()) {
    homeDao = HomeDao();

    on<FetchNotificationList>(_onFetchNotificationList);
    on<FetchNotificationSingleClear>(_onFetchNotificationSingleClear);
    on<FetchNotificationClearAll>(_onFetchNotificationClearAll);
    on<FetchNotificationViewEvent>(_onFetchNotificationView);
  }

  Future<void> _onFetchNotificationList(
      FetchNotificationList event, Emitter<NotificationState> emit) async {
    try {
      emit(const FetchNotificationListLoading());
      final response = await homeDao.fetchNotificationListView();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        List<NotificationModel> notifications = (jsonDecoded['data']['notifications'] as List)
            .map((notification) => NotificationModel.fromJson(notification))
            .toList();
        emit(NotificationFetchSuccess(notifications: notifications));
      } else {
        emit(NotificationFetchFailure(message: jsonDecoded['message']));
      }
    } catch (error) {
      emit(NotificationFetchFailure(message: "Something went wrong"));
    }
  }

  Future<void> _onFetchNotificationSingleClear(
      FetchNotificationSingleClear event, Emitter<NotificationState> emit) async {
    try {
      final response = await homeDao.fetchNotificationClearSingle(Id: event.notificationId);
      if (response.statusCode == 200) {
        emit(NotificationClearSuccess(message: "Notification cleared successfully"));
        add(const FetchNotificationList()); // Re-fetch notifications after clearing
      } else {
        emit(NotificationFetchFailure(message: "Failed to clear notification"));
      }
    } catch (error) {
      emit(NotificationFetchFailure(message: "Something went wrong while clearing notification"));
    }
  }

  Future<void> _onFetchNotificationClearAll(
      FetchNotificationClearAll event, Emitter<NotificationState> emit) async {
    try {
      final response = await homeDao.fetchNotificationClearAll();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        emit(NotificationClearAllSuccess(message: "All notifications cleared successfully"));
        add(const FetchNotificationList()); // Re-fetch notifications after clearing all
      } else {
        emit(NotificationFetchFailure(message: jsonDecoded['message']));
      }
    } catch (error) {
      emit(NotificationFetchFailure(message: "Something went wrong while clearing all notifications"));
    }
  }

  Future<void> _onFetchNotificationView(
      FetchNotificationViewEvent event, Emitter<NotificationState> emit) async {
    try {
      final response = await homeDao.fetchNotificationView(id: event.id);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        emit(NotificationViewSuccess(message: "All notifications cleared successfully"));
        add(const FetchNotificationList()); // Re-fetch notifications after clearing all
      } else {
        emit(NotificationViewFailed(message: jsonDecoded['message']));
        event.onError!(jsonDecoded['message']);
      }
    } catch (error) {
      emit(NotificationViewFailed(message: "Something went wrong"));
      event.onError!('Something went wrong');
    }
  }
}
