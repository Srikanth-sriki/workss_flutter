part of 'initial_register_bloc.dart';

@immutable
abstract class InitialRegisterState extends Equatable{
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
