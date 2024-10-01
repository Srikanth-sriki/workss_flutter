import 'dart:convert';

import 'package:http/http.dart' as http;
import '../components/config.dart';
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
    return response;
  }
}
