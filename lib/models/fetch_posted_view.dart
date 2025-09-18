

import 'dart:convert';

import 'package:works_app/models/fetch_profile_model.dart';




ViewFetchPostedWork viewFetchPostedWorkFromJson(String str) => ViewFetchPostedWork.fromJson(json.decode(str));

String viewFetchPostedWorkToJson(ViewFetchPostedWork data) => json.encode(data.toJson());

class ViewFetchPostedWork {
  String? id;
  String? userId;
  String? requiredProfession;
  String ?experienceLevel;
  String? gender;
  List<String>? knowLanguage;
  String? location;
  String? workPlace;
  List<String>? workImages;
  bool? isProfessionalCanCall;
  String? latitude;
  String? longitude;
  String? description;
  bool? isVerified;
  // DateTime? createdAt;
  // DateTime? updatedAt;
  // dynamic? deletedAt;
  List<WorkViewDetails>? workIntrestsDetailsView;
  List<WorkViewDetails>? workViewsDetailsView;
  ProfessionalSubCategory? professionalSubCategory;
  ProfessionalSubCategory? workPlaceCategory;

  ViewFetchPostedWork({
    this.id,
    this.userId,
    this.requiredProfession,
    this.experienceLevel,
    this.gender,
    this.knowLanguage,
    this.location,
    this.workPlace,
    this.workImages,
    this.isProfessionalCanCall,
    this.latitude,
    this.longitude,
    this.description,
    this.isVerified,
    // this.createdAt,
    // this.updatedAt,
    // this.deletedAt,
    this.workIntrestsDetailsView,
    this.workViewsDetailsView,
    this.professionalSubCategory,
    this.workPlaceCategory
  });

  factory ViewFetchPostedWork.fromJson(Map<String, dynamic> json) => ViewFetchPostedWork(
    id: json["id"] ?? "",  // Default to an empty string if null
    userId: json["userId"] ?? "",
    requiredProfession: json["required_profession"] ?? "",
    experienceLevel: json["experience_level"] ?? "",
    gender: json["gender"] ?? "",
    knowLanguage: json["know_language"] != null ? List<String>.from(json["know_language"].map((x) => x)) : [],  // Handle null safely
    location: json["location"] ?? "",
    workPlace: json["work_place"] ?? "",
    workImages: json["work_images"] != null ? List<String>.from(json["work_images"].map((x) => x)) : [],
    isProfessionalCanCall: json["is_professional_can_call"] ?? false,
    latitude: json["latitude"] ?? "",
    longitude: json["longitude"] ?? "",
    description: json["description"] ?? "",
    isVerified: json["is_verified"] ?? false,
    workIntrestsDetailsView: json.containsKey('workIntrests')?json["workIntrests"] != null ? List<WorkViewDetails>.from(json["workIntrests"].map((x) => WorkViewDetails.fromJson(x))) : null:null,
    workViewsDetailsView: json.containsKey('workViews')?json["workViews"] != null ? List<WorkViewDetails>.from(json["workViews"].map((x) => WorkViewDetails.fromJson(x))) : null:[],
    professionalSubCategory: json["professionalSubCategory"] != null?
    ProfessionalSubCategory.fromJson(json["professionalSubCategory"]):null,
    workPlaceCategory: json.containsKey("workPlace")?json["workPlace"] == null ? null : ProfessionalSubCategory.fromJson(json["workPlace"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "required_profession": requiredProfession,
    "experience_level": experienceLevel,
    "gender": gender,
    "know_language": List<dynamic>.from(knowLanguage!.map((x) => x)),
    "location": location,
    "work_place": workPlace,
    "work_images": List<dynamic>.from(workImages!.map((x) => x)),
    "is_professional_can_call": isProfessionalCanCall,
    "latitude": latitude,
    "longitude": longitude,
    "description": description,
    "is_verified": isVerified,
    // "createdAt": createdAt!.toIso8601String(),
    // "updatedAt": updatedAt!.toIso8601String(),
    // "deletedAt": deletedAt,
    "workIntrests": List<dynamic>.from(workIntrestsDetailsView!.map((x) => x.toJson())),
    "workViews": List<dynamic>.from(workViewsDetailsView!.map((x) => x.toJson())),
    "professionalSubCategory": professionalSubCategory!.toJson(),
    "workPlace": workPlaceCategory!.toJson(),
  };

}

class WorkViewDetails {
  String? id;
  String? userId;
  String? workId;
  bool? isContacted;
  // DateTime? createdAt;
  // DateTime? updatedAt;
  User? user;


  WorkViewDetails({
    this.id,
    this.userId,
    this.workId,
    // this.createdAt,
    // this.updatedAt,
    this.isContacted,
     this.user,

  });

  factory WorkViewDetails.fromJson(Map<String, dynamic> json) => WorkViewDetails(
    id: json.containsKey('id')?json["id"] ?? "":"",  // Default to an empty string if null
    userId: json.containsKey('userId')?json["userId"] ?? "":"",
    workId: json.containsKey('workId')?json["workId"] ?? "":"",
    isContacted: json.containsKey('is_contacted')?json["is_contacted"] ?? false:false,  // Default to false if null
    user: json.containsKey('user')?json["user"] != null ? User.fromJson(json["user"]) : null:null,
  );


  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "workId": workId,
    "is_contacted": isContacted,
    // "createdAt": createdAt!.toIso8601String(),
    // "updatedAt": updatedAt!.toIso8601String(),
    "user": user!.toJson(),
  };
}

class User {
  String? id;
  // String? countryCode;
  String? mobile;
  String? name;
  // String? email;
  String? profilePic;
  // String? bio;
  String? userType;
  String? professionType;
  int? pincode;
  String? city;
  String? experiencedYears;
  List<String>? knownLanguages;
  String? gender;
  // int? age;
  // dynamic fcmToken;
  // bool? isRegistered;
  // List<String>? workImages;
  String? charges;
  String? chargeType;
  // String? userLatitude;
  // String? userLongitude;
  // dynamic defaultLanguage;
  bool? isVerified;
  // DateTime? createdAt;
  // DateTime? updatedAt;
  // dynamic deletedAt;
  IsContacted?isSaved;
  IsContacted? isContacted;
  String? smartCallControl;
  List<SmartCallSchedule>? smartCallSchedule;
  ProfessionalSubCategory? professionalSubCategory;

