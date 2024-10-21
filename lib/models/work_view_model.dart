// To parse this JSON data, do
//
//     final workViewModel = workViewModelFromJson(jsonString);

import 'dart:convert';

WorkViewModel workViewModelFromJson(String str) => WorkViewModel.fromJson(json.decode(str));

String workViewModelToJson(WorkViewModel data) => json.encode(data.toJson());

class WorkViewModel {
  Work? work;
  List<Work>? similarWorks;

  WorkViewModel({
    this.work,
    this.similarWorks,
  });

  factory WorkViewModel.fromJson(Map<String, dynamic> json) => WorkViewModel(
    work: json.containsKey("work") ? json["work"] == null ? null :   Work.fromJson(json["work"]) : null,
    similarWorks:json.containsKey("SimilarWorks") ? json["SimilarWorks"] == null ? null : List<Work>.from(json["SimilarWorks"].map((x) => Work.fromJson(x))):null,

  );

  Map<String, dynamic> toJson() => {
    "work": work!.toJson(),
    "SimilarWorks": List<dynamic>.from(similarWorks!.map((x) => x.toJson())),
  };
}

class Work {
  String? id;
  String? userId;
  String? requiredProfession;
  String? experienceLevel;
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
  IntrestShown? intrestShown;
  IntrestShown? isSaved;
  User? user;
  DateTime? updatedAt;

  Work({
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
    this.intrestShown,
    this.isSaved,
    this.user,
    this.updatedAt
  });

  factory Work.fromJson(Map<String, dynamic> json) => Work(
    id: json["id"],
    userId: json["userId"],
    requiredProfession: json["required_profession"],
    experienceLevel: json["experience_level"],
    gender: json["gender"],
    knowLanguage: json["know_language"] != null
        ? List<String>.from(json["know_language"].map((x) => x))
        : [],
    location: json["location"],
    workPlace: json["work_place"],
    workImages: json["work_images"] != null
        ? List<String>.from(json["work_images"].map((x) => x))
        : [],
    isProfessionalCanCall: json["is_professional_can_call"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    description: json["description"],
    isVerified: json["is_verified"],
    intrestShown: json["intrestShown"] != null?IntrestShown.fromJson(json["intrestShown"]):null,
    isSaved: json["isSaved"] != null?IntrestShown.fromJson(json["isSaved"]):null,
    user: json["user"] != null?User.fromJson(json["user"]):null,
    updatedAt: DateTime.parse(json["updatedAt"]),
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
    "intrestShown": intrestShown!.toJson(),
    "isSaved": isSaved!.toJson(),
    "user": user!.toJson(),
    "updatedAt": updatedAt!.toIso8601String(),
  };
}

class IntrestShown {
  String? id;
  String? userId;
  String? workId;
  bool? isContacted;

  IntrestShown({
    this.id,
    this.userId,
    this.workId,
    this.isContacted,
  });

  factory IntrestShown.fromJson(Map<String, dynamic> json) => IntrestShown(
    id: json["id"]??"",
    userId: json["userId"]??"",
    workId: json["workId"]??"",
    isContacted: json["is_contacted"]??false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "workId": workId,
    "is_contacted": isContacted,
  };
}

class User {
  String? id;
  String? name;
  String? city;
  dynamic? professionType;
  String? countryCode;
  String? mobile;

  User({
    this.id,
    this.name,
    this.city,
    this.professionType,
    this.countryCode,
    this.mobile,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"]??'',
    name: json["name"]??'',
    city: json["city"]??'',
    professionType: json["profession_type"]??'',
    countryCode: json["country_code"]??'',
    mobile: json["mobile"]??'',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "city": city,
    "profession_type": professionType,
    "country_code": countryCode,
    "mobile": mobile,
  };
}
