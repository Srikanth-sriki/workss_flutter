import 'package:shared_preferences/shared_preferences.dart';

class LocalConstant {
  static String phoneNumber = "phoneNumber";
  static String countryCode = "countryCode";
  static String accessToken = "AccessToken";
  static String userId = "userId";
  static String profileCompleted = "profileCompleted";
  static String name = "name";
  static String profilePicture = "profilePicture";
  static String intoChecked = "intoChecked";
  static String initialLanguage = "initialLanguage";
  static String userType = "userType";
}

storeToLocalStorage(dynamic key, dynamic value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}