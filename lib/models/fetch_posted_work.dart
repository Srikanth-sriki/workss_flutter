

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
    // "deletedAt": deletedAt,
  };
}
