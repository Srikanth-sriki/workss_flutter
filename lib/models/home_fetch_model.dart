class HomeFetchModel {
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
  DateTime? createdAt;
  DateTime? updatedAt;
  String? distance;
  User? user;
  IntrestShown? intrestShown;

  HomeFetchModel({
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
    this.distance,
    this.user,
    this.intrestShown,
  });

  factory HomeFetchModel.fromJson(Map<String, dynamic> json) => HomeFetchModel(
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
    isProfessionalCanCall: json["is_professional_can_call"] ?? false,
    latitude: json["latitude"]?.toString() ?? '',
    longitude: json["longitude"]?.toString() ?? '',
    description: json["description"] ?? '',
    isVerified: json["is_verified"] ?? false,
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : null,
    distance: json["distance"]?.toString() ?? '',
    user: json["user"] != null ? User.fromJson(json["user"]) : null,
    intrestShown: json["intrestShown"] != null
        ? IntrestShown.fromJson(json["intrestShown"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "required_profession": requiredProfession,
    "experience_level": experienceLevel,
    "gender": gender,
    "know_language": knowLanguage != null
        ? List<String>.from(knowLanguage!.map((x) => x))
        : [],
    "location": location,
    "work_place": workPlace,
    "work_images": workImages != null
        ? List<dynamic>.from(workImages!.map((x) => x))
        : [],
    "is_professional_can_call": isProfessionalCanCall,
    "latitude": latitude,
    "longitude": longitude,
    "description": description,
    "is_verified": isVerified,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "distance": distance,
    "user": user?.toJson(),
    "intrestShown": intrestShown?.toJson(),
  };
}

class IntrestShown {
  String? id;
  String? userId;
  String? workId;
  bool? isContacted;
  DateTime? createdAt;
  DateTime? updatedAt;

  IntrestShown({
    this.id,
    this.userId,
    this.workId,
    this.isContacted,
    this.createdAt,
    this.updatedAt,
  });

  factory IntrestShown.fromJson(Map<String, dynamic> json) => IntrestShown(
    id: json["id"],
    userId: json["userId"],
    workId: json["workId"],
    isContacted: json["is_contacted"] ?? false,
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "workId": workId,
    "is_contacted": isContacted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
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
    id: json["id"],
    name: json["name"],
    city: json["city"],
    professionType: json["profession_type"],
    countryCode: json["country_code"],
    mobile: json["mobile"],
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
