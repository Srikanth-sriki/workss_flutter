

import 'dart:convert';

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
