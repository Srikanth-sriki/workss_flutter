
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
  bool?isRequest;
  String?requestedBy;


  ChatList({
     this.name,
     this.picture,
     this.chatId,
     this.isGroup,
     this.latestMessage,
     this.unreadCount,
     this.updatedAt,
    this.isRequest,
    this.requestedBy,
  });

  factory ChatList.fromJson(Map<String, dynamic> json) => ChatList(
    name: json["name"]??"",
    picture: json["picture"]??"",
    chatId: json["chat_id"]??"",
    isGroup: json["is_group"]??"",
    latestMessage: json["latest_message"] == null ? null : LatestMessage.fromJson(json["latest_message"]),
    unreadCount: json["unread_count"].toString()??"",
    updatedAt: json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) : null,
    isRequest: json.containsKey("isRequest")?json["isRequest"]??false:false,
      requestedBy:json.containsKey("requestedBy")?json["requestedBy"]:"",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "picture": picture,
    "chat_id": chatId,
    "is_group": isGroup,
    "latest_message": latestMessage?.toJson(),
    "unread_count": unreadCount,
    "updatedAt": updatedAt?.toIso8601String(),
    "isRequest":isRequest,
    "requestedBy":requestedBy,
  };
}

class LatestMessage {
  String? id;
  String? content;
  DateTime? createdAt;
  String? type;
  Sender? sender;
  bool?deletedforall;
  bool?isEdited;

  LatestMessage({
     this.id,
     this.content,
     this.createdAt,
     this.type,
     this.sender,
     this.deletedforall,
     this.isEdited,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) => LatestMessage(
    id: json["id"]??"",
    content: json.containsKey("content")?json["content"]??"":"",
    createdAt: DateTime.parse(json["createdAt"]),
    type: json["type"]??"",
    sender: json.containsKey("sender")?Sender.fromJson(json["sender"]):null,
    deletedforall: json.containsKey("deleted_for_all")?json["deleted_for_all"]??false:false,
    isEdited: json.containsKey("is_edited")?json["is_edited"]??false:false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "createdAt": createdAt?.toIso8601String(),
    "type": type,
    "sender": sender?.toJson(),
    "deleted_for_all":deletedforall,
    "is_edited":isEdited,
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
