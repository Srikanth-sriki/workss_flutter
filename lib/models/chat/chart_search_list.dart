

import 'dart:convert';

List<ChartSearchList> chartSearchListFromJson(String str) => List<ChartSearchList>.from(json.decode(str).map((x) => ChartSearchList.fromJson(x)));

String chartSearchListToJson(List<ChartSearchList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChartSearchList {
  String? id;
  String? name;
  String? picture;
  String? description;
  bool? isGroup;
  String? type;
  String? createdBy;
  IsInvited? isInvited;
  IsInvited? isRequested;
  IsInvited? participantsDetails;

  ChartSearchList({
     this.id,
     this.name,
     this.picture,
     this.isGroup,
     this.type,
     this.createdBy,
     this.isInvited,
     this.isRequested,
     this.participantsDetails,
    this.description
  });

  factory ChartSearchList.fromJson(Map<String, dynamic> json) => ChartSearchList(
    id: json["id"],
    name: json["name"],
    picture: json["picture"],
    description: json["description"],
    isGroup: json["is_group"],
    type: json["type"],
    createdBy: json["created_by"],
    isInvited: json["isInvited"] == null ? null : IsInvited.fromJson(json["isInvited"]),
    isRequested: json["isRequested"] == null ? null : IsInvited.fromJson(json["isRequested"]),
    participantsDetails: json["participantsDetails"] == null ? null : IsInvited.fromJson(json["participantsDetails"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "picture": picture,
    "description": description,
    "is_group": isGroup,
    "type": type,
    "created_by": createdBy,
    "isInvited": isInvited?.toJson(),
    "isRequested": isRequested?.toJson(),
    "participantsDetails": participantsDetails?.toJson(),
  };
}

class IsInvited {
  String? id;
  String? userId;
  String? chatId;
  bool? isAdmin;

  IsInvited({
     this.id,
     this.userId,
     this.chatId,
    this.isAdmin,
  });

  factory IsInvited.fromJson(Map<String, dynamic> json) => IsInvited(
    id: json["id"],
    userId: json["user_id"],
    chatId: json["chat_id"],
    isAdmin: json["is_admin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "chat_id": chatId,
    "is_admin": isAdmin,
  };
}
