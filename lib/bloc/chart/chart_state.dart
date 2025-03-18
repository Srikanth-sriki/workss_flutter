part of 'chart_bloc.dart';

@immutable
sealed class ChartState extends Equatable {
  const ChartState();
  @override
  List<Object> get props => [];
}

final class ChartInitial extends ChartState {}

class ChartListLoading extends ChartState {
  const ChartListLoading();
  @override
  List<Object> get props => [];
}

class ChartListFailed extends ChartState {
  String message;
  ChartListFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ChartListSuccess extends ChartState {
  List<ChatList> chatList = [];
  ChartListSuccess({required this.chatList});
  @override
  List<Object> get props => [chatList];
}

class ChartGroupCreateFailed extends ChartState {
  String message;
  ChartGroupCreateFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ChartGroupCreateSuccess extends ChartState {
  String message;
  ChartGroupCreateSuccess({required this.message});
  @override
  List<Object> get props => [];
}

class ChartGroupEditFailed extends ChartState {
  String message;
  ChartGroupEditFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ChartGroupEditSuccess extends ChartState {
  String message;
  ChartGroupEditSuccess({required this.message});
  @override
  List<Object> get props => [];
}

class InviteMemberFailed extends ChartState {
  String message;
  InviteMemberFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class InviteMemberSuccess extends ChartState {
  List<InviteFriend> inviteFriend = [];
  int maxPageNumber;
  int maxPageSize;
  InviteMemberSuccess(
      {required this.inviteFriend,
      required this.maxPageNumber,
      required this.maxPageSize});
  @override
  List<Object> get props => [InviteFriend, maxPageNumber, maxPageSize];
}

class InviteMemberLoading extends ChartState {
  const InviteMemberLoading();
  @override
  List<Object> get props => [];
}

class ChatViewLoading extends ChartState {
  const ChatViewLoading();
  @override
  List<Object> get props => [];
}

class ChatViewFailed extends ChartState {
  String message;
  ChatViewFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ChatViewSuccess extends ChartState {
  List<ChatView> chatView = [];
  int maxPageNumber;
  int maxPageSize;
  ChatViewGroupInfo chatViewGroupInfo = ChatViewGroupInfo();
  ChatViewSuccess(
      {required this.chatView,
      required this.maxPageNumber,
      required this.maxPageSize,required this.chatViewGroupInfo});
  @override
  List<Object> get props => [chatView, maxPageNumber, maxPageSize,chatViewGroupInfo];
}


class ChartSendMessageFailed extends ChartState {
  String message;
  ChartSendMessageFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ChartSendMessageSuccess extends ChartState {
  String message;
  ChartSendMessageSuccess({required this.message});
  @override
  List<Object> get props => [];
}

class ChartSendMessageLoading extends ChartState {
  const ChartSendMessageLoading();
  @override
  List<Object> get props => [];
}

class UploadFileLoading extends ChartState {
  const UploadFileLoading();
  @override
  List<Object> get props => [];
}

class UploadFileSuccess extends ChartState {
  String filePath;
  UploadFileSuccess({required this.filePath});
  @override
  List<Object> get props => [filePath];
}

class UploadFileFailed extends ChartState {
  String message;
  UploadFileFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class EditGroupChatProfileSuccess extends ChartState {
  String message;
  EditGroupChatProfileSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class EditGroupChatProfileFailed extends ChartState {
  String message;
  EditGroupChatProfileFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class EditGroupChatProfileLoading extends ChartState {
  const EditGroupChatProfileLoading();
  @override
  List<Object> get props => [];
}