part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class FetchProfileEvent extends ProfileEvent {
  const FetchProfileEvent();
  @override
  List<Object> get props => [];
}

class FetchPostedEvent extends ProfileEvent {
  const FetchPostedEvent();
  @override
  List<Object> get props => [];
}

class FetchInterestedWorkEvent extends ProfileEvent {
  const FetchInterestedWorkEvent();
  @override
  List<Object> get props => [];
}

class FetchSavedWorkEvent extends ProfileEvent {
  const FetchSavedWorkEvent();
  @override
  List<Object> get props => [];
}

class EditProfileAccount extends ProfileEvent {
  String name;
  String profile_pic;
  String user_type;
  String email;
  String profession_type;
  String pincode;
  String city;
  List<String> known_languages;
  List<String> workImages;
  String gender;
  String bio;
  String experienced_years;
  String charges;
  String charge_type;
  String userLatitude;
  String userLongitude;
  String age;

  EditProfileAccount(
      {required this.name,
      required this.gender,
      required this.bio,
      required this.charge_type,
      required this.charges,
      required this.city,
      required this.email,
      required this.experienced_years,
      required this.known_languages,
      required this.pincode,
      required this.profession_type,
      required this.profile_pic,
      required this.user_type,
      required this.userLatitude,
      required this.userLongitude,
      required this.age,
      required this.workImages});

  @override
  List<Object> get props => [
        name,
        gender,
        bio,
        charge_type,
        charges,
        city,
        email,
        experienced_years,
        known_languages,
        pincode,
        profession_type,
        profile_pic,
        user_type,
        userLongitude,
        userLongitude,
        workImages,
        age
      ];
}

class FetchPostViewEvent extends ProfileEvent {
  String workId;
  FetchPostViewEvent({required this.workId});
  @override
  List<Object> get props => [];
}

class DeleteAccount extends ProfileEvent {
  String reason;
  VoidCallback onSuccess;
  VoidCallback onError;
  DeleteAccount(
      {required this.onSuccess, required this.onError, required this.reason});
  @override
  List<Object> get props => [onSuccess, onError, reason];
}

class NotificationSettingEvent extends ProfileEvent {
  bool workPostedInCity;
  bool workViewedIntrestShowed;
  bool friendRequest;
  bool newClipsFromFriends;
  bool newFriendSuggestions;
  bool msgRecevied;
  bool cmtOrLikeOnYourPost;
  bool groupAlert;
  NotificationSettingEvent({
    required this.workPostedInCity,
    required this.workViewedIntrestShowed,
    required this.friendRequest,
    required this.newClipsFromFriends,
    required this.newFriendSuggestions,
    required this.msgRecevied,
    required this.cmtOrLikeOnYourPost,
    required this.groupAlert,
  });
  @override
  List<Object> get props => [
        workPostedInCity,
        workViewedIntrestShowed,
        friendRequest,
        newClipsFromFriends,
        newFriendSuggestions,
        msgRecevied,
        cmtOrLikeOnYourPost,
        groupAlert
      ];
}

class FetchSettingEvent extends ProfileEvent {
  const FetchSettingEvent();
  @override
  List<Object> get props => [];
}

class FetchFaqEvent extends ProfileEvent {
  const FetchFaqEvent();
  @override
  List<Object> get props => [];
}


class ContactUsEvent extends ProfileEvent {
  String name;
  String email;
  String mobile;
  String message;
  ContactUsEvent({required this.name,required this.email,required this.mobile,required this.message});
  @override
  List<Object> get props => [name,mobile,email,message];
}

class FetchSavedProfessionalEvent extends ProfileEvent {
  const FetchSavedProfessionalEvent();
  @override
  List<Object> get props => [];
}