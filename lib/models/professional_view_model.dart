

import 'dart:convert';

import 'fetch_profile_model.dart';

ProfessionalViewModel professionalViewModelFromJson(String str) => ProfessionalViewModel.fromJson(json.decode(str));

String professionalViewModelToJson(ProfessionalViewModel data) => json.encode(data.toJson());

class ProfessionalViewModel {
  Professional? professional;
  List<Professional>? similarProfessionals;

  ProfessionalViewModel({
    this.professional,
    this.similarProfessionals,
  });

  factory ProfessionalViewModel.fromJson(Map<String, dynamic> json) => ProfessionalViewModel(
    professional: json.containsKey("professional") ? json["professional"] == null ? null :  Professional.fromJson(json["professional"]) : null,
    similarProfessionals:json.containsKey("SimilarProfessionals") ? json["SimilarProfessionals"] == null ? null : List<Professional>.from(json["SimilarProfessionals"].map((x) => Professional.fromJson(x))):null,
  );

  Map<String, dynamic> toJson() => {
    "professional": professional!.toJson(),
    "SimilarProfessionals": List<dynamic>.from(similarProfessionals!.map((x) => x.toJson())),
  };
}

class Professional {
  String? id;
  String? countryCode;
  String? mobile;
  String? name;
  String? email;
  String? profilePic;
  String? bio;
  String? userType;
  String? professionType;
  String? pincode;
  String? city;
  String? experiencedYears;
  List<String>? knownLanguages;
  String? gender;
  String? age;
  bool? isRegistered;
  List<String>? workImages;
  String? charges;
  String? chargeType;
  String? userLatitude;
  String? userLongitude;
  bool? isVerified;
  IsContacted?isSaved;
  IsContacted? isContacted;
  IsFriend? isFriend;
  FriendRequestSent? friendRequestSent;
  List<SmartCallSchedule>? smartCallSchedule;
  String? smartCallControl;
  ProfessionalSubCategory? professionalSubCategory;


  Professional({
    this.id,
    this.countryCode,
    this.mobile,
    this.name,
    this.email,
    this.profilePic,
    this.bio,
    this.userType,
    this.professionType,
    this.pincode,
    this.city,
    this.experiencedYears,
    this.knownLanguages,
    this.gender,
    this.age,
    this.isRegistered,
    this.workImages,
    this.charges,
    this.chargeType,
    this.userLatitude,
    this.userLongitude,
    this.isVerified,
    this.isSaved,
    this.isContacted,
    this.isFriend,
    this.friendRequestSent,
    this.smartCallSchedule,
    this.smartCallControl,
    this.professionalSubCategory,
  });

