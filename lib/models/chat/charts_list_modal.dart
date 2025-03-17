
import 'dart:convert';

List<ChatList> chatListFromJson(String str) => List<ChatList>.from(json.decode(str).map((x) => ChatList.fromJson(x)));

String chatListToJson(List<ChatList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatList {
  String? name;
  String? picture;
  String? chatId;
  bool? isGroup;
  LatestMessage? latestMessage;
  String? unreadCount;
  DateTime? updatedAt;

  ChatList({
     this.name,
     this.picture,
     this.chatId,
     this.isGroup,
     this.latestMessage,
     this.unreadCount,
     this.updatedAt,
  });

  factory ChatList.fromJson(Map<String, dynamic> json) => ChatList(
    name: json["name"]??"",
    picture: json["picture"]??"",
    chatId: json["chat_id"]??"",
    isGroup: json["is_group"]??"",
    latestMessage: json["latest_message"] == null ? null : LatestMessage.fromJson(json["latest_message"]),
    unreadCount: json["unread_count"].toString()??"",
    updatedAt: json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "picture": picture,
    "chat_id": chatId,
    "is_group": isGroup,
    "latest_message": latestMessage?.toJson(),
    "unread_count": unreadCount,
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class LatestMessage {
  String? id;
  String? content;
  DateTime? createdAt;
  String? type;
  Sender? sender;

  LatestMessage({
     this.id,
     this.content,
     this.createdAt,
     this.type,
     this.sender,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) => LatestMessage(
    id: json["id"]??"",
    content: json.containsKey("content")?json["content"]??"":"",
    createdAt: DateTime.parse(json["createdAt"]),
    type: json["type"]??"",
    sender: json.containsKey("sender")?Sender.fromJson(json["sender"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "createdAt": createdAt?.toIso8601String(),
    "type": type,
    "sender": sender?.toJson(),
  };
}

class Sender {
  String? id;
  String? name;
  String? profilePic;
  String? userType;
  String? professionType;

  Sender({
     this.id,
     this.name,
     this.profilePic,
     this.userType,
     this.professionType,
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
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
