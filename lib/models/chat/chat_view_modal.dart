import 'dart:convert';

List<ChatView> chatViewFromJson(String str) => List<ChatView>.from(json.decode(str).map((x) => ChatView.fromJson(x)));

String chatViewToJson(List<ChatView> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatView {
  String date;
  List<Message> messages;

  ChatView({
    required this.date,
    required this.messages,
  });

  factory ChatView.fromJson(Map<String, dynamic> json) => ChatView(
    date: json["date"],
    messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
  };
}

class Message {
  String? id;
  String? chatId;
  String? senderId;
  String? content;
  String? type;
  List<dynamic>? deletedFor;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<MessageMedia>? messageMedia;
  Sender? sender;

  Message({
     this.id,
     this.chatId,
     this.senderId,
     this.content,
     this.type,
     this.deletedFor,
     this.createdAt,
     this.updatedAt,
     this.deletedAt,
     this.messageMedia,
     this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"]??'',
    chatId: json["chat_id"]??'',
    senderId: json["sender_id"]??'',
    content: json["content"]??'',
    type: json["type"]??'',
    deletedFor: List<dynamic>.from(json["deleted_for"].map((x) => x)),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    deletedAt: json["deletedAt"],
    messageMedia: json.containsKey('messageMedia')?List<MessageMedia>.from(json["messageMedia"].map((x) => MessageMedia.fromJson(x))):null,
    sender: Sender.fromJson(json["sender"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "chat_id": chatId,
    "sender_id": senderId,
    "content": content,
    "type": type,
    "deleted_for": List<dynamic>.from(deletedFor!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "deletedAt": deletedAt,
    "messageMedia": List<dynamic>.from(messageMedia!.map((x) => x.toJson())),
    "sender": sender?.toJson(),
  };
}

class MessageMedia {
  String? id;
  String? messageId;
  String? fileName;
  String? fileUrl;
  String? fileType;
  String? fileSize;
  // DateTime createdAt;
  // DateTime updatedAt;
  // dynamic deletedAt;

  MessageMedia({
     this.id,
     this.messageId,
     this.fileName,
     this.fileUrl,
     this.fileType,
     this.fileSize,
    // required this.createdAt,
    // required this.updatedAt,
    // required this.deletedAt,
  });

  factory MessageMedia.fromJson(Map<String, dynamic> json) => MessageMedia(
    id: json["id"]??"",
    messageId: json["message_id"]??"",
    fileName: json["file_name"]??"",
    fileUrl: json["file_url"]??"",
    fileType: json["file_type"]??"",
    fileSize: json["file_size"]??"",
    // createdAt: DateTime.parse(json["createdAt"]),
    // updatedAt: DateTime.parse(json["updatedAt"]),
    // deletedAt: json["deletedAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "message_id": messageId,
    "file_name": fileName,
    "file_url": fileUrl,
    "file_type": fileType,
    "file_size": fileSize,
    // "createdAt": createdAt.toIso8601String(),
    // "updatedAt": updatedAt.toIso8601String(),
    // "deletedAt": deletedAt,
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



