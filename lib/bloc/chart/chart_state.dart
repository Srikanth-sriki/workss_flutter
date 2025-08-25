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
class RequestedChartListLoading extends ChartState {
  const RequestedChartListLoading();
  @override
  List<Object> get props => [];
}

class RequestedChartListFailed extends ChartState {
  String message;
  RequestedChartListFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class RequestedChartListSuccess extends ChartState {
  List<ChatList> chatList = [];
  RequestedChartListSuccess({required this.chatList});
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

class ChatViewProfileLoading extends ChartState {
  const ChatViewProfileLoading();
  @override
  List<Object> get props => [];
}

class ChatViewProfileFailed extends ChartState {
  String message;
  ChatViewProfileFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ChatViewProfileSuccess extends ChartState {
  ChatViewGroupInfo chatViewGroupInfo = ChatViewGroupInfo();
  ChatViewProfileSuccess(
      {required this.chatViewGroupInfo});
  @override
  List<Object> get props => [chatViewGroupInfo];
}

class SendInviteMemberLoading extends ChartState {
  const SendInviteMemberLoading();
  @override
  List<Object> get props => [];
}

class SendInviteMemberFailed extends ChartState {
  String message;
  SendInviteMemberFailed({required this.message});
  @override
  List<Object> get props => [message];
}
class SendInviteMemberSuccess extends ChartState {
  String message;
  SendInviteMemberSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class SendRemoveMemberLoading extends ChartState {
  const SendRemoveMemberLoading();
  @override
  List<Object> get props => [];
}

class SendRemoveMemberFailed extends ChartState {
  String message;
  SendRemoveMemberFailed({required this.message});
  @override
  List<Object> get props => [message];
}
class SendRemoveMemberSuccess extends ChartState {
  String message;
  SendRemoveMemberSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class ClearChatLoading extends ChartState {
  const ClearChatLoading();
  @override
  List<Object> get props => [];
}
class ClearChatSuccess extends ChartState {
  String message;
  ClearChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class ClearChatFailed extends ChartState {
  String message;
  ClearChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ArchiveChatLoading extends ChartState {
  const ArchiveChatLoading();
  @override
  List<Object> get props => [];
}
class ArchiveChatSuccess extends ChartState {
  String message;
  ArchiveChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class ArchiveChatFailed extends ChartState {
  String message;
  ArchiveChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class LeaveChatLoading extends ChartState {
  const LeaveChatLoading();
  @override
  List<Object> get props => [];
}
class LeaveChatSuccess extends ChartState {
  String message;
  LeaveChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class LeaveChatFailed extends ChartState {
  String message;
  LeaveChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ArchivedChartListLoading extends ChartState {
  const ArchivedChartListLoading();
  @override
  List<Object> get props => [];
}

class ArchivedChartListFailed extends ChartState {
  String message;
  ArchivedChartListFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ArchivedChartListSuccess extends ChartState {
  List<ChatList> chatList = [];
  ArchivedChartListSuccess({required this.chatList});
  @override
  List<Object> get props => [chatList];
}

class AcceptInviteChatLoading extends ChartState {
  const AcceptInviteChatLoading();
  @override
  List<Object> get props => [];
}
class AcceptInviteChatSuccess extends ChartState {
  String message;
  AcceptInviteChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class AcceptInviteChatFailed extends ChartState {
  String message;
  AcceptInviteChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}


class RejectInviteChatLoading extends ChartState {
  const RejectInviteChatLoading();
  @override
  List<Object> get props => [];
}
class RejectInviteChatSuccess extends ChartState {
  String message;
  RejectInviteChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class RejectInviteChatFailed extends ChartState {
  String message;
  RejectInviteChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class StartMessageSuccess extends ChartState {
  String chatId;
  StartMessageSuccess({required this.chatId});
  @override
  List<Object> get props => [chatId];
}
class StartMessageChatFailed extends ChartState {
  String message;
  StartMessageChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}



class DeleteGroupChatSuccess extends ChartState {
  String message;
  DeleteGroupChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class DeleteGroupChatFailed extends ChartState {
  String message;
  DeleteGroupChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}


class CancelInviteChatLoading extends ChartState {
  const CancelInviteChatLoading();
  @override
  List<Object> get props => [];
}
class CancelInviteSuccess extends ChartState {
  String message;
  CancelInviteSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class CancelInviteChatFailed extends ChartState {
  String message;
  CancelInviteChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}


class MarkAsAdminLoading extends ChartState {
  const MarkAsAdminLoading();
  @override
  List<Object> get props => [];
}
class MarkAsAdminSuccess extends ChartState {
  String message;
  MarkAsAdminSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class MarkAsAdminFailed extends ChartState {
  String message;
  MarkAsAdminFailed({required this.message});
  @override
  List<Object> get props => [message];
}


class UnArchiveChatSuccess extends ChartState {
  String message;
  UnArchiveChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class UnArchiveChatFailed extends ChartState {
  String message;
  UnArchiveChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class GroupBlocChatFailed extends ChartState {
  String message;
  GroupBlocChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class GroupBlocChatSuccess extends ChartState {
  String message;
  GroupBlocChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class GroupUnBlocChatFailed extends ChartState {
  String message;
  GroupUnBlocChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ReportChatSuccess extends ChartState {
  String message;
  ReportChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class ReportChatFailed extends ChartState {
  String message;
  ReportChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class GroupUnBlocChatSuccess extends ChartState {
  String message;
  GroupUnBlocChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}


class ChatBlockedListSuccess extends ChartState {
  List<ChatList> chatBlockedList = [];
  ChatBlockedListSuccess(
      {required this.chatBlockedList});
  @override
  List<Object> get props => [chatBlockedList];
}

class ChatBlockedListFalied extends ChartState {
  String message;
  ChatBlockedListFalied({required this.message});
  @override
  List<Object> get props => [message];
}
class GroupUnBlocChatLoading extends ChartState {
  const GroupUnBlocChatLoading();
  @override
  List<Object> get props => [];
}

class chartListSearchLoading extends ChartState {
  const chartListSearchLoading();
  @override
  List<Object> get props => [];
}


class chartListSearchFailed extends ChartState {
  String message;

  chartListSearchFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class chartListSearchSuccess extends ChartState {
  List<ChartSearchList> chartSearchList = [];
  int maxPageNumber;
  int maxPageSize;

  chartListSearchSuccess(
      {required this.chartSearchList,
        required this.maxPageNumber,
        required this.maxPageSize});
  @override
  List<Object> get props => [ChartSearchList,maxPageSize,maxPageNumber];
}


class DeleteChatSuccess extends ChartState {
  String message;
  DeleteChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class DeleteChatFailed extends ChartState {
  String message;
  DeleteChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ApproveChartRequestSuccess extends ChartState {
  String message;
  ApproveChartRequestSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class ApproveChartRequestFailed extends ChartState {
  String message;
  ApproveChartRequestFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class RejectChartRequestSuccess extends ChartState {
  String message;
  RejectChartRequestSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class RejectChartRequestFailed extends ChartState {
  String message;
  RejectChartRequestFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class AcceptInvitePublicChatRequestSuccess extends ChartState {
  String message;
  AcceptInvitePublicChatRequestSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class AcceptInvitePublicChatRequestFailed extends ChartState {
  String message;
  AcceptInvitePublicChatRequestFailed({required this.message});
  @override
  List<Object> get props => [message];
}


class RejectInvitePublicChatRequestFailed extends ChartState {
  String message;
  RejectInvitePublicChatRequestFailed({required this.message});
  @override
  List<Object> get props => [message];
}
class RejectInvitePublicChatRequestSuccess extends ChartState {
  String message;
  RejectInvitePublicChatRequestSuccess({required this.message});
  @override
  List<Object> get props => [message];
}