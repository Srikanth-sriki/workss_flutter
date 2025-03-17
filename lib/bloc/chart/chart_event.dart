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