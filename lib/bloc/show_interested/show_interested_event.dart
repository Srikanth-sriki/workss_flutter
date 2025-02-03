part of 'show_interested_bloc.dart';

@immutable

sealed class ShowInterestedEvent extends Equatable {
  const ShowInterestedEvent();
  @override
  List<Object> get props => [];
}

class SaveInterestedWork extends ShowInterestedEvent {
  String workID;
  bool contact;
  VoidCallback onSuccess;
  VoidCallback onError;
  SaveInterestedWork({
    required this.workID,
    required this.contact,required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [workID, contact,onSuccess,onError];
}


class ProfessionalContactUs extends ShowInterestedEvent {
  String PropId;
  VoidCallback onSuccess;
  VoidCallback onError;
  ProfessionalContactUs({
    required this.PropId, required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [PropId,onSuccess,onError];
}

class ProfessionalSavedUs extends ShowInterestedEvent {
  String PropId;
  VoidCallback onSuccess;
  VoidCallback onError;
  ProfessionalSavedUs({
    required this.PropId, required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [PropId,onSuccess,onError];
}


typedef CallbackWithMessage = void Function(String message);

class AddFriendEvent extends ShowInterestedEvent {
  String userId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  AddFriendEvent({
    required this.userId, required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [userId,onSuccess,onError];
}
class AcceptRequestFriendsEvent extends ShowInterestedEvent {
  String id;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  AcceptRequestFriendsEvent({
    required this.id, required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [id,onSuccess,onError];
}

class RejectRequestFriendsEvent extends ShowInterestedEvent {
  String id;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  RejectRequestFriendsEvent({
    required this.id, required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [id,onSuccess,onError];
}
class UnfriendsEvent extends ShowInterestedEvent {
  String friendId;
  CallbackWithMessage onSuccess;
  CallbackWithMessage onError;
  UnfriendsEvent({
    required this.friendId, required this.onSuccess,required this.onError
  });
  @override
  List<Object> get props => [friendId,onSuccess,onError];
}