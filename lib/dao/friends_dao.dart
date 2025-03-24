import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../components/config.dart';
import 'package:http_parser/http_parser.dart';
import '../global_helper/helper_function.dart';
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

  Future fetchAddFriendsChatSearchList({
    required int page,
    required int pageSize,
    required String keyWord,
  }) async {
    var url = '${Config.url}/user/friend/search?search=$keyWord';
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

  Future fetchFriendsRequestList({
    required int page,
    required int pageSize,
    required String keyWord,
  }) async {
    var url =
        '${Config.url}/user/friend/request-list?page=$page&page_size=$pageSize&search=$keyWord';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future fetchChartList() async {
    var url = '${Config.url}/user/chat/list';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future fetchArchivedChartList() async {
    var url = '${Config.url}/user/chat/archive-list';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future createGroupChat({
    required String picture,
    required String name,
    required String description,
    required List<dynamic> invitedUsers,
  }) async {
    var url = '${Config.url}/user/chat/create-group';
    Map<String, dynamic> body = {
      "picture": picture,
      "name": name,
      "description": description,
      "invitedUsers": invitedUsers,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    customLog("Response Status Code : ${response.request}");
    return response;
  }

  Future fetchInviteMemberList({
    required int page,
    required int pageSize,
    required String groupId,
    required String keyWord,
  }) async {
    var url =
        '${Config.url}/user/chat/invite-people?chatId=$groupId&search=$keyWord&page=$page&page_size=$pageSize';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future fetchChatView({
    required int page,
    required int pageSize,
    required String chatId,
  }) async {
    var url =
        '${Config.url}/user/chat/view?chatId=$chatId&page=$page&page_size=$pageSize';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future sendMessageChat({
    required String chatId,
    required String content,
    required String messageType,
    String? fileName,
    String? fileUrl,
    String? fileType,
    String? fileSize,
  }) async {
    Map<String, dynamic> body = {
      "chatId": chatId,
      "content": content,
      "messageType": messageType,
      "mediaFiles": [
        {
          "fileName": fileName,
          "fileUrl": fileUrl,
          "fileType": fileType,
          "fileSize": fileSize,
        }
      ],
    };
    var url = '${Config.url}/user/chat/send-message';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog(body);
    return response;
  }

  Future uploadFile({required File imagePath}) async {
    var url = '${Config.url}/user/chat/upload-file';

    try {
      File? compressedImage = await compressImage(imagePath);
      if (compressedImage == null) {
        customLog("Image compression failed");
        return;
      }

      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: "multipart/form-data",
        HttpHeaders.authorizationHeader: "Bearer ${Config.accessToken}",
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await compressedImage.readAsBytes(),
          filename: 'image.mp3',
          contentType: MediaType('mp3', 'mp4'),
        ),
      );

      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      customLog('Response status:${response.statusCode}');
      customLog('Response body of upload:${response.body.toString()}');

      return response;
    } catch (error) {
      customLog("The error of Upload Mci : $error");
    }
  }

  Future editGroupChat({
    required String chatId,
    required String picture,
    required String description,
    required String name,
  }) async {
    Map<String, dynamic> body = {
      "id": chatId,
      "name": name,
      "description": description,
      "picture": picture
    };
    var url = '${Config.url}/user/chat/edit-group';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog(body);
    return response;
  }

  Future fetchChatViewProfile({
    required String chatId,
  }) async {
    var url = '${Config.url}/user/chat/details?chatId=$chatId';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future inviteMemberRequest({
    required String chatId,
    required List<String> invitedUsers,
  }) async {
    Map<String, dynamic> body = {
      "chatId": chatId,
      "invitedUsers": invitedUsers,
    };
    var url = '${Config.url}/user/chat/invite';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog(body);
    return response;
  }

  Future removeMemberRequest({
    required String chatId,
    required List<String> removedUsers,
  }) async {
    Map<String, dynamic> body = {
      "chatId": chatId,
      "removingUsers": removedUsers,
    };
    var url = '${Config.url}/user/chat/remove-members';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog(body);
    return response;
  }

  Future clearChatRequest({
    required String chatId,
  }) async {
    Map<String, dynamic> body = {"chatId": chatId};
    var url = '${Config.url}/user/chat/clear-chat';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future archiveChatRequest({
    required String chatId,
  }) async {
    Map<String, dynamic> body = {
      "chatId": chatId
    };
    var url = '${Config.url}/user/chat/archive';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future leaveChatRequest({
    required String chatId,
  }) async {
    Map<String, dynamic> body = {
      "chatId": chatId
    };
    var url = '${Config.url}/user/chat/leave-group';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future acceptInviteGroup({
    required String chatId,
  }) async {
    Map<String, dynamic> body = {
      "id": chatId
    };
    var url = '${Config.url}/user/chat/accept-invite';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future rejectInviteGroup({
    required String chatId,
  }) async {
    Map<String, dynamic> body = {
      "id": chatId
    };
    var url = '${Config.url}/user/chat/reject-invite';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future sendChatMessage({
    required String chatId,
  }) async {
    Map<String, dynamic> body = {
      "userId": chatId
    };
    var url = '${Config.url}/user/chat/start-chat';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }


  Future deleteGroupChart({
    required String chatId,
  }) async {
    Map<String, dynamic> body = {
      "chatId": chatId
    };
    var url = '${Config.url}/user/chat/delete-group';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }


  Future cancelInviteGroupChart({
    required String id,
  }) async {
    Map<String, dynamic> body = {
      "id": id
    };
    var url = '${Config.url}/user/chat/cancel-invite';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future markAsAdminRequest({
    required String chatId,
    required List<String> userIds,
  }) async {
    Map<String, dynamic> body = {
      "chatId": chatId,
      "userIds": userIds,
    };
    var url = '${Config.url}/user/chat/mark-admin';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog(body);
    return response;
  }

  Future unArchiveChatRequest({
    required String chatId,
  }) async {
    Map<String, dynamic> body = {
      "chatId": chatId
    };
    var url = '${Config.url}/user/chat/unarchive';
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }



}
