import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../components/config.dart';
import '../global_helper/helper_function.dart';
import '../helper/custom_log.dart';

class HomeDao {
  Future fetchHome(
      {required int page,
      required int pageSize,
      required String keyWord,
      required String profession,
      required String city,
      required String gender}) async {
    var url =
        '${Config.url}/user/home/fetch-works?search=$keyWord&profession=$profession&gender=$gender&city=$city&page=$page&page_size=$pageSize';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    return response;
  }

  Future saveInterested({
    required String workID,
    required bool contact,
  }) async {
    var url = '${Config.url}/user/home/show-intrest';
    Map<String, dynamic> body = {
      "work_id": workID,
      "is_contact": contact,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future postWork({
    required String requiredProfession,
    required String experienceLevel,
    required String gender,
    required List<String> knowLanguage,
    required String location,
    required String workPlace,
    required List<String> workImages,
    required bool isProfessionalCanCall,
    required String latitude,
    required String longitude,
    required String description,
  }) async {
    var url = '${Config.url}/user/work/post';

    Map<String, dynamic> body = {
      "required_profession": requiredProfession,
      "experience_level": experienceLevel,
      "gender": gender,
      "know_language": knowLanguage,
      "location": location,
      "work_place": workPlace,
      "work_images": workImages,
      "is_professional_can_call": isProfessionalCanCall,
      "latitude": latitude,
      "longitude": longitude,
      "description": description,
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

  // Future uploadWorksPic({required File imagePath}) async {
  //   var url = '${Config.url}/user/work/upload-image';
  //
  //   try {
  //     var request = http.MultipartRequest("POST", Uri.parse(url));
  //     request.headers.addAll({
  //       HttpHeaders.contentTypeHeader: "multipart/form-data",
  //       HttpHeaders.authorizationHeader: "Bearer ${Config.accessToken}",
  //     });
  //
  //     request.files.add(
  //       http.MultipartFile.fromBytes(
  //         'file',
  //         await File.fromUri(Uri.parse(imagePath.path)).readAsBytes(),
  //         filename: 'image.jpg',
  //         contentType: MediaType('image', 'jpg'),
  //       ),
  //     );
  //
  //     var streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //
  //     customLog('Response status:${response.statusCode}');
  //     customLog('Response body of upload:${response.body.toString()}');
  //
  //     return response;
  //   } catch (error) {
  //     customLog("The error of Upload Mci : $error");
  //   }
  // }
  //

  Future uploadWorksPic({required File imagePath}) async {
    var url = '${Config.url}/user/work/upload-image';

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
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpg'),
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

  Future editPostWork({
    required String workId,
    required String requiredProfession,
    required String experienceLevel,
    required String gender,
    required List<String> knowLanguage,
    required String location,
    required String workPlace,
    required List<String> workImages,
    required bool isProfessionalCanCall,
    required String latitude,
    required String longitude,
    required String description,
  }) async {
    var url = '${Config.url}/user/work/update-post';

    Map<String, dynamic> body = {
      "workId": workId,
      "required_profession": requiredProfession,
      "experience_level": experienceLevel,
      "gender": gender,
      "know_language": knowLanguage,
      "location": location,
      "work_place": workPlace,
      "work_images": workImages,
      "is_professional_can_call": isProfessionalCanCall,
      "latitude": latitude,
      "longitude": longitude,
      "description": description,
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

  Future postWorkDelete({required String workID}) async {
    var url = '${Config.url}/user/work/delete-post';
    Map<String, dynamic> body = {"workId": workID};
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future fetchProfessional(
      {required int page,
      required int pageSize,
      required String keyWord,
      required String profession,
      required String city,
      required String gender}) async {
    var url =
        '${Config.url}/user/professional/fetch-professionals?search=$keyWord&profession=$profession&gender=$gender&city=$city&page=$page&page_size=$pageSize';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future professionalContactUs({
    required String professionalId,
  }) async {
    var url = '${Config.url}/user/professional/contact';
    Map<String, dynamic> body = {"professional_id": professionalId};
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future professionalSavedUs({
    required String professionalId,
  }) async {
    var url = '${Config.url}/user/professional/save';
    Map<String, dynamic> body = {"professional_id": professionalId};
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future fetchProfessionalView({required String professionalId}) async {
    var url =
        '${Config.url}/user/professional/view-professional?id=$professionalId';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog('Response body:${response.body.toString()}');
    return response;
  }

  Future fetchWorkView({required String workId}) async {
    var url =
        '${Config.url}/user/home/view-work?work_id=$workId';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog('Response body:${response.body.toString()}');
    return response;
  }

  Future fetchNotificationListView() async {
    var url = '${Config.url}/user/notification/list';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog('Response body:${response.body.toString()}');
    return response;
  }

  Future fetchNotificationClearSingle({
    required String Id,
  }) async {
    var url = '${Config.url}/user/notification/clear';
    Map<String, dynamic> body = {"id": Id};
    final response = await http.post(
      Uri.parse(url),
      headers: Config.authHeaders(),
      body: jsonEncode(body),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response Status Code : ${response.body}");
    return response;
  }

  Future fetchNotificationClearAll() async {
    var url = '${Config.url}/user/notification/clear-all';
    final response = await http.get(
      Uri.parse(url),
      headers: Config.authHeaders(),
    );
    customLog("Response Status Code : ${response.statusCode}");
    customLog('Response body:${response.body.toString()}');
    return response;
  }
}
