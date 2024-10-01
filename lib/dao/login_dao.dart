import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../components/config.dart';
import 'package:http_parser/http_parser.dart';
import '../helper/custom_log.dart';

class LoginDao {
  Future login(
      {required String countryCode, required String phoneNumber}) async {
    var url = '${Config.url}/user/auth/send-otp';

    print("----------_Dao 1-----------");
    Map<String, dynamic> body = {
      "country_code": countryCode,
      "mobile": phoneNumber
    };

    print("----------Dao 2-----------");

    final response = await http.post(Uri.parse(url),
        headers: Config.headers(), body: jsonEncode(body));

    print("----------Dao 3-----------");

    customLog("Response Status Code : ${response.statusCode}");
    customLog("Response body : ${response.body}");

    print("----------Dao 4-----------");

    return response;
  }

  Future verifyOtp({required String otp, required String otpToken}) async {
    var url = '${Config.url}/user/auth/verify-otp';
    Map<String, dynamic> body = {"otp_token": otpToken, "otp": otp};

    final response = await http.post(
      Uri.parse(url),
      headers: Config.headers(),
      body: jsonEncode(body),
    );

    customLog("Response Status Code : ${response.statusCode}");

    return response;
  }

  Future resendOtp({required String otpToken}) async {
    var url = '${Config.url}/user/auth/resend-otp';

    Map<String, dynamic> body = {"otp_token": otpToken};

    final response = await http.post(
      Uri.parse(url),
      headers: Config.headers(),
      body: jsonEncode(body),
    );

    customLog("Response Status Code : ${response.statusCode}");

    return response;
  }

  Future uploadProfilePic({required File imagePath}) async {
    var url = '${Config.url}/user/profile/upload-image';

    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: "multipart/form-data",
        HttpHeaders.authorizationHeader: "Bearer ${Config.accessToken}",
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await File.fromUri(Uri.parse(imagePath.path)).readAsBytes(),
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

  Future registerAccount(
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
    var url = '${Config.url}/user/profile/register';

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
}
