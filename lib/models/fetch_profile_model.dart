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
    id: json["id"],
    countryCode: json["country_code"],
    mobile: json["mobile"],
    name: json["name"],
    email: json["email"],
    profilePic: json["profile_pic"],
    bio: json["bio"],
    userType: json["user_type"],
    professionType: json["profession_type"],
    pincode: json["pincode"],
    city: json["city"],
    experiencedYears: json["experienced_years"],
    knownLanguages: List<String>.from(json["known_languages"].map((x) => x)),
    gender: json["gender"],
    age: json["age"],
    fcmToken: json["fcm_token"],
    isRegistered: json["is_registered"],
    workImages: List<String>.from(json["work_images"].map((x) => x)),
    charges: json["charges"],
    chargeType: json["charge_type"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
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
