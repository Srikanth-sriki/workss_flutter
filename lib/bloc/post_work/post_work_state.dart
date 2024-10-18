part of 'post_work_bloc.dart';

@immutable
sealed class PostWorkState extends Equatable {
  const PostWorkState();
  @override
  List<Object> get props => [];
}

final class PostWorkInitial extends PostWorkState {}

class PostWorkLoading extends PostWorkState {
  const PostWorkLoading();
  @override
  List<Object> get props => [];
}

class PostWorkFailed extends PostWorkState {
  String message;
  PostWorkFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class PostWorkSuccess extends PostWorkState {
  String message;
  String workId;
  PostWorkSuccess({required this.message,required this.workId});
  @override
  List<Object> get props => [];
}

class UploadMultipleImageSuccess extends PostWorkState {
  String filePath;
  UploadMultipleImageSuccess({required this.filePath});
  @override
  List<Object> get props => [filePath];
}


class UploadImageFailed extends PostWorkState {
  String message;
  UploadImageFailed({required this.message});
  @override
  List<Object> get props => [message];
}


class EditPostWorkFailed extends PostWorkState {
  String message;
  EditPostWorkFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class EditPostWorkSuccess extends PostWorkState {
  String message;
  EditPostWorkSuccess({required this.message});
  @override
  List<Object> get props => [];
}


class DeletePostWorkFailed extends PostWorkState {
  String message;
  DeletePostWorkFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class DeletePostWorkSuccess extends PostWorkState {
  String message;
  DeletePostWorkSuccess({required this.message});
  @override
  List<Object> get props => [];
}

class DeletePostWorkLoading extends PostWorkState {
  const DeletePostWorkLoading();
  @override
  List<Object> get props => [];
}