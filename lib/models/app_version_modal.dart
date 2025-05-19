

import 'dart:convert';

List<AppVersion> AppVersionFromJson(String str) => List<AppVersion>.from(json.decode(str).map((x) => AppVersion.fromJson(x)));

String AppVersionToJson(List<AppVersion> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AppVersion {
  String? id;
  String? type;
  String? version;
  bool? forceUpdate;
  bool? maintainanceMode;


  AppVersion({
    this.id,
    this.type,
    this.version,
    this.forceUpdate,
    this.maintainanceMode,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
    id: json["id"]??"",
    type: json["type"]??"",
    version: json["version"]??"",
    forceUpdate: json["force_update"]??false,
    maintainanceMode: json["maintainance_mode"]??false,

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "version": version,
    "force_update": forceUpdate,
    "maintainance_mode": maintainanceMode,
  };
}
