

import 'dart:convert';




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
    workIntrestsDetailsView: json["workIntrests"] != null ? List<WorkViewDetails>.from(json["workIntrests"].map((x) => WorkViewDetails.fromJson(x))) : null,
    workViewsDetailsView: json["workViews"] != null ? List<WorkViewDetails>.from(json["workViews"].map((x) => WorkViewDetails.fromJson(x))) : null,
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
    user: json.containsKey('"user')?json["user"] != null ? User.fromJson(json["user"]) : null:null,  // Handle null case
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
  String? countryCode;
  String? mobile;
  String? name;
  String? email;
  String? profilePic;
  String? bio;
  String? userType;
  String? professionType;
  int? pincode;
  String? city;
  String? experiencedYears;
  List<String>? knownLanguages;
  String? gender;
  // int? age;
  // dynamic fcmToken;
  bool? isRegistered;
  List<String>? workImages;
  String? charges;
  String? chargeType;
  // String? userLatitude;
  // String? userLongitude;
  // dynamic defaultLanguage;
  bool? isVerified;
  // DateTime? createdAt;
  // DateTime? updatedAt;
  // dynamic deletedAt;

  User({
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
    // this.age,
    // this.fcmToken,
    this.isRegistered,
    this.workImages,
    this.charges,
    this.chargeType,
    // this.userLatitude,
    // this.userLongitude,
    // this.defaultLanguage,
    this.isVerified,
    // this.createdAt,
    // this.updatedAt,
    // this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json.containsKey('id') ? json["id"] : "",
    countryCode: json.containsKey('country_code') ? json["country_code"] : "",
    mobile: json.containsKey('mobile') ? json["mobile"] : "",
    name: json.containsKey('name') ? json["name"] : "",
    email: json.containsKey('email') ? json["email"] : "",
    profilePic: json.containsKey('profile_pic') ? json["profile_pic"] : "",
    bio: json.containsKey('bio') ? json["bio"] : "",
    userType: json.containsKey('user_type') ? json["user_type"] : "",
    professionType: json.containsKey('profession_type') ? json["profession_type"] : "",
    pincode: json.containsKey('pincode') ? json["pincode"] : "",
    city: json.containsKey('city') ? json["city"] : "",
    experiencedYears: json.containsKey('experienced_years') ? json["experienced_years"] : "",
    knownLanguages: json.containsKey('known_languages') && json['known_languages'] != null
        ? List<String>.from(json["known_languages"].map((x) => x))
        : [],
    gender: json.containsKey('gender') ? json["gender"] : "",
    isRegistered: json.containsKey('is_registered') ? json["is_registered"] : false,
    workImages: json.containsKey('work_images') && json["work_images"] != null
        ? List<String>.from(json["work_images"].map((x) => x))
        : [],
    charges: json.containsKey('charges') ? json["charges"] : "",
    chargeType: json.containsKey('charge_type') ? json["charge_type"] : "",
    isVerified: json.containsKey('is_verified') ? json["is_verified"] : "",
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
    // "age": age,
    // "fcm_token": fcmToken,
    "is_registered": isRegistered,
    "work_images": List<dynamic>.from(workImages!.map((x) => x)),
    "charges": charges,
    "charge_type": chargeType,
    // "userLatitude": userLatitude,
    // "userLongitude": userLongitude,
    // "default_language": defaultLanguage,
    "is_verified": isVerified,
    // "createdAt": createdAt!.toIso8601String(),
    // "updatedAt": updatedAt!.toIso8601String(),
    // "deletedAt": deletedAt,
  };
}
