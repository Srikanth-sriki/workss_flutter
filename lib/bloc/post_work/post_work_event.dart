part of 'post_work_bloc.dart';

@immutable
sealed class PostWorkEvent extends Equatable {
  const PostWorkEvent();
  @override
  List<Object> get props => [];
}

class UploadImageEvent extends PostWorkEvent {
  final File imagePath;
  const UploadImageEvent({required this.imagePath});
  @override
  List<Object> get props => [imagePath];
}

class UploadMultipleImageEvent extends PostWorkEvent {
  final File imagePath;
  const UploadMultipleImageEvent({required this.imagePath});
  @override
  List<Object> get props => [imagePath];
}

class CreatePostWorkEvent extends PostWorkEvent {
  String requiredProfession;
  String experienceLevel;
  String gender;
  List<String> knowLanguage;
  String location;
  String workPlace;
  List<String> workImages;
  bool isProfessionalCanCall;
  String latitude;
  String longitude;
  String description;
  String city;
  String pincode;
  String locality;
  String profCategoryId;
  String workPlaceId;
  String localityId;
  String cityId;

  CreatePostWorkEvent({
    required this.requiredProfession,
    required this.experienceLevel,
    required this.gender,
    required this.knowLanguage,
    required this.location,
    required this.workPlace,
    required this.workImages,
    required this.isProfessionalCanCall,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this. city,
    required this. pincode,
    required this. locality,
    required this.profCategoryId,
    required this.workPlaceId,
    required this.localityId,
    required this.cityId
  });

  @override
  List<Object> get props => [
        requiredProfession,
        experienceLevel,
        gender,
        knowLanguage,
        location,
        workImages,
        workPlace,
        isProfessionalCanCall,
        latitude,
        longitude,
        description,city,pincode,locality,profCategoryId,workPlaceId,localityId,cityId
      ];
}

class EditPostWorkEvent extends PostWorkEvent {
  String workId;
  String requiredProfession;
  String experienceLevel;
  String gender;
  List<String> knowLanguage;
  String location;
  String workPlace;
  List<String> workImages;
  bool isProfessionalCanCall;
  String latitude;
  String longitude;
  String description;
  String city;
  String pincode;
  String locality;

  EditPostWorkEvent({
    required this.workId,
    required this.requiredProfession,
    required this.experienceLevel,
    required this.gender,
    required this.knowLanguage,
    required this.location,
    required this.workPlace,
    required this.workImages,
    required this.isProfessionalCanCall,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this. city,
    required this. pincode,
    required this. locality,
  });

  @override
  List<Object> get props => [
        workId,
        requiredProfession,
        experienceLevel,
        gender,
        knowLanguage,
        location,
        workImages,
        workPlace,
        isProfessionalCanCall,
        latitude,
        longitude,
        description,city,pincode,locality
      ];
}

class PostWorkDeleteEvent extends PostWorkEvent {
  String workID;
  VoidCallback onSuccess;
  VoidCallback onError;
  PostWorkDeleteEvent(
      {required this.workID, required this.onSuccess, required this.onError});
  @override
  List<Object> get props => [workID, onSuccess, onError];
}

class FetchWorkPlaceEvent extends PostWorkEvent {
  const FetchWorkPlaceEvent();
  @override
  List<Object> get props => [];
}

class FetchWorkKnownLanguageEvent extends PostWorkEvent {
  const FetchWorkKnownLanguageEvent();
  @override
  List<Object> get props => [];
}


class PostVerifyKycImages extends PostWorkEvent {
  String firstImg;
  String backImg;
  PostVerifyKycImages(
      {required this.backImg, required this.firstImg,});
  @override
  List<Object> get props => [firstImg,backImg];
}