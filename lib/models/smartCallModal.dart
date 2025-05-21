// To parse this JSON data, do
//
//     final smartCallSettings = smartCallSettingsFromJson(jsonString);

import 'dart:convert';

import 'package:works_app/models/fetch_profile_model.dart';

SmartCallSettings smartCallSettingsFromJson(String str) => SmartCallSettings.fromJson(json.decode(str));

String smartCallSettingsToJson(SmartCallSettings data) => json.encode(data.toJson());

class SmartCallSettings {
  String smartCallControl;
  List<SmartCallSchedule> smartCallSchedule;

  SmartCallSettings({
    required this.smartCallControl,
    required this.smartCallSchedule,
  });

  factory SmartCallSettings.fromJson(Map<String, dynamic> json) => SmartCallSettings(
    smartCallControl: json["smart_call_control"],
    smartCallSchedule: List<SmartCallSchedule>.from(json["smart_call_schedule"].map((x) => SmartCallSchedule.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "smart_call_control": smartCallControl,
    "smart_call_schedule": List<dynamic>.from(smartCallSchedule.map((x) => x.toJson())),
  };
}


