import 'dart:convert';

FriendsSearchList friendsSearchListFromJson(String str) => FriendsSearchList.fromJson(json.decode(str));

String friendsSearchListToJson(FriendsSearchList data) => json.encode(data.toJson());

class FriendsSearchList {
  List<Friend> friends;
  Pagination pagination;

  FriendsSearchList({
    required this.friends,
    required this.pagination,
  });

  factory FriendsSearchList.fromJson(Map<String, dynamic> json) => FriendsSearchList(
    friends: List<Friend>.from(json["friends"].map((x) => Friend.fromJson(x))),
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "friends": List<dynamic>.from(friends.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Friend {
  String id;
  String userId;
  String friendId;
  Friends friends;

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friends,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json["id"],
    userId: json["userId"],
    friendId: json["friendId"],
    friends: Friends.fromJson(json["friends"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "friendId": friendId,
    "friends": friends.toJson(),
  };

  @override
  String toString() {
    return 'Friend(id: $id, userId: $userId, friendId: $friendId, friends: $friends)';
  }
}


class Friends {
  String id;
  String name;
  String profilePic;
  String bio;
  String userType;
  String professionType;

  Friends({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.bio,
    required this.userType,
    required this.professionType,
  });

  factory Friends.fromJson(Map<String, dynamic> json) => Friends(
    id: json["id"]??"",
    name: json["name"]??"",
    profilePic: json["profile_pic"]??"",
    bio: json["bio"]??"",
    userType: json["user_type"]??"",
    professionType: json["profession_type"]??"",
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

class Pagination {
  // dynamic previousPage;
  int currentPage;
  // dynamic nextPage;
  int total;
  int totalPages;
  int pageSize;

  Pagination({
    // required this.previousPage,
    required this.currentPage,
    // required this.nextPage,
    required this.total,
    required this.totalPages,
    required this.pageSize,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    // previousPage: json["previousPage"],
    currentPage: json["currentPage"],
    // nextPage: json["nextPage"],
    total: json["total"],
    totalPages: json["totalPages"],
    pageSize: json["pageSize"],
  );

  Map<String, dynamic> toJson() => {
    // "previousPage": previousPage,
    "currentPage": currentPage,
    // "nextPage": nextPage,
    "total": total,
    "totalPages": totalPages,
    "pageSize": pageSize,
  };
}
