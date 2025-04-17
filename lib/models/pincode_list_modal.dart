

import 'dart:convert';

List<PincodeListModal> pincodeListModalFromJson(String str) => List<PincodeListModal>.from(json.decode(str).map((x) => PincodeListModal.fromJson(x)));

String pincodeListModalToJson(List<PincodeListModal> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PincodeListModal {
  String id;
  String cityId;
  String pincode;

  PincodeListModal({
    required this.id,
    required this.cityId,
    required this.pincode,
  });

  factory PincodeListModal.fromJson(Map<String, dynamic> json) => PincodeListModal(
    id: json["id"],
    cityId: json["city_id"],
    pincode: json["pincode"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "city_id": cityId,
    "pincode": pincode,
  };
}


