import 'dart:convert';

FetchCategoryModalData fetchCategoryModalDataFromJson(String str) => FetchCategoryModalData.fromJson(json.decode(str));

String fetchCategoryModalDataToJson(FetchCategoryModalData data) => json.encode(data.toJson());

class FetchCategoryModalData {
  bool status;
  String message;
  List<CategorySub> data;

  FetchCategoryModalData({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FetchCategoryModalData.fromJson(Map<String, dynamic> json) => FetchCategoryModalData(
    status: json["status"],
    message: json["message"],
    data: List<CategorySub>.from(json["data"].map((x) => CategorySub.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CategorySub {
  String id;
  String name;
  String image;
  Translation? translation;
  List<ProfessionalSubCategory> professionalSubCategories;

  CategorySub({
    required this.id,
    required this.name,
    required this.image,
    required this.professionalSubCategories,
    required this.translation
  });

  factory CategorySub.fromJson(Map<String, dynamic> json) => CategorySub(
    id: json["id"]??"",
    name: json["name"]??"",
    image: json["image"]??"",
    professionalSubCategories: List<ProfessionalSubCategory>.from(json["professionalSubCategories"].map((x) => ProfessionalSubCategory.fromJson(x)))??[],
    translation: json.containsKey('translation')? json["translation"] == null ? null : Translation.fromJson(json["translation"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "professionalSubCategories": List<dynamic>.from(professionalSubCategories.map((x) => x.toJson())),
    "translation": translation?.toJson(),
  };
}

class ProfessionalSubCategory {
  String id;
  String name;
  Translation? translation;

  ProfessionalSubCategory({
    required this.id,
    required this.name,
    required this.translation
  });

  factory ProfessionalSubCategory.fromJson(Map<String, dynamic> json) => ProfessionalSubCategory(
    id: json["id"]??"",
    name: json["name"]??"",
    translation: json.containsKey('translation')? json["translation"] == null ? null : Translation.fromJson(json["translation"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "translation": translation?.toJson(),
  };
}

class Translation {
  String hindi;
  String tamil;
  String telugu;
  String kannada;
  String marathi;
  String gujarati;
  String malayalam;

  Translation({
    required this.hindi,
    required this.tamil,
    required this.telugu,
    required this.kannada,
    required this.marathi,
    required this.gujarati,
    required this.malayalam,
  });

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
    hindi: json["hindi"] ?? "",
    tamil: json["tamil"] ?? "",
    telugu: json["telugu"] ?? "",
    kannada: json["kannada"] ?? "",
    marathi: json["marathi"] ?? "",
    gujarati: json["gujarati"] ?? "",
    malayalam: json["malayalam"] ?? "",
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

  String? getTranslation(String langKey) {
    switch (langKey) {
      case 'hindi':
        return hindi;
      case 'tamil':
        return tamil;
      case 'telugu':
        return telugu;
      case 'kannada':
        return kannada;
      case 'marathi':
        return marathi;
      case 'gujarati':
        return gujarati;
      case 'malayalam':
        return malayalam;
      default:
        return null;
    }
  }
}
