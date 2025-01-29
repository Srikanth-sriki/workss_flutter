import 'dart:convert';

import 'package:works_app/models/friends/friends_search_list_modal.dart';

FriendsSearchView friendsSearchViewFromJson(String str) => FriendsSearchView.fromJson(json.decode(str));

String friendsSearchViewToJson(FriendsSearchView data) => json.encode(data.toJson());

class FriendsSearchView {
  bool status;
  String message;
  FriendData data;

  FriendsSearchView({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FriendsSearchView.fromJson(Map<String, dynamic> json) => FriendsSearchView(
    status: json["status"],
    message: json["message"],
    data: FriendData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class FriendData {
  User user;
  List<Friend> friends;

  FriendData({
    required this.user,
    required this.friends,
  });

  factory FriendData.fromJson(Map<String, dynamic> json) => FriendData(
    user: User.fromJson(json["user"]),
    friends: json.containsKey('friends') && json['friends'] != null
        ? List<Friend>.from((json['friends'] as List).map((x) => Friend.fromJson(x)))
        : [],

  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
    "friends": List<Friend>.from(friends.map((x) => x.toJson())),
  };
}



class User {
  String id;
  String code;
  String countryCode;
  String mobile;
  String name;
  String profilePic;
  String bio;
  String userType;
  String professionType;
  String city;
  String experiencedYears;
  List<String> knownLanguages;
  String gender;
  String age;
  List<String> workImages;
  String charges;
  String chargeType;
  bool isVerified;
  IsFriend isFriend;
  IsContacted?isSaved;
  IsContacted? isContacted;
  // FriendRequestSent friendRequestSent;

  User({
    required this.id,
    required this.code,
    required this.countryCode,
    required this.mobile,
    required this.name,
    required this.profilePic,
    required this.bio,
    required this.userType,
    required this.professionType,
    required this.city,
    required this.experiencedYears,
    required this.knownLanguages,
    required this.gender,
    required this.age,
    required this.workImages,
    required this.charges,
    required this.chargeType,
    required this.isVerified,
    required this.isFriend,
    this.isSaved,
    this.isContacted,
    // required this.friendRequestSent,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    code: json["code"],
    countryCode: json["country_code"],
    mobile: json["mobile"],
    name: json["name"],
    profilePic: json["profile_pic"],
    bio: json["bio"],
    userType: json["user_type"],
    professionType: json["profession_type"],
    city: json["city"],
    experiencedYears: json["experienced_years"],
    knownLanguages: List<String>.from(json["known_languages"].map((x) => x)),
    gender: json["gender"],
    age: json["age"]?.toString()??'',
    workImages: List<String>.from(json["work_images"].map((x) => x)),
    charges: json["charges"],
    chargeType: json["charge_type"],
    isVerified: json["is_verified"],
    isFriend: IsFriend.fromJson(json["isFriend"]),
    isSaved: json["isSaved"] != null
        ? IsContacted.fromJson(json["isSaved"])
        : null,
    isContacted: json["isContacted"] != null
        ? IsContacted.fromJson(json["isContacted"])
        : null,
    // friendRequestSent: json.containsKey('friendRequestSent') && json['friendRequestSent'] != null
    //     ?FriendRequestSent.fromJson(json["friendRequestSent"])
    //     : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "country_code": countryCode,
    "mobile": mobile,
    "name": name,
    "profile_pic": profilePic,
    "bio": bio,
    "user_type": userType,
    "profession_type": professionType,
    "city": city,
    "experienced_years": experiencedYears,
    "known_languages": List<dynamic>.from(knownLanguages.map((x) => x)),
    "gender": gender,
    "age": age,
    "work_images": List<dynamic>.from(workImages.map((x) => x)),
    "charges": charges,
    "charge_type": chargeType,
    "is_verified": isVerified,
    "isFriend": isFriend.toJson(),
    "isSaved":isSaved,
    "isContacted": isContacted?.toJson(),
   // "friendRequestSent": friendRequestSent.toJson(),
  };
}

class IsFriend {
  String id;
  String userId;
  String friendId;

  IsFriend({
    required this.id,
    required this.userId,
    required this.friendId,
  });

  factory IsFriend.fromJson(Map<String, dynamic> json) => IsFriend(
    id: json["id"]??"",
    userId: json["userId"]??"",
    friendId: json["friendId"]??"",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "friendId": friendId,
  };
}

class FriendRequestSent {
  String id;
  String userId;
  String senderId;

  FriendRequestSent({
    required this.id,
    required this.userId,
    required this.senderId,
  });

  factory FriendRequestSent.fromJson(Map<String, dynamic> json) => FriendRequestSent(
    id: json["id"],
    userId: json["userId"],
    senderId: json["senderId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "senderId": senderId,
  };
}


class IsContacted {
  String? id;
  String? userId;
  String? professionalId;

  IsContacted({
    this.id,
    this.userId,
    this.professionalId,
  });

  factory IsContacted.fromJson(Map<String, dynamic> json) => IsContacted(
    id: json["id"],
    userId: json["userId"],
    professionalId: json["professionalId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "professionalId": professionalId,
  };
}
