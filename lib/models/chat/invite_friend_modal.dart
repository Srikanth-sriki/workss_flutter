

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
    id: json["id"]??'',
    userId: json["userId"]??'',
    friendId: json["friendId"]??'',
    user: json.containsKey('user')?User.fromJson(json["user"]):null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "friendId": friendId,
    "user": user?.toJson(),
  };
}

class User {
  String? id;
  String? name;
  String? profilePic;
  String? bio;
  String? userType;
  String? professionType;
  IsInvited? isInvited;
  dynamic? isGroupMember;

  User({
     this.id,
     this.name,
     this.profilePic,
     this.bio,
     this.userType,
     this.professionType,
     this.isInvited,
     this.isGroupMember,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"]??"",
    name: json["name"]??"",
    profilePic: json["profile_pic"]??"",
    bio: json["bio"]??"",
    userType: json["user_type"]??"",
    professionType: json["profession_type"]??"",
    isInvited: IsInvited.fromJson(json["isInvited"]),
    isGroupMember: json["isGroupMember"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "profile_pic": profilePic,
    "bio": bio,
    "user_type": userType,
    "profession_type": professionType,
    "isInvited": isInvited?.toJson(),
    "isGroupMember": isGroupMember,
  };
}

class IsInvited {
  String? id;
  String? userId;
  String? chatId;
  String? sentBy;


  IsInvited({
     this.id,
     this.userId,
     this.chatId,
     this.sentBy,
  });

  factory IsInvited.fromJson(Map<String, dynamic> json) => IsInvited(
    id: json["id"],
    userId: json["user_id"],
    chatId: json["chat_id"],
    sentBy: json["sent_by"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "chat_id": chatId,
    "sent_by": sentBy,
  };
}
