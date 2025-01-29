import 'dart:convert';

import 'package:http/http.dart' as http;
import '../components/config.dart';
import '../helper/custom_log.dart';

class FriendsDao {
  Future fetchFriendsSearchList({
    required int page,
    required int pageSize,
    required String keyWord,
  }) async {
    var url =
        '${Config.url}/user/friend/list?page=$page&page_size=$pageSize&search=$keyWord';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future fetchFriendsView({
    required String id,
  }) async {
    var url = '${Config.url}/user/friend/view?id=$id';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code view : ${response.statusCode}");
    return response;
  }

  Future addFriends({
    required String userId,
  }) async {
    var url = '${Config.url}/user/friend/add';
    Map<String, dynamic> body = {"userId": userId};
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future acceptRequestFriend({
    required String id,
  }) async {
    var url = '${Config.url}/user/friend/accept-request';
    Map<String, dynamic> body = {"id": id};
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future rejectRequestFriends({
    required String id,
  }) async {
    var url = '${Config.url}/user/friend/reject-request';
    Map<String, dynamic> body = {"id": id};
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future unfriends({
    required String friendId,
  }) async {
    var url = '${Config.url}/user/friend/unfriend';
    Map<String, dynamic> body = {"friendId": friendId};
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }
}
