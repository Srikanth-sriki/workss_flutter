import 'dart:convert';

ChatViewGroupInfo chatViewGroupInfoFromJson(String str) =>
    ChatViewGroupInfo.fromJson(json.decode(str));

String chatViewGroupInfoToJson(ChatViewGroupInfo data) =>
    json.encode(data.toJson());

class ChatViewGroupInfo {
  String id;
  String name;
  String picture;
  String description;
  String createdBy;
  bool isGroup;
  List<String> archivedFor;
  List<Participant> participants;

  ChatViewGroupInfo({
    this.id = "",
    this.name = "",
    this.picture = "",
    this.description = "",
    this.createdBy = "",
    this.isGroup = false,
    List<String>? archivedFor,
    List<Participant>? participants,
  })  : archivedFor = archivedFor ?? [],
        participants = participants ?? [];

  factory ChatViewGroupInfo.fromJson(Map<String, dynamic> json) =>
      ChatViewGroupInfo(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        picture: json["picture"] ?? "",
        description: json["description"] ?? "",
        createdBy: json["created_by"] ?? "",
        isGroup: json["is_group"] ?? false,
        archivedFor: json["archived_for"] != null
            ? List<String>.from(json["archived_for"].map((x) => x))
            : [],
        participants: json["participants"] != null
            ? List<Participant>.from(
            json["participants"].map((x) => Participant.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "picture": picture,
    "description": description,
    "is_group": isGroup,
    "created_by": createdBy,
    "archived_for": List<dynamic>.from(archivedFor.map((x) => x)),
    "participants":
    List<dynamic>.from(participants.map((x) => x.toJson())),
  };
}

class Participant {
  String id;
  String chatId;
  String userId;
  bool isAdmin;
  User user;

  Participant({
    this.id = "",
    this.chatId = "",
    this.userId = "",
    this.isAdmin = false,
    User? user,
  }) : user = user ?? User();

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    id: json["id"] ?? "",
    chatId: json["chat_id"] ?? "",
    userId: json["user_id"] ?? "",
    isAdmin: json["is_admin"] ?? false,
    user: json["user"] != null ? User.fromJson(json["user"]) : User(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "chat_id": chatId,
    "user_id": userId,
    "is_admin": isAdmin,
    "user": user.toJson(),
  };
}

class User {
  String id;
  String name;
  String profilePic;
  String userType;
  String professionType;

  User({
    this.id = "",
    this.name = "",
    this.profilePic = "",
    this.userType = "",
    this.professionType = "",
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    profilePic: json["profile_pic"] ?? "",
    userType: json["user_type"] ?? "",
    professionType: json["profession_type"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_pic": profilePic,
    "user_type": userType,
    "profession_type": professionType,
  };
}
