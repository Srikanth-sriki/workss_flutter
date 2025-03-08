// To parse this JSON data, do
//
//     final requestFriendsList = requestFriendsListFromJson(jsonString);

import 'dart:convert';

List<RequestFriendsList> requestFriendsListFromJson(String str) => List<RequestFriendsList>.from(json.decode(str).map((x) => RequestFriendsList.fromJson(x)));

String requestFriendsListToJson(List<RequestFriendsList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RequestFriendsList {
  String id;
  String userId;
  String senderId;
  Sender sender;

  RequestFriendsList({
    required this.id,
    required this.userId,
    required this.senderId,
    required this.sender,
  });

  factory RequestFriendsList.fromJson(Map<String, dynamic> json) => RequestFriendsList(
    id: json["id"],
    userId: json["userId"],
    senderId: json["senderId"],
    sender: Sender.fromJson(json["sender"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "senderId": senderId,
    "sender": sender.toJson(),
  };
}

class Sender {
  String id;
  String name;
  String profilePic;
  String bio;
  String userType;
  String professionType;

  Sender({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.bio,
    required this.userType,
    required this.professionType,
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    id: json["id"],
    name: json["name"],
    profilePic: json["profile_pic"],
    bio: json["bio"],
    userType: json["user_type"],
    professionType: json["profession_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_pic": profilePic,
    "bio": bio,
    "user_type": userType,
    "profession_type": professionType,
  };
}
