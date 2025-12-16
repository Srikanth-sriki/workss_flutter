import '../core/storage_service.dart';

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
  static String localLanguageSelected = "localLanguageSelected";
  static String refreshToken = "RefreshToken";
}

storeToLocalStorage(dynamic key, dynamic value) async {
  await StorageService.setString(key, value);
}
