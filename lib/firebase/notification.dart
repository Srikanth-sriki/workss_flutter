import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:works_app/components/config.dart';

import '../bloc/chart/chart_bloc.dart';
import '../bloc/friends/friends_bloc.dart';
import '../bloc/notification/notification_bloc.dart';
import '../bloc/show_interested/show_interested_bloc.dart';
import '../ui/home/notification_list.dart';

void initializeNotifications(GlobalKey<NavigatorState> navigatorKey) async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    print('22222222222222222222222222222222222222');
    print('22222222222222222222222222222222222222');
    print(notification!.body);
    if (notification != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            color: Colors.blue,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    print('1111111111111111111111111111111111111111111111111');
    if (notification != null && !kIsWeb) {

      final notificationBody = message.notification?.body ?? '';
      if (notificationBody.contains('new message')) {
        Config.chatHasNewMessage.value = true;
      }
      _handleNotificationNavigation(navigatorKey,message);
    }
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    print('5555555555555555555555555555555555');
    if (message != null) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && !kIsWeb) {
        final notificationBody = message.notification?.body ?? '';
        if (notificationBody.contains('new message')) {
          Config.chatHasNewMessage.value = true;
        }
        _handleNotificationNavigation(navigatorKey,message);
      }
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            color: Colors.blue,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
      );
    }
  });
}

// void _handleNotificationNavigation(GlobalKey<NavigatorState> navigatorKey) {
//   final context = navigatorKey.currentContext;
//   if (context == null) return;
//
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => MultiBlocProvider(
//         providers: [
//           BlocProvider(
//             create: (_) => NotificationBloc()..add(const FetchNotificationList()),
//           ),
//           BlocProvider(create: (_) => ShowInterestedBloc()),
//           BlocProvider(create: (_) => ChartBloc()),
//           BlocProvider(
//             create: (_) => FriendsBloc()
//               ..add(FetchFriendsRequestListEvent(
//                 page: 1,
//                 pageSize: 10,
//                 keyWord: '',
//               )),
//           ),
//         ],
//         child: const NotificationListScreen(),
//       ),
//     ),
//   );
// }


void _handleNotificationNavigation(GlobalKey<NavigatorState> navigatorKey, RemoteMessage message) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  final notificationBody = message.notification?.body ?? '';
  final data = message.data;

  if (notificationBody.contains('new message')) {
    Navigator.pushNamed(
      context,
      '/main_screen',
      arguments: {'selectedIndex': 3},
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => NotificationBloc()..add(const FetchNotificationList()),
            ),
            BlocProvider(create: (_) => ShowInterestedBloc()),
            BlocProvider(create: (_) => ChartBloc()),
            BlocProvider(
              create: (_) => FriendsBloc()
                ..add(FetchFriendsRequestListEvent(
                  page: 1,
                  pageSize: 10,
                  keyWord: '',
                )),
            ),
          ],
          child: const NotificationListScreen(),
        ),
      ),
    );
  }
}
