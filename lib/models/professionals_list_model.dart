

import 'dart:convert';

import 'fetch_profile_model.dart';

List<ProfessionalsPostedWork> professionalsPostedWorkFromJson(String str) => List<ProfessionalsPostedWork>.from(json.decode(str).map((x) => ProfessionalsPostedWork.fromJson(x)));

String professionalsPostedWorkToJson(List<ProfessionalsPostedWork> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProfessionalsPostedWork {
  String? id;
  String? mobile;
  String? name;
  String? profilePic;
  String? userType;
  String? professionType;
  String? city;
  String? experiencedYears;
  List<String>? knownLanguages;
  String? gender;
  bool? isRegistered;
  List<String>? workImages;
  String? charges;
  String? chargeType;
  bool? isVerified;
  IsContacted?isSaved;
  IsContacted? isContacted;
  List<SmartCallSchedule>? smartCallSchedule;
  String? smartCallControl;
  ProfessionalSubCategory? professionalSubCategory;

  ProfessionalsPostedWork({
    this.id,
    this.mobile,
    this.name,
    this.profilePic,
    this.userType,
    this.professionType,
    this.city,
    this.experiencedYears,
    this.knownLanguages,
    this.gender,
    this.isRegistered,
    this.workImages,
    this.charges,
    this.chargeType,
    this.isVerified,
    this.isSaved,
    this.isContacted,
    this.smartCallSchedule,
    this.smartCallControl,
    this.professionalSubCategory,
  });

  factory ProfessionalsPostedWork.fromJson(Map<String, dynamic> json) => ProfessionalsPostedWork(
    id: json["id"],
    mobile: json["mobile"],
    name: json["name"],
    profilePic: json["profile_pic"],
    userType: json["user_type"],
    professionType: json["profession_type"],
    city: json["city"],
    experiencedYears: json["experienced_years"],
    knownLanguages: json["known_languages"] != null
        ? List<String>.from(json["known_languages"].map((x) => x))
        : [],
    gender: json["gender"],
    isRegistered: json["is_registered"],
    workImages: json["work_images"] != null
        ? List<String>.from(json["work_images"].map((x) => x))
        : [],
    charges: json["charges"],
    chargeType: json["charge_type"],
    isVerified: json["is_verified"],
    isSaved: json["isSaved"] != null
        ? IsContacted.fromJson(json["isSaved"])
        : null,
    isContacted: json["isContacted"] != null
        ? IsContacted.fromJson(json["isContacted"])
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
    "mobile": mobile,
    "name": name,
    "profile_pic": profilePic,
    "user_type": userType,
    "profession_type": professionType,
    "city": city,
    "experienced_years": experiencedYears,
    "known_languages": knownLanguages != null
        ? List<dynamic>.from(knownLanguages!.map((x) => x))
        : [],
    "gender": gender,
    "is_registered": isRegistered,
    "work_images": workImages != null
        ? List<dynamic>.from(workImages!.map((x) => x))
        : [],
    "charges": charges,
    "charge_type": chargeType,
    "is_verified": isVerified,
    "isSaved":isSaved,
    "isContacted": isContacted?.toJson(),
    "smart_call_control":smartCallControl,
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
    id: json["id"]??"",
    userId: json["userId"]??"",
    professionalId: json["professionalId"]??"",
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
