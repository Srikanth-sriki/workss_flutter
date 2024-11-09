import 'dart:convert';

List<AddressListModal> addressListModalFromJson(String str) => List<AddressListModal>.from(json.decode(str).map((x) => AddressListModal.fromJson(x)));

String addressListModalToJson(List<AddressListModal> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddressListModal {
  String? id;
  String? userId;
  String? addressType;
  String? houseNo;
  String? area;
  String? instructions;
  String? latitude;
  String? longitude;
  bool? isDefault;
  String? addressTypeName;


  AddressListModal({
    this.id,
    this.userId,
    this.addressType,
    this.houseNo,
    this.area,
    this.instructions,
    this.latitude,
    this.longitude,
    this.isDefault,
    this.addressTypeName

  });

  factory AddressListModal.fromJson(Map<String, dynamic> json) => AddressListModal(
    id: json["id"]??"",
    userId: json["user_id"]??"",
    addressType: json["address_type"]??"",
    houseNo: json["house_no"]??"",
    area: json["area"]??"",
    instructions: json["instructions"]??"",
    latitude: json["latitude"]??"",
    longitude: json["longitude"]??"",
    isDefault: json["is_default"]??"",
    addressTypeName: json["address_type_name"]??""
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "address_type": addressType,
    "house_no": houseNo,
    "area": area,
    "instructions": instructions,
    "latitude": latitude,
    "longitude": longitude,
    "is_default": isDefault,
    "address_type_name":addressTypeName
  };
}
