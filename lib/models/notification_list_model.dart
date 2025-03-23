import 'dart:convert';

List<NotificationModel> notificationModelFromJson(String str) => List<NotificationModel>.from(json.decode(str).map((x) => NotificationModel.fromJson(x)));

String notificationModelToJson(List<NotificationModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationModel {
  String? id;
  String? userId;
  String? workId;
  String? type;
  String? title;
  String? description;
  bool? isRead;
  Content? content;


  NotificationModel({
     this.id,
     this.userId,
     this.workId,
     this.type,
     this.title,
     this.description,
     this.isRead,
     this.content,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json["id"]??"",
    userId: json["user_id"]??"",
    workId: json["work_id"]??"",
    type: json["type"]??"",
    title: json["title"]??"",
    description: json["description"]??"",
    isRead: json["is_read"]??"",
    content: json.containsKey('content') && json['content'] != null?Content.fromJson(json["content"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "work_id": workId,
    "type": type,
    "title": title,
    "description": description,
    "is_read": isRead,
    "content": content?.toJson(),
  };
}

class Content {
  String? body;
  String? type;
  String? title;
  String ?userId;
  String? requestId;
  String ?profilePic;
  String? chatId;
  String? inviteId;

  Content({
     this.body,
     this.type,
     this.title,
     this.userId,
    this.requestId,
     this.profilePic,
    this.chatId,
    this.inviteId,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    body: json["body"]??"",
    type: json["type"]??"",
    title: json["title"]??"",
    userId: json["user_id"]??"",
    requestId: json["request_id"]??"",
    profilePic: json["profile_pic"]??"",
    chatId: json["chat_id"]??"",
    inviteId: json["invite_id"]??"",
  );

  Map<String, dynamic> toJson() => {
    "body": body,
    "type": type,
    "title": title,
    "user_id": userId,
    "request_id": requestId,
    "profile_pic": profilePic,
    "chat_id": chatId,
    "invite_id": inviteId,
  };
}