  factory Professional.fromJson(Map<String, dynamic> json) => Professional(
    id: json["id"]??"",
    countryCode: json["country_code"]??"",
    mobile: json["mobile"]??"",
    name: json["name"]??"",
    email: json["email"]??"",
    profilePic: json["profile_pic"]??"",
    bio: json["bio"]??"",
    userType: json["user_type"]??"",
    professionType: json["profession_type"]??"",
    pincode: json["pincode"] != null?json["pincode"]?.toString()??"":"",
    city: json["city"]??"",
    experiencedYears: json["experienced_years"]??"",
    knownLanguages: json["known_languages"] != null
        ? List<String>.from(json["known_languages"].map((x) => x))
        : [],
    gender: json["gender"]??"",
    age: json["age"] != null?json["age"]?.toString()??"":"",
    isRegistered: json["is_registered"],
    workImages:   json["work_images"] != null
        ? List<String>.from(json["work_images"].map((x) => x))
        : [],
    charges: json["charges"]??"",
    chargeType: json["charge_type"]??"",
    userLatitude: json["userLatitude"]??"",
    userLongitude: json["userLongitude"]??"",
    isVerified: json["is_verified"],
    isSaved: json["isSaved"] != null
        ? IsContacted.fromJson(json["isSaved"])
        : null,
    isContacted: json["isContacted"] != null
        ? IsContacted.fromJson(json["isContacted"])
        : null,
    isFriend: json["isFriend"] != null
        ? IsFriend.fromJson(json["isFriend"]):null,
    friendRequestSent: json.containsKey('friendRequestSent') && json['friendRequestSent'] != null
        ?FriendRequestSent.fromJson(json["friendRequestSent"])
        : null,
    smartCallControl: json.containsKey("smart_call_control")?json["smart_call_control"]??null:null,
    smartCallSchedule: json["smart_call_schedule"] != null
        ? List<SmartCallSchedule>.from(
        (json["smart_call_schedule"] as List).map((x) => SmartCallSchedule.fromJson(x)))
        : null,
    professionalSubCategory: json["professionalSubCategory"] != null?
    ProfessionalSubCategory.fromJson(json["professionalSubCategory"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "country_code": countryCode,
    "mobile": mobile,
    "name": name,
    "email": email,
    "profile_pic": profilePic,
    "bio": bio,
    "user_type": userType,
    "profession_type": professionType,
    "pincode": pincode,
    "city": city,
    "experienced_years": experiencedYears,
    "known_languages": List<dynamic>.from(knownLanguages!.map((x) => x)),
    "gender": gender,
    "age": age,
    "is_registered": isRegistered,
    "work_images": List<dynamic>.from(workImages!.map((x) => x)),
    "charges": charges,
    "charge_type": chargeType,
    "userLatitude": userLatitude,
    "userLongitude": userLongitude,
    "is_verified": isVerified,
    "isSaved":isSaved,
    "isContacted": isContacted?.toJson(),
    "isFriend": isFriend?.toJson(),
    "friendRequestSent": friendRequestSent?.toJson(),
    "smart_call_control":smartCallControl,
    "smart_call_control": smartCallControl,
    "smart_call_schedule": smartCallSchedule?.map((x) => x.toJson()).toList(),
    "professionalSubCategory": professionalSubCategory!.toJson(),
  };

}

class IsFriend {
  String id;
  String userId;
  String friendId;

  IsFriend({
    required this.id,
    required this.userId,
    required this.friendId,
  });

  factory IsFriend.fromJson(Map<String, dynamic> json) => IsFriend(
    id: json["id"]??"",
    userId: json["userId"]??"",
    friendId: json["friendId"]??"",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "friendId": friendId,
  };
}

class FriendRequestSent {
  String? id;
  String? userId;
  String? senderId;
  String? friendId;

  FriendRequestSent({
    this.id,
    this.userId,
    this.senderId,
    this.friendId,
  });

  factory FriendRequestSent.fromJson(Map<String, dynamic> json) => FriendRequestSent(
    id: json["id"],
    userId: json["userId"],
    senderId: json["senderId"],
    friendId: json["friendId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "senderId": senderId,
    "friendId": friendId,
  };
}

class IsContacted {
  String? id;
  String? userId;
  String? professionalId;

  IsContacted({
    this.id,
    this.userId,
    this.professionalId,
  });

  factory IsContacted.fromJson(Map<String, dynamic> json) => IsContacted(
    id: json["id"],
    userId: json["userId"],
    professionalId: json["professionalId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "professionalId": professionalId,
  };
}

class ProfessionalSubCategory {
  String? id;
  String? name;
  String? categoryId;
  Translation? translation;


  ProfessionalSubCategory({
    this.id,
    this.name,
    this.categoryId,
    this.translation,

  });

  factory ProfessionalSubCategory.fromJson(Map<String, dynamic> json) => ProfessionalSubCategory(
    id: json["id"],
    name: json["name"],
    categoryId: json["category_id"],
    translation: json["translation"] != null?Translation.fromJson(json["translation"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "category_id": categoryId,
    "translation": translation!.toJson(),
  };
}

class Translation {
  String? hindi;
  String? tamil;
  String ?telugu;
  String ?kannada;
  String? marathi;
  String? gujarati;
  String? malayalam;

  Translation({
    this.hindi,
    this.tamil,
    this.telugu,
    this.kannada,
    this.marathi,
    this.gujarati,
    this.malayalam,
  });

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
    hindi: json["hindi"],
    tamil: json["tamil"],
    telugu: json["telugu"],
    kannada: json["kannada"],
    marathi: json["marathi"],
    gujarati: json["gujarati"],
    malayalam: json["malayalam"],
  );

  Map<String, dynamic> toJson() => {
    "hindi": hindi,
    "tamil": tamil,
    "telugu": telugu,
    "kannada": kannada,
    "marathi": marathi,
    "gujarati": gujarati,
    "malayalam": malayalam,
  };
}
