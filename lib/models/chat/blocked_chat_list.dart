// To parse this JSON data, do
//
//     final chatBlockedList = chatBlockedListFromJson(jsonString);

import 'dart:convert';

List<ChatBlockedList> chatBlockedListFromJson(String str) => List<ChatBlockedList>.from(json.decode(str).map((x) => ChatBlockedList.fromJson(x)));

String chatBlockedListToJson(List<ChatBlockedList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatBlockedList {
  String? name;
  String? picture;
  String? chatId;
  bool? isGroup;
  // dynamic description;
  // dynamic latestMessage;
  // int unreadCount;
  // DateTime updatedAt;

  ChatBlockedList({
     this.name,
     this.picture,
     this.chatId,
     this.isGroup,
    // required this.description,
    // required this.latestMessage,
    // required this.unreadCount,
    // required this.updatedAt,
  });

  factory ChatBlockedList.fromJson(Map<String, dynamic> json) => ChatBlockedList(
    name: json["name"],
    picture: json["picture"],
    chatId: json["chat_id"],
    isGroup: json["is_group"],
    // description: json["description"],
    // latestMessage: json["latest_message"],
    // unreadCount: json["unread_count"],
    // updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "picture": picture,
    "chat_id": chatId,
    "is_group": isGroup,
    // "description": description,
    // "latest_message": latestMessage,
    // "unread_count": unreadCount,
    // "updatedAt": updatedAt.toIso8601String(),
  };
}
