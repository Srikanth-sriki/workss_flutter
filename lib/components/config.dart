import 'dart:io';

import 'package:flutter/cupertino.dart';

class Config {
  // static String url = "https://43.204.94.146/api";
  // static String socketUrl = "https://43.204.94.146";
  // static String url = "https://api.workss.co.in/api";
  // static String socketUrl = "https://api.workss.co.in";
  static String url = "https://dev.api.workss.co.in/api";
  static String socketUrl = "https://dev.api.workss.co.in";
  static String accessToken = '';
  static String id = '';
  static bool profileCompleted = false;
  static String phoneNumber = "";
  static String languageSelected = "";
  static String introUploaded = "";
  static String name = "";
  static String profilePic = "";
  static bool accountVerify = false;
  static bool isRegistered = false;
  static String userType = "";
  static String fcmToken = "";
  static int notificationCount =0;
  static bool chartCount = false ;
  static ValueNotifier<bool> chatHasNewMessage = ValueNotifier<bool>(false);
  static ValueNotifier<bool> notificationReceiveMessage = ValueNotifier<bool>(false);
  static bool fromNotificationTap = false;

  static Map<String, String> headers() {
    return {
      HttpHeaders.contentTypeHeader: "application/json",
    };
  }
  // static Map<String, String> authHeaders() {
  //   return {
  //     HttpHeaders.contentTypeHeader: "application/json",
  //     "access_token" :Config.accessToken
  //   };
  // }

  static Map<String, String> authHeaders() {
    return {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer ${Config.accessToken}",
    };
  }
}
