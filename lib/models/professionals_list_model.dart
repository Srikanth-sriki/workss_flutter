

import 'dart:convert';

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