  User({
    this.id,
    // this.countryCode,
    this.mobile,
    this.name,
    // this.email,
    this.profilePic,
    // this.bio,
    this.userType,
    this.professionType,
    this.pincode,
    this.city,
    this.experiencedYears,
    this.knownLanguages,
    this.gender,
    // this.age,
    // this.fcmToken,
    // this.isRegistered,
    // this.workImages,
    this.charges,
    this.chargeType,
    // this.userLatitude,
    // this.userLongitude,
    // this.defaultLanguage,
    this.isVerified,
    // this.createdAt,
    // this.updatedAt,
    // this.deletedAt,
    this.isSaved,
    this.isContacted,
    this.smartCallControl,
    this.smartCallSchedule,
    this.professionalSubCategory,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json.containsKey('id') ? json["id"]??"" : "",
    name: json.containsKey('name') ? json["name"]??"" : "",
    mobile: json.containsKey('mobile') ? json["mobile"]??"" : "",
    profilePic: json.containsKey('profile_pic') ? json["profile_pic"]??"" : "",
    userType: json.containsKey('user_type') ? json["user_type"]??"" : "",
    professionType: json.containsKey('profession_type') ? json["profession_type"] ??"": "",
    pincode: json.containsKey('pincode') ? json["pincode"]??"" : "",
    city: json.containsKey('city') ? json["city"] ?? "" : "",
    experiencedYears: json.containsKey('experienced_years') ? json["experienced_years"]??"" : "",
    knownLanguages: json.containsKey('known_languages') && json['known_languages'] != null
        ? List<String>.from(json["known_languages"].map((x) => x))
        : [],
    gender: json.containsKey('gender') ? json["gender"]??"" : "",
    charges: json.containsKey('charges') ? json["charges"]??"" : "",
    chargeType: json.containsKey('charge_type') ? json["charge_type"]??"" : "",
    isVerified: json.containsKey('is_verified') ? json["is_verified"]??false : false,
    isSaved: json["isSaved"] != null
        ? IsContacted.fromJson(json["isSaved"])
        : null,
    isContacted: json["isContacted"] != null
        ? IsContacted.fromJson(json["isContacted"])
        : null,
    smartCallControl: json.containsKey('smart_call_control')
        ? json["smart_call_control"] ?? ""
        : "",
    smartCallSchedule: json["smart_call_schedule"] != null
        ? List<SmartCallSchedule>.from(
        (json["smart_call_schedule"] as List).map((x) => SmartCallSchedule.fromJson(x)))
        : null,
    professionalSubCategory: json["professionalSubCategory"] != null?
    ProfessionalSubCategory.fromJson(json["professionalSubCategory"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_pic": profilePic,
    "user_type": userType,
    "profession_type": professionType,
    "pincode": pincode,
    "city": city,
    "experienced_years": experiencedYears,
    "known_languages": List<dynamic>.from(knownLanguages!.map((x) => x)),
    "gender": gender,
    "charges": charges,
    "charge_type": chargeType,
    "is_verified": isVerified,
    "mobile":mobile,
    "isSaved":isSaved,
    "isContacted": isContacted?.toJson(),
    "smart_call_control": smartCallControl,
    "smart_call_schedule": smartCallSchedule?.map((x) => x.toJson()).toList(),
    "professionalSubCategory": professionalSubCategory!.toJson(),
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
  String? place;


  ProfessionalSubCategory({
    this.id,
    this.name,
    this.categoryId,
    this.translation,
    this.place

  });

  factory ProfessionalSubCategory.fromJson(Map<String, dynamic> json) => ProfessionalSubCategory(
    id: json["id"],
    name: json["name"],
    place: json["place"],
    categoryId: json["category_id"],
    translation: json.containsKey('translation')?json["translation"] == null ? null : Translation.fromJson(json["translation"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "place":place,
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