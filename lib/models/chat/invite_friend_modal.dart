

import 'dart:convert';

List<InviteFriend> inviteFriendFromJson(String str) => List<InviteFriend>.from(json.decode(str).map((x) => InviteFriend.fromJson(x)));

String inviteFriendToJson(List<InviteFriend> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InviteFriend {
  String? id;
  String? userId;
  String? friendId;
  User? user;

  InviteFriend({
     this.id,
     this.userId,
     this.friendId,
     this.user,
  });

  factory InviteFriend.fromJson(Map<String, dynamic> json) => InviteFriend(
    id: json["id"],
    userId: json["userId"],
    friendId: json["friendId"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "friendId": friendId,
    "user": user!.toJson(),
  };
}

class User {
  String? id;
  String? name;
  String? profilePic;
  String? bio;
  String? userType;
  String? professionType;
  IsGroupMember? isGroupMember;

  User({
     this.id,
     this.name,
     this.profilePic,
     this.bio,
     this.userType,
     this.professionType,
     this.isGroupMember,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"]??"",
    name: json["name"]??"",
    profilePic: json["profile_pic"]??"",
    bio: json["bio"]??"",
    userType: json["user_type"]??"",
    professionType: json["profession_type"]??"",
    // isInvited: json["isInvited"],
    isGroupMember: IsGroupMember.fromJson(json["isGroupMember"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_pic": profilePic,
    "bio": bio,
    "user_type": userType,
    "profession_type": professionType,
    // "isInvited": isInvited,
    "isGroupMember": isGroupMember!.toJson(),
  };
}

class IsGroupMember {
  String? id;
  String? chatId;
  String? userId;
  bool? isAdmin;

  IsGroupMember({
     this.id,
     this.chatId,
     this.userId,
     this.isAdmin,

  });

  factory IsGroupMember.fromJson(Map<String, dynamic> json) => IsGroupMember(
    id: json["id"]??"",
    chatId: json["chat_id"]??"",
    userId: json["user_id"]??"",
    isAdmin: json["is_admin"]??"",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "chat_id": chatId,
    "user_id": userId,
    "is_admin": isAdmin,
  };
}
