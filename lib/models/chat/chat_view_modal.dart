import 'dart:convert';

List<ChatView> chatViewFromJson(String str) =>
    List<ChatView>.from(json.decode(str).map((x) => ChatView.fromJson(x)));

String chatViewToJson(List<ChatView> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatView {
  String date;
  List<Message> messages;

  ChatView({
    required this.date,
    required this.messages,
  });

  factory ChatView.fromJson(Map<String, dynamic> json) => ChatView(
        date: json["date"] ?? "", // Default empty string if null
        messages: json["messages"] != null
            ? List<Message>.from(
                json["messages"].map((x) => Message.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
      };
}

enum MessageState { sending, sent, delivered, read, failed }

class Message {
  String id;
  String chatId;
  String senderId;
  String content;
  String type;
  List<dynamic> deletedFor;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<MessageMedia> messageMedia;
  Sender? sender;
  MessageState messageState;
  bool isUploading;
  String? tempId; // For tracking messages before server response

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.deletedFor,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.messageMedia,
    this.sender,
    this.messageState = MessageState.sent,
    this.isUploading = false,
    this.tempId,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"] ?? "",
        chatId: json["chat_id"] ?? "",
        senderId: json["sender_id"] ?? "",
        content: json["content"] ?? "",
        type: json["type"] ?? "",
        deletedFor: json["deleted_for"] != null
            ? List<dynamic>.from(json["deleted_for"])
            : [],
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        deletedAt: json["deletedAt"],
        messageMedia: json["messageMedia"] != null
            ? List<MessageMedia>.from(
                json["messageMedia"].map((x) => MessageMedia.fromJson(x)))
            : [],
        sender: json["sender"] != null ? Sender.fromJson(json["sender"]) : null,
        messageState: MessageState.values.firstWhere(
          (e) =>
              e.toString() == 'MessageState.${json["messageState"] ?? "sent"}',
          orElse: () => MessageState.sent,
        ),
        isUploading: json["isUploading"] ?? false,
        tempId: json["tempId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "chat_id": chatId,
        "sender_id": senderId,
        "content": content,
        "type": type,
        "deleted_for": List<dynamic>.from(deletedFor.map((x) => x)),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "deletedAt": deletedAt,
        "messageMedia": List<dynamic>.from(messageMedia.map((x) => x.toJson())),
        "sender": sender?.toJson(),
        "messageState": messageState.toString().split('.').last,
        "isUploading": isUploading,
        "tempId": tempId,
      };
}

class MessageMedia {
  String id;
  String messageId;
  String fileName;
  String fileUrl;
  String fileType;
  String fileSize;

  MessageMedia({
    required this.id,
    required this.messageId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
  });

  factory MessageMedia.fromJson(Map<String, dynamic> json) => MessageMedia(
        id: json["id"] ?? "",
        messageId: json["message_id"] ?? "",
        fileName: json["file_name"] ?? "",
        fileUrl: json["file_url"] ?? "",
        fileType: json["file_type"] ?? "",
        fileSize: json["file_size"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message_id": messageId,
        "file_name": fileName,
        "file_url": fileUrl,
        "file_type": fileType,
        "file_size": fileSize,
      };
}

class Sender {
  String id;
  String name;
  String profilePic;
  String userType;
  String professionType;

  Sender({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.userType,
    required this.professionType,
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
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
