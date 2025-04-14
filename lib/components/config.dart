import 'dart:io';

class Config {
  static String url = "https://43.204.94.146/api";
  static String socketUrl = "https://43.204.94.146";
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
