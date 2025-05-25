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

class PostedWorkViewLoading extends ProfileState {
  const PostedWorkViewLoading();
  @override
  List<Object> get props => [];
}

class FetchPostedViewWorkFailed extends ProfileState {
  String message;
  FetchPostedViewWorkFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchPostedViewWorkSuccess extends ProfileState {
  ViewFetchPostedWork viewFetchPostedWork = ViewFetchPostedWork();
  FetchPostedViewWorkSuccess({required this.viewFetchPostedWork});
  @override
  List<Object> get props => [ViewFetchPostedWork];
}

class DeleteAccountFailed extends ProfileState {
  String message;
  DeleteAccountFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class DeleteAccountSuccess extends ProfileState {
  String message;
  DeleteAccountSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class NotificationSettingLoading extends ProfileState {
  const NotificationSettingLoading();
  @override
  List<Object> get props => [];
}

class NotificationSettingFailed extends ProfileState {
  String message;
  NotificationSettingFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class NotificationSettingSuccess extends ProfileState {
  String message;
  NotificationSettingSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class NotificationFetchSettingFailed extends ProfileState {
  String message;
  NotificationFetchSettingFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class NotificationFetchSettingSuccess extends ProfileState {
  SettingFetchModelList settingFetchModelList = SettingFetchModelList();
  NotificationFetchSettingSuccess({required this.settingFetchModelList});
  @override
  List<Object> get props => [settingFetchModelList];
}

class FetchFaqFailed extends ProfileState {
  final String message;
  const FetchFaqFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchFaqSuccess extends ProfileState {
  final List<FaqModelList> faqList;

  const FetchFaqSuccess({required this.faqList});

  @override
  List<Object> get props => [faqList];
}

class ContactUsSuccess extends ProfileState {
  final String message;
  const ContactUsSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class ContactUsFailed extends ProfileState {
  final String message;
  const ContactUsFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchSavedProfessionalSuccess extends ProfileState {
  List<ProfessionalsPostedWork> professionalsPostedWork = [];
  FetchSavedProfessionalSuccess({required this.professionalsPostedWork});
  @override
  List<Object> get props => [professionalsPostedWork];
}

class FetchSavedProfessionalFailed extends ProfileState {
  String message;
  FetchSavedProfessionalFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class AddressLocationLoading extends ProfileState {
  const AddressLocationLoading();
  @override
  List<Object> get props => [];
}


class AddressLocationCreateSuccess extends ProfileState {
  final String message;
  const AddressLocationCreateSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class AddressLocationCreateFailed extends ProfileState {
  final String message;
  const AddressLocationCreateFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class AddressLocationEditSuccess extends ProfileState {
  final String message;
  const AddressLocationEditSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class AddressLocationEditFailed extends ProfileState {
  final String message;
  const AddressLocationEditFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class AddressLocationListSuccess extends ProfileState {
  List<AddressListModal> addressListModal = [];
  AddressLocationListSuccess({required this.addressListModal});
  @override
  List<Object> get props => [addressListModal];
}

class AddressLocationListFailed extends ProfileState {
  String message;

  AddressLocationListFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class DeleteAddressLocationFailed extends ProfileState {
  String message;
  DeleteAddressLocationFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class DeleteAddressLocationSuccess extends ProfileState {
  String message;
  DeleteAddressLocationSuccess({required this.message});
  @override
  List<Object> get props => [];
}

class SmartCallControlFailed extends ProfileState {
  String message;
  SmartCallControlFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class SmartCallControlSuccess extends ProfileState {
  String message;
  SmartCallControlSuccess({required this.message});
  @override
  List<Object> get props => [];
}