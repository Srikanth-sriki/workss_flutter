import 'dart:convert';

ChatViewGroupInfo chatViewGroupInfoFromJson(String str) => ChatViewGroupInfo.fromJson(json.decode(str));

String chatViewGroupInfoToJson(ChatViewGroupInfo data) => json.encode(data.toJson());

class ChatViewGroupInfo {
  String? id;
  String? name;
  String? picture;
  String? description;
  bool? isGroup;
  List<Participant>? participants;

  ChatViewGroupInfo({
     this.id,
     this.name,
     this.picture,
     this.description,
     this.isGroup,
     this.participants,
  });

  factory ChatViewGroupInfo.fromJson(Map<String, dynamic> json) => ChatViewGroupInfo(
    id: json["id"]??"",
    name: json["name"]??"",
    picture: json["picture"]??"",
    description: json["description"]??"",
    isGroup: json["is_group"] ?? false,
    participants: json["participants"] != null
        ? List<Participant>.from(json["participants"].map((x) => Participant.fromJson(x)))
        : [],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "picture": picture,
    "description": description,
    "is_group": isGroup,
    "participants": List<dynamic>.from(participants!.map((x) => x.toJson())),
  };
}

class Participant {
  String id;
  String chatId;
  String userId;
  bool isAdmin;
  User user;

  Participant({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.isAdmin,
    required this.user,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    id: json["id"],
    chatId: json["chat_id"],
    userId: json["user_id"],
    isAdmin: json["is_admin"],
    user: User.fromJson(json["user"]),
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
    required this.id,
    required this.name,
    required this.profilePic,
    required this.userType,
    required this.professionType,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"]??"",
    name: json["name"]??"",
    profilePic: json["profile_pic"]??"",
    userType: json["user_type"]??"",
    professionType: json["profession_type"]??"",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_pic": profilePic,
    "user_type": userType,
    "profession_type": professionType,
  };
}
