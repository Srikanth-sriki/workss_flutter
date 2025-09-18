

import 'dart:convert';

List<FetchPostedModel> fetchPostedModelFromJson(String str) => List<FetchPostedModel>.from(json.decode(str).map((x) => FetchPostedModel.fromJson(x)));

String fetchPostedModelToJson(List<FetchPostedModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FetchPostedModel {
  String? id;
  String? userId;
  String ?requiredProfession;
  String? experienceLevel;
  String? gender;
  List<String>? knowLanguage;
  String? location;
  String ?workPlace;
  List<String>? workImages;
  bool ?isProfessionalCanCall;
  String? latitude;
  String ?longitude;
  String? description;
  bool? isVerified;
  DateTime? createdAt;
  DateTime? updatedAt;
  // dynamic deletedAt;
  List<Work>? workIntrests;
  List<Work>? workViews;
  User? user;
  String? city;
  String? pincode;
  String? locality;
  String? profCategoryId;
  String? workPlaceId;
  String?localityId;
  String? cityId;
  ProfessionalSubCategory? professionalSubCategory;
  ProfessionalSubCategory? workPlaceCategory;

  FetchPostedModel({
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
    this.createdAt,
    this.updatedAt,
    this.workIntrests,
    this.workViews,
    this.user,
     this. city,
     this. pincode,
     this. locality,
    this.workPlaceId,
    this.profCategoryId,
    this.professionalSubCategory,
    this.workPlaceCategory,
    this.cityId,
    this.localityId
    // this.deletedAt,
  });

  factory FetchPostedModel.fromJson(Map<String, dynamic> json) => FetchPostedModel(
    id: json["id"],
    userId: json["userId"],
    requiredProfession: json["required_profession"],
    experienceLevel: json["experience_level"],
    gender: json["gender"],
    knowLanguage: List<String>.from(json["know_language"].map((x) => x)),
    location: json["location"],
    workPlace: json["work_place"],
    workImages: List<String>.from(json["work_images"].map((x) => x)),
    isProfessionalCanCall: json["is_professional_can_call"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    description: json["description"],
    isVerified: json["is_verified"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    workIntrests:  json.containsKey("workIntrests") ? json["workIntrests"] == null ? null :  List<Work>.from(json["workIntrests"].map((x) => Work.fromJson(x))) : null,
    workViews: json.containsKey("workViews") ? json["workViews"] == null ? null :  List<Work>.from(json["workViews"].map((x) => Work.fromJson(x))) : null,
    user: json["user"] != null ? User.fromJson(json["user"]) : null,
    locality: json["locality"] ??"",
    pincode: json["pincode"] ??"",
    city: json["city"] ??'',
    profCategoryId: json["prof_category_id"]??'',
    workPlaceId: json["work_place_id"]??"",
    localityId: json["locality_id"]??"",
    cityId: json["city_id"]??"",
    professionalSubCategory: json["professionalSubCategory"] != null?
    ProfessionalSubCategory.fromJson(json["professionalSubCategory"]):null,
    workPlaceCategory: json.containsKey("workPlace")?json["workPlace"] == null ? null : ProfessionalSubCategory.fromJson(json["workPlace"]):null,
    // deletedAt: json["deletedAt"],
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
    "createdAt": createdAt!.toIso8601String(),
    "updatedAt": updatedAt!.toIso8601String(),
    "workIntrests": List<dynamic>.from(workIntrests!.map((x) => x.toJson())),
    "workViews": List<dynamic>.from(workViews!.map((x) => x.toJson())),
    "user": user?.toJson(),
    "city":city,
    "pincode": pincode,
    "locality": locality,
    "professionalSubCategory": professionalSubCategory!.toJson(),
    "workPlace": workPlaceCategory!.toJson(),
    "prof_category_id": profCategoryId,
    "work_place_id": workPlaceId,
    "locality_id": localityId,
    "city_id": cityId,
    // "deletedAt": deletedAt,
  };
}

class Work {
  String? id;
  String? userId;
  String? workId;
  bool? isContacted;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic? deletedAt;

  Work({
    this.id,
    this.userId,
    this.workId,
    this.isContacted,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Work.fromJson(Map<String, dynamic> json) => Work(
    id: json["id"],
    userId: json["userId"],
    workId: json["workId"],
    isContacted: json.containsKey('is_contacted')?json["is_contacted"]:false,
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    deletedAt: json["deletedAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "workId": workId,
    "is_contacted": isContacted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "deletedAt": deletedAt,
  };
}
class User {
  String? id;
  String? name;
  String? city;
  String? professionType;
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
    id: json["id"]??"",
    name: json["name"]??"",
    city: json["city"]??"",
    professionType: json["profession_type"]??"",
    countryCode: json["country_code"]??"",
    mobile: json["mobile"]??"",
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