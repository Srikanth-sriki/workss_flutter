part of 'initial_register_bloc.dart';

@immutable
abstract class InitialRegisterEvent extends Equatable {
  const InitialRegisterEvent();
  @override
  List<Object> get props => [];
}

class UploadImageEvent extends InitialRegisterEvent {
  final File imagePath;

  UploadImageEvent({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}

class UploadMultipleImageEvent extends InitialRegisterEvent {
  final File imagePath;

  const UploadMultipleImageEvent({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}

class RegisterAccountEvent extends InitialRegisterEvent {
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

  RegisterAccountEvent(
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
