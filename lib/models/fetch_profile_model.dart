import 'dart:convert';

ProfileFetch profileFetchFromJson(String str) => ProfileFetch.fromJson(json.decode(str));

String profileFetchToJson(ProfileFetch data) => json.encode(data.toJson());



class ProfileFetch {
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
  String ?city;
  String? experiencedYears;
  List<String>? knownLanguages;
  String ?gender;
  int? age;
  String? fcmToken;
  bool? isRegistered;
  bool?isVerified;
  List<String>? workImages;
  String ?charges;
  String ?chargeType;
  DateTime ?createdAt;
  DateTime ?updatedAt;
  String?kycStatus;
  List<SmartCallSchedule>? smartCallSchedule;
  String? smartCallControl;
  String?cityId;
  String?professionId;
  String?chargeId;
  // dynamic deletedAt;

  ProfileFetch({
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
     this.fcmToken,
     this.isRegistered,
     this.workImages,
     this.charges,
     this.chargeType,
     this.createdAt,
     this.updatedAt,
    this.isVerified,
    this.kycStatus,
    this.smartCallSchedule,
    this.smartCallControl,
    this.chargeId,
    this.cityId,
    this.professionId
    // required this.deletedAt,
  });

  factory ProfileFetch.fromJson(Map<String, dynamic> json) => ProfileFetch(
    id: json.containsKey("id")?json["id"]??null:null,
    countryCode: json.containsKey("country_code")?json["country_code"]??null:null,
    mobile: json.containsKey("mobile")?json["mobile"]??null:null,
    name: json.containsKey("name")?json["name"]??null:null,
    email: json.containsKey("email")?json["email"]??null:null,
    profilePic: json.containsKey("profile_pic")?json["profile_pic"]??'':null,
    bio: json.containsKey("bio")?json["bio"]??"":null,
    userType: json.containsKey("user_type")?json["user_type"]??null:null,
    professionType: json.containsKey("profession_type")?json["profession_type"]??null:null,
    pincode: json.containsKey("pincode")?json["pincode"]??null:null,
    city: json.containsKey("city")?json["city"]??null:null,
    experiencedYears: json.containsKey("experienced_years")?json["experienced_years"]??null:null,
    knownLanguages: json.containsKey("known_languages")?json["known_languages"] == null?null:List<String>.from(json["known_languages"].map((x) => x)):null,
    gender: json.containsKey("gender")?json["gender"]??null:null,
    age: json.containsKey("age")?json["age"]??null:null,
    fcmToken: json.containsKey("fcm_token")?json["fcm_token"]??null:null,
    isRegistered: json.containsKey("is_registered")?json["is_registered"]??false:false,
    isVerified:json.containsKey("is_verified")?json["is_verified"]??false:false,
    workImages: json.containsKey("work_images")?json["work_images"] == null?null:List<String>.from(json["work_images"].map((x) => x)):null,
    charges: json.containsKey("charges")?json["charges"]??null:null,
    chargeType: json.containsKey("charge_type")?json["charge_type"]??null:null,
    createdAt: json.containsKey("createdAt")?DateTime.parse(json["createdAt"])??null:null,
    updatedAt: json.containsKey("updatedAt")?DateTime.parse(json["updatedAt"])??null:null,
    kycStatus: json.containsKey("kyc_status")?json["kyc_status"]??null:null,
    smartCallControl: json.containsKey("smart_call_control")?json["smart_call_control"]??null:null,
    smartCallSchedule: json["smart_call_schedule"] != null
        ? List<SmartCallSchedule>.from(
        (json["smart_call_schedule"] as List).map((x) => SmartCallSchedule.fromJson(x)))
        : null,
    professionId: json.containsKey("prof_category_id")?json["prof_category_id"]??null:null,
    cityId: json.containsKey("city_id")?json["city_id"]??null:null,
    chargeId: json.containsKey("charge_type_id")?json["charge_type_id"]??null:null,
    // deletedAt: json["deletedAt"],
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
    "known_languages": List<String>.from(knownLanguages!.map((x) => x)),
    "gender": gender,
    "age": age,
    "fcm_token": fcmToken,
    "is_registered": isRegistered,
    "work_images": List<String>.from(workImages!.map((x) => x)),
    "charges": charges,
    "charge_type": chargeType,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "is_verified":isVerified,
    "kyc_status":kycStatus,
    "smart_call_control": smartCallControl,
    "smart_call_schedule": smartCallSchedule?.map((x) => x.toJson()).toList(),
    "charge_type_id":chargeId,
    "city_id":cityId,
    "prof_category_id":professionId
    // "deletedAt": deletedAt,
  };
}

class SmartCallSchedule {
  String? day;
  bool? status;
  String? toTime;
  String? fromTime;

  SmartCallSchedule({
    this.day,
    this.status,
    this.toTime,
    this.fromTime,
  });

  factory SmartCallSchedule.fromJson(Map<String, dynamic> json) =>
      SmartCallSchedule(
        day: json["day"],
        status: json["status"],
        toTime: json["to_time"],
        fromTime: json["from_time"],
      );

  Map<String, dynamic> toJson() => {
    "day": day,
    "status": status,
    "to_time": toTime,
    "from_time": fromTime,
  };
}

