import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

void initializeNotifications(BuildContext context) async {
  // Create a notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // This is the id of the channel
    'High Importance Notifications', // This is the name of the channel
    description: 'This channel is used for important notifications.', // Optional description
    importance: Importance.max,
  );

  // Initialize FlutterLocalNotificationsPlugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Create the notification channel on Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Request permission for notifications
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Foreground message handling
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("The live : ${message.notification?.android?.imageUrl}");
    print("The live : ${message.data['notification_type']}");
    print("The live : ${message.notification?.android?.link}");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && !kIsWeb) {
      print(notification.body);
      print("The message notification ${message.data}");

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id, // Use the defined channel
            channel.name,
            channelDescription: channel.description,
            color: Colors.blue,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            styleInformation: const BigTextStyleInformation(''),
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true,
          ),
        ),
      );
    }
  });

  // Handle background message interactions
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && !kIsWeb) {
      print("Notification: ${message.notification}");
      print("Notification Title: ${message.notification!.title}");
      print("Notification Body: ${message.notification!.body}");

      print(notification.body);
      print("The message ${message.data}");

      // Navigate to the desired screen based on the custom data
    }
  });

  // If the app is opened from a terminated state
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    print("The message is : $message");
    if (message != null) {
      print("Inside the message");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      print("The values are notification : $notification kIsWeb $kIsWeb");
      if (notification != null && !kIsWeb) {
        print("When the app is completely terminated");

        print(notification.body);
        print("The message ${message.data}");

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification?.title,
          notification?.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id, // Use the defined channel
              channel.name,
              channelDescription: channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              ongoing: true,
              styleInformation: const BigTextStyleInformation(''),
            ),
          ),
        );
      } else {
        print("Message is null");
      }
    }
  });
}
