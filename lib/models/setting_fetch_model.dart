
import 'dart:convert';

SettingFetchModelList settingFetchModelListFromJson(String str) => SettingFetchModelList.fromJson(json.decode(str));

String settingFetchModelListToJson(SettingFetchModelList data) => json.encode(data.toJson());

class SettingFetchModelList {
  String? id;
  String? userId;
  bool? workPostedInCity;
  bool? workViewedIntrestShowed;
  bool? friendRequest;
  bool? newClipsFromFriends;
  bool? newFriendSuggestions;
  bool? msgRecevied;
  bool? cmtOrLikeOnYourPost;
  bool? groupAlert;

  SettingFetchModelList({
    this.id,
    this.userId,
    this.workPostedInCity,
    this.workViewedIntrestShowed,
    this.friendRequest,
    this.newClipsFromFriends,
    this.newFriendSuggestions,
    this.msgRecevied,
    this.cmtOrLikeOnYourPost,
    this.groupAlert,
  });

  factory SettingFetchModelList.fromJson(Map<String, dynamic> json) => SettingFetchModelList(
    id: json["id"],
    userId: json["userId"],
    workPostedInCity: json["work_posted_in_city"],
    workViewedIntrestShowed: json["work_viewed_intrest_showed"],
    friendRequest: json["friend_request"],
    newClipsFromFriends: json["new_clips_from_friends"],
    newFriendSuggestions: json["new_friend_suggestions"],
    msgRecevied: json["msg_recevied"],
    cmtOrLikeOnYourPost: json["cmt_or_like_on_your_post"],
    groupAlert: json["group_alert"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "work_posted_in_city": workPostedInCity,
    "work_viewed_intrest_showed": workViewedIntrestShowed,
    "friend_request": friendRequest,
    "new_clips_from_friends": newClipsFromFriends,
    "new_friend_suggestions": newFriendSuggestions,
    "msg_recevied": msgRecevied,
    "cmt_or_like_on_your_post": cmtOrLikeOnYourPost,
    "group_alert": groupAlert,
  };
}
