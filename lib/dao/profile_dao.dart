import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../components/config.dart';
import '../helper/custom_log.dart';

class ProfileDao {
  Future fetchProfile() async {
    var url = '${Config.url}/user/profile/fetch-profile';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future fetchPostedWork() async {
    var url = '${Config.url}/user/profile/fetch-posted-works';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future fetchInterestedWork() async {
    var url = '${Config.url}/user/profile/fetch-work-intrests';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future fetchSavedWork() async {
    var url = '${Config.url}/user/profile/fetch-saved-works';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future profileAccountEdit(
      {required String name,
      required String age,
      required String profile_pic,
      required String user_type,
      required String email,
      required String profession_type,
      required String pincode,
      required String city,
      required List<String> knownLanguages,
      required List<String> workImages,
      required String gender,
      required String bio,
      required String experienced_years,
      required String charges,
      required String charge_type,
      required String userLatitude,
      required String userLongitude}) async {
    var url = '${Config.url}/user/profile/update';

    Map<String, dynamic> body = {
      "name": name,
      "age": age,
      "profile_pic": profile_pic,
      "email": email,
      "user_type": user_type,
      "profession_type": profession_type,
      "pincode": pincode,
      "city": city,
      "gender": gender,
      "known_languages": knownLanguages,
      "work_images": workImages,
      "bio": bio,
      "experienced_years": experienced_years,
      "charges": charges,
      "charge_type": charge_type,
      "userLatitude": userLatitude,
      "userLongitude": userLongitude
    };
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );

    customLog("Response Status Code : ${response.statusCode}");
    customLog('Response body:${response.body.toString()}');

    return response;
  }

  Future fetchPostedView({required String workId}) async {
    var url = '${Config.url}/user/profile/fetch-work?id=$workId';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog('Response body:${response.body.toString()}');
    return response;
  }

  Future accountDelete({required String reason}) async {
    var url = '${Config.url}/user/profile/delete-account';
    Map<String, dynamic> body = {"reason": reason};
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog('Response body:${response.body.toString()}');
    return response;
  }

  Future notificationSetting({
    required bool workPostedInCity,
    required bool workViewedIntrestShowed,
    required bool friendRequest,
    required bool newClipsFromFriends,
    required bool newFriendSuggestions,
    required bool msgRecevied,
    required bool cmtOrLikeOnYourPost,
    required bool groupAlert,
  }) async {
    var url = '${Config.url}/user/profile/notification-settings';

    Map<String, dynamic> body = {
      "work_posted_in_city": workPostedInCity,
      "work_viewed_intrest_showed": workViewedIntrestShowed,
      "friend_request": friendRequest,
      "new_clips_from_friends": newClipsFromFriends,
      "new_friend_suggestions": newFriendSuggestions,
      "msg_recevied": msgRecevied,
      "cmt_or_like_on_your_post": cmtOrLikeOnYourPost,
      "group_alert": groupAlert,
    };

    final response = await http.post(
        Uri.parse(url),
        headers: Config.authHeaders(),
        body: jsonEncode(body));
    return response;
  }

  Future fetchFaq() async {
    var url = '${Config.url}/user/profile/faqs';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response body : ${response.body}");

    return response;
  }

  Future contactUs({
    required String name,
    required String email,
    required String mobile,
    required String message,
  }) async {
    var url = '${Config.url}/user/profile/support';

    Map<String, dynamic> body = {
      "name": name,
      "email": email,
      "mobile": mobile,
      "message": message,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    return response;
  }

  Future fetchSetting() async {
    var url = '${Config.url}/user/profile/fetch-notification-settings';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response body : ${response.body}");

    return response;
  }

  Future fetchSavedProfessional() async {
    var url = '${Config.url}/user/profile/fetch-saved-professionals';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response body : ${response.body}");

    return response;
  }



}
