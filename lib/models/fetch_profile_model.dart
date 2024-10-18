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
  List<String>? workImages;
  String ?charges;
  String ?chargeType;
  DateTime ?createdAt;
  DateTime ?updatedAt;
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
    isRegistered: json.containsKey("is_registered")?json["is_registered"]??null:null,
    workImages: json.containsKey("work_images")?json["work_images"] == null?null:List<String>.from(json["work_images"].map((x) => x)):null,
    charges: json.containsKey("charges")?json["charges"]??null:null,
    chargeType: json.containsKey("charge_type")?json["charge_type"]??null:null,
    createdAt: json.containsKey("createdAt")?DateTime.parse(json["createdAt"])??null:null,
    updatedAt: json.containsKey("updatedAt")?DateTime.parse(json["updatedAt"])??null:null,
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
    // "deletedAt": deletedAt,
  };
}
