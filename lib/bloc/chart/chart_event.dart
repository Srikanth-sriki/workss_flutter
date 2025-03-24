part of 'chart_bloc.dart';

@immutable
sealed class ChartEvent extends Equatable {
  const ChartEvent();
  @override
  List<Object> get props => [];
}

class ChartListEvent extends ChartEvent {
  const ChartListEvent();
  @override
  List<Object> get props => [];
}

class ChartGroupCreateEvent extends ChartEvent {
  String picture;
  String name;
  String description;
  List<String> invitedUsers;
  ChartGroupCreateEvent({
    required this.picture,
    required this.name,
    required this.description,
    required this.invitedUsers,
  });
  @override
  List<Object> get props => [picture, name, description, invitedUsers];
}


class ChartGroupEditEvent extends ChartEvent {
  String picture;
  String name;
  String description;
  String id;
  ChartGroupEditEvent({
    required this.picture,
    required this.name,
    required this.description,
    required this.id,
  });
  @override
  List<Object> get props => [picture, name, description, id];
}


class InviteMemberChartEvent extends ChartEvent {
  int page;
  int pageSize;
  String groupId;
  String keyWord;
  InviteMemberChartEvent({
    required this.page,
    required this.pageSize,
    required this.groupId,
    required this.keyWord,
  });
  @override
  List<Object> get props => [page, pageSize, groupId, keyWord];
}

class FetchChartViewEvent extends ChartEvent {
  int page;
  int pageSize;
  String chatId;
  FetchChartViewEvent({
    required this.page,
    required this.pageSize,
    required this.chatId
  });
  @override
  List<Object> get props => [page, pageSize,chatId];
}

class ChartSendMessageEvent extends ChartEvent {
  String chatId;
  String content;
  String messageType;
  String? fileName;
  String? fileUrl;
  String? fileType;
  String? fileSize;
  ChartSendMessageEvent({
    required this.chatId,
    required this.content,
    required this.messageType,
     this.fileName,
     this.fileUrl,
     this.fileType,
     this.fileSize,
  });
  @override
  List<Object> get props => [chatId,
    content,
    messageType,];
}

class UploadFileEvent extends ChartEvent {
  final File filePath;
  UploadFileEvent({required this.filePath});
  @override
  List<Object> get props => [filePath];
}

class EditGroupChatProfileEvent extends ChartEvent {
  String name;
  String picture;
  String chatId;
  String description;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  EditGroupChatProfileEvent({
    required this.name,
    required this.picture,
    required this.chatId,
    required this.description,required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [name,chatId,picture,description,onError,onSuccess];
}


class FetchChartViewProfileEvent extends ChartEvent {
  String chatId;
  FetchChartViewProfileEvent({
    required this.chatId,
  });
  @override
  List<Object> get props => [chatId];
}

class SendInviteMemberEvent extends ChartEvent {
  String chatId;
  List<String> invitedUsers;
  CallbackWithMessage? onSuccess;
  CallbackWithMessage? onError;
  SendInviteMemberEvent({
    required this.chatId,
    required this.invitedUsers,
     this.onSuccess, this.onError
  });
  @override
  List<Object> get props => [chatId,invitedUsers,];
}
class SendRemoveMemberEvent extends ChartEvent {
  String chatId;
  List<String> removeMember;
  CallbackWithMessage? onSuccess;
  CallbackWithMessage? onError;
  SendRemoveMemberEvent({
    required this.chatId,
    required this.removeMember,
     this.onSuccess, this.onError
  });
  @override
  List<Object> get props => [chatId,removeMember,];
}


class ClearChatEvent extends ChartEvent {
  String chatId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  ClearChatEvent({
    required this.chatId,
    required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [chatId,onError,onSuccess];
}

class ArchiveChatEvent extends ChartEvent {
  String chatId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  ArchiveChatEvent({
    required this.chatId,
    required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [chatId,onError,onSuccess];
}

class LeaveGroupChatEvent extends ChartEvent {
  String chatId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  LeaveGroupChatEvent({
    required this.chatId,
    required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [chatId,onError,onSuccess];
}

class ArchivedChartListEvent extends ChartEvent {
  const ArchivedChartListEvent();
  @override
  List<Object> get props => [];
}

class AcceptChatEvent extends ChartEvent {
  String chatId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  AcceptChatEvent({
    required this.chatId,
    required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [chatId,onError,onSuccess];
}

class RejectGroupChatEvent extends ChartEvent {
  String chatId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  RejectGroupChatEvent({
    required this.chatId,
    required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [chatId,onError,onSuccess];
}

class StartMessageEvent extends ChartEvent {
  String chatId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  StartMessageEvent({
    required this.chatId,
    required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [chatId,onError,onSuccess];
}

class DeleteGroupEvent extends ChartEvent {
  String chatId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  DeleteGroupEvent({
    required this.chatId,
    required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [chatId,onError,onSuccess];
}

class CancelInviteChatEvent extends ChartEvent {
  String id;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  CancelInviteChatEvent({
    required this.id,
    required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [id,onError,onSuccess];
}