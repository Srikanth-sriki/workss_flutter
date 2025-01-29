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

