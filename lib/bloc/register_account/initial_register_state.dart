part of 'initial_register_bloc.dart';

@immutable
abstract class InitialRegisterState extends Equatable {
  const InitialRegisterState();
  @override
  List<Object> get props => [];
}

class InitialRegisterInitial extends InitialRegisterState {}

class InitialRegisterLoading extends InitialRegisterState {
  const InitialRegisterLoading();
  @override
  List<Object> get props => [];
}

class UploadImageSuccess extends InitialRegisterState {
  String filePath;
  UploadImageSuccess({required this.filePath});
  @override
  List<Object> get props => [filePath];
}

class UploadMultipleImageSuccess extends InitialRegisterState {
  String filePath;
  UploadMultipleImageSuccess({required this.filePath});
  @override
  List<Object> get props => [filePath];
}

class UploadImageFailed extends InitialRegisterState {
  String message;
  UploadImageFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class InitialRegisterFailed extends InitialRegisterState {
  String message;
  InitialRegisterFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class InitialRegisterSuccess extends InitialRegisterState {
  String message;
  InitialRegisterSuccess({required this.message});
  @override
  List<Object> get props => [];
}

class FetchCityFailed extends InitialRegisterState {
  String message;
  FetchCityFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchCitySuccess extends InitialRegisterState {
  final List<CityData> dropDownItems;
  final String message;
  FetchCitySuccess({required this.dropDownItems, required this.message});
  @override
  List<Object> get props => [dropDownItems, message];
}

class FetchCityLoading extends InitialRegisterState {
  const FetchCityLoading();
  @override
  List<Object> get props => [];
}

class FetchChargeFeesLoading extends InitialRegisterState {
  const FetchChargeFeesLoading();
  @override
  List<Object> get props => [];
}

class FetchChargeFeesFailed extends InitialRegisterState {
  String message;
  FetchChargeFeesFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchChargeFeesSuccess extends InitialRegisterState {
  final List<FeesChargeData> fetchChargeFeesItems;
  final String message;
  const FetchChargeFeesSuccess(
      {required this.fetchChargeFeesItems, required this.message});
  @override
  List<Object> get props => [fetchChargeFeesItems, message];
}

class FetchKnownLanguageSuccess extends InitialRegisterState {
  final List<KnownLanguageData> dropDownItems;
  final String message;

  FetchKnownLanguageSuccess(
      {required this.dropDownItems, required this.message});

  @override
  List<Object> get props => [dropDownItems, message];
}

class FetchDropDownLoading extends InitialRegisterState {
  const FetchDropDownLoading();
  @override
  List<Object> get props => [];
}

class FetchDropDownFailed extends InitialRegisterState {
  String message;
  FetchDropDownFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchPinListSuccess extends InitialRegisterState {
  List<PincodeListModal> dropDownItems = [];
  final String message;

  FetchPinListSuccess(
      {required this.dropDownItems, required this.message});

  @override
  List<Object> get props => [dropDownItems, message];
}

class FetchPinListLoading extends InitialRegisterState {
  const FetchPinListLoading();
  @override
  List<Object> get props => [];
}

class FetchPinListFailed extends InitialRegisterState {
  String message;
  FetchPinListFailed({required this.message});
  @override
  List<Object> get props => [message];
}
