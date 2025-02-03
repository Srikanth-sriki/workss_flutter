

import 'dart:convert';

List<SearchFriendLists> searchFriendListsFromJson(String str) => List<SearchFriendLists>.from(json.decode(str).map((x) => SearchFriendLists.fromJson(x)));

String searchFriendListsToJson(List<SearchFriendLists> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchFriendLists {
  String id;
  String name;
  String profilePic;
  String bio;
  String userType;
  String? professionType;
  FriendRequestSent? isFriend;
  FriendRequestSent? friendRequestSent;

  SearchFriendLists({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.bio,
    required this.userType,
    required this.professionType,
    required this.isFriend,
    required this.friendRequestSent,
  });

  factory SearchFriendLists.fromJson(Map<String, dynamic> json) => SearchFriendLists(
    id: json["id"]??"",
    name: json["name"]??"",
    profilePic: json["profile_pic"]??"",
    bio: json["bio"]??"",
    userType: json["user_type"]??"",
    professionType: json["profession_type"]??"",
    isFriend: json["isFriend"] == null ? null : FriendRequestSent.fromJson(json["isFriend"]),
    friendRequestSent: json["friendRequestSent"] == null ? null : FriendRequestSent.fromJson(json["friendRequestSent"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_pic": profilePic,
    "bio": bio,
    "user_type": userType,
    "profession_type": professionType,
    "isFriend": isFriend?.toJson(),
    "friendRequestSent": friendRequestSent?.toJson(),
  };
}

class FriendRequestSent {
  String? id;
  String? userId;
  String? senderId;
  String? friendId;

  FriendRequestSent({
     this.id,
     this.userId,
    this.senderId,
    this.friendId,
  });

  factory FriendRequestSent.fromJson(Map<String, dynamic> json) => FriendRequestSent(
    id: json["id"],
    userId: json["userId"],
    senderId: json["senderId"],
    friendId: json["friendId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "senderId": senderId,
    "friendId": friendId,
  };
}
