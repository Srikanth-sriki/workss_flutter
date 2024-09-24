

import 'dart:io';

class Config{
  static String url = "http://13.127.193.213/api";
  static String accessToken = '';
  static String id = '';
  static bool profileCompleted = false;
  static String phoneNumber = "";
  static String languageSelected = "";
  static String introUploaded = "";
  static String name = "";
  static String userType = "";





  static Map<String, String> headers(){
    return {
      HttpHeaders.contentTypeHeader : "application/json",
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