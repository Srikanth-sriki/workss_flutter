part of 'profile_bloc.dart';

@immutable
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
  @override
  List<Object> get props => [];
}

class FetchProfileFailed extends ProfileState {
  String message;

  FetchProfileFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchProfileSuccess extends ProfileState {
  ProfileFetch profileFetch = ProfileFetch();

  FetchProfileSuccess({required this.profileFetch});
  @override
  List<Object> get props => [profileFetch];
}

class UploadPicSuccess extends ProfileState {
  String filePath;
  UploadPicSuccess({required this.filePath});
  @override
  List<Object> get props => [filePath];
}

class UploadPicFailed extends ProfileState {
  String message;
  UploadPicFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class EditProfileSuccess extends ProfileState {
  String message;
  EditProfileSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class EditProfileFailed extends ProfileState {
  String message;
  EditProfileFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchPostedWorkFailed extends ProfileState {
  String message;

  FetchPostedWorkFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchPostedWorkSuccess extends ProfileState {
  List<FetchPostedModel> fetchPostedModel = [];
  FetchPostedWorkSuccess({required this.fetchPostedModel});
  @override
  List<Object> get props => [fetchPostedModel];
}

class FetchInterestedWorkFailed extends ProfileState {
  String message;

  FetchInterestedWorkFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchInterestedWorkSuccess extends ProfileState {
  List<FetchPostedModel> fetchPostedModel = [];
  FetchInterestedWorkSuccess({required this.fetchPostedModel});
  @override
  List<Object> get props => [fetchPostedModel];
}
class FetchSavedWorkFailed extends ProfileState {
  String message;
  FetchSavedWorkFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchSavedWorkSuccess extends ProfileState {
  List<FetchPostedModel> fetchPostedModel = [];
  FetchSavedWorkSuccess({required this.fetchPostedModel});
  @override
  List<Object> get props => [fetchPostedModel];
}


