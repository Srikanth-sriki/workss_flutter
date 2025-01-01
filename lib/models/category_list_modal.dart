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
  List<ProfessionalSubCategory> professionalSubCategories;

  CategorySub({
    required this.id,
    required this.name,
    required this.image,
    required this.professionalSubCategories,
  });

  factory CategorySub.fromJson(Map<String, dynamic> json) => CategorySub(
    id: json["id"]??"",
    name: json["name"]??"",
    image: json["image"]??"",
    professionalSubCategories: List<ProfessionalSubCategory>.from(json["professionalSubCategories"].map((x) => ProfessionalSubCategory.fromJson(x)))??[],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "professionalSubCategories": List<dynamic>.from(professionalSubCategories.map((x) => x.toJson())),
  };
}

class ProfessionalSubCategory {
  String id;
  String name;

  ProfessionalSubCategory({
    required this.id,
    required this.name,
  });

  factory ProfessionalSubCategory.fromJson(Map<String, dynamic> json) => ProfessionalSubCategory(
    id: json["id"]??"",
    name: json["name"]??"",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
