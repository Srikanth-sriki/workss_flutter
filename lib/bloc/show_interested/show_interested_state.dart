part of 'show_interested_bloc.dart';

@immutable
sealed class ShowInterestedState extends Equatable {
  const ShowInterestedState();
  @override
  List<Object> get props => [];
}

final class ShowInterestedInitial extends ShowInterestedState {}

class WorkInterestedLoading extends ShowInterestedState {
  const WorkInterestedLoading();
  @override
  List<Object> get props => [];
}

class WorkInterestedFailed extends ShowInterestedState {
  String message;
  WorkInterestedFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class WorkInterestedSuccess extends ShowInterestedState {
  String message;
  WorkInterestedSuccess({required this.message});
  @override
  List<Object> get props => [message];
}


class ProfessionalContactFailed extends ShowInterestedState {
  String message;
  ProfessionalContactFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ProfessionalContactSuccess extends ShowInterestedState {
  String message;
  ProfessionalContactSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class ProfessionalSavedFailed extends ShowInterestedState {
  String message;
  ProfessionalSavedFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ProfessionalSavedSuccess extends ShowInterestedState {
  String message;
  ProfessionalSavedSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

///------------------------------------///


class AddFriendFailed extends ShowInterestedState {
  String message;
  AddFriendFailed({required this.message});
  @override
  List<Object> get props => [message];
}
class AddFriendSuccess extends ShowInterestedState {
  String message;
  AddFriendSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class AcceptRequestFriendsSuccess extends ShowInterestedState {
  String message;
  AcceptRequestFriendsSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class AcceptRequestFriendsFailed extends ShowInterestedState {
  String message;
  AcceptRequestFriendsFailed({required this.message});
  @override
  List<Object> get props => [message];
}


class UnfriendsSuccess extends ShowInterestedState {
  String message;
  UnfriendsSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class UnfriendsFailed extends ShowInterestedState {
  String message;
  UnfriendsFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class RejectRequestFriendsSuccess extends ShowInterestedState {
  String message;
  RejectRequestFriendsSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class RejectRequestFriendsFailed extends ShowInterestedState {
  String message;
  RejectRequestFriendsFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class UnSendFriendSuccess extends ShowInterestedState {
  String message;
  UnSendFriendSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class UnSendFriendFriendsFailed extends ShowInterestedState {
  String message;
  UnSendFriendFriendsFailed({required this.message});
  @override
  List<Object> get props => [message];
}



class SendJoinGroupChatLoading extends ShowInterestedState {
  const SendJoinGroupChatLoading();
  @override
  List<Object> get props => [];
}
class SendJoinGroupChatSuccess extends ShowInterestedState {
  String message;
  SendJoinGroupChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class SendJoinGroupChatFailed extends ShowInterestedState {
  String message;
  SendJoinGroupChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}


class CancelJoinRequestChatLoading extends ShowInterestedState {
  const CancelJoinRequestChatLoading();
  @override
  List<Object> get props => [];
}
class CancelJoinRequestChatSuccess extends ShowInterestedState {
  String message;
  CancelJoinRequestChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class CancelJoinRequestChatFailed extends ShowInterestedState {
  String message;
  CancelJoinRequestChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}


class AcceptSendInviteChatLoading extends ShowInterestedState {
  const AcceptSendInviteChatLoading();
  @override
  List<Object> get props => [];
}
class AcceptSendInviteChatSuccess extends ShowInterestedState {
  String message;
  AcceptSendInviteChatSuccess({required this.message});
  @override
  List<Object> get props => [message];
}
class AcceptSendInviteChatFailed extends ShowInterestedState {
  String message;
  AcceptSendInviteChatFailed({required this.message});
  @override
  List<Object> get props => [message];
}
