import 'dart:convert';

FetchDropDown fetchDropDownFromJson(String str) =>
    FetchDropDown.fromJson(json.decode(str));

String fetchDropDownToJson(FetchDropDown data) => json.encode(data.toJson());

class FetchDropDown {
  bool status;
  String message;
  List<DropDownData> data;

  FetchDropDown({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FetchDropDown.fromJson(Map<String, dynamic> json) => FetchDropDown(
        status: json["status"],
        message: json["message"],
        data: List<DropDownData>.from(
            json["data"].map((x) => DropDownData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DropDownData {
  String id;
  String place;

  DropDownData({required this.id, required this.place});

  factory DropDownData.fromJson(Map<String, dynamic> json) => DropDownData(
        id: json["id"] ?? "",
        place: json["place"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "place": place,
      };

  @override
  String toString() => "DropDownData(id: $id, place: $place,)";
}

///-------------------------///

FetchKnownLanguageDropDown fetchKnownLanguageDropDownFromJson(String str) =>
    FetchKnownLanguageDropDown.fromJson(json.decode(str));

String fetchKnownLanguageDropDownToJson(FetchKnownLanguageDropDown data) =>
    json.encode(data.toJson());

class FetchKnownLanguageDropDown {
  bool status;
  String message;
  List<KnownLanguageData> data;

  FetchKnownLanguageDropDown({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FetchKnownLanguageDropDown.fromJson(Map<String, dynamic> json) =>
      FetchKnownLanguageDropDown(
        status: json["status"],
        message: json["message"],
        data: List<KnownLanguageData>.from(
            json["data"].map((x) => KnownLanguageData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class KnownLanguageData {
  String id;
  String language;

  KnownLanguageData({
    required this.id,
    required this.language,
  });

  factory KnownLanguageData.fromJson(Map<String, dynamic> json) =>
      KnownLanguageData(
        id: json["id"] ?? "",
        language: json["language"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "language": language,
  };

  @override
  String toString() => "DropDownData(id: $id, language: $language,)";
}

///-------------------------///

FetchCityDropDown fetchCityDropDownFromJson(String str) =>
    FetchCityDropDown.fromJson(json.decode(str));

String fetchCityDropDownToJson(FetchCityDropDown data) =>
    json.encode(data.toJson());

class FetchCityDropDown {
  bool status;
  String message;
  List<CityData> data;

  FetchCityDropDown({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FetchCityDropDown.fromJson(Map<String, dynamic> json) =>
      FetchCityDropDown(
        status: json["status"],
        message: json["message"],
        data: List<CityData>.from(
            json["data"].map((x) => CityData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CityData {
  String id;
  String city;

  CityData({
    required this.id,
    required this.city,
  });

  factory CityData.fromJson(Map<String, dynamic> json) =>
      CityData(
        id: json["id"] ?? "",
        city: json["city"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "language": city,
  };

  @override
  String toString() => "DropDownData(id: $id, language: $city,)";
}

///-----------------------///


FetchFeesChargeDropDown fetchFeesChargeDropDownFromJson(String str) =>
    FetchFeesChargeDropDown.fromJson(json.decode(str));

String fetchFeesChargeDropDownToJson(FetchCityDropDown data) =>
    json.encode(data.toJson());

class FetchFeesChargeDropDown {
  bool status;
  String message;
  List<FeesChargeData> data;

  FetchFeesChargeDropDown({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FetchFeesChargeDropDown.fromJson(Map<String, dynamic> json) =>
      FetchFeesChargeDropDown(
        status: json["status"],
        message: json["message"],
        data: List<FeesChargeData>.from(
            json["data"].map((x) => FeesChargeData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class FeesChargeData {
  String id;
  String type;

  FeesChargeData({
    required this.id,
    required this.type,
  });

  factory FeesChargeData.fromJson(Map<String, dynamic> json) =>
      FeesChargeData(
        id: json["id"] ?? "",
        type: json["type"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
  };

  @override
  String toString() => "DropDownData(id: $id, type: $type,)";
}


