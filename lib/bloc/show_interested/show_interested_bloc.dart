import 'dart:convert';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../dao/friends_dao.dart';
import '../../dao/home_dao.dart';

part 'show_interested_event.dart';
part 'show_interested_state.dart';

class ShowInterestedBloc
    extends Bloc<ShowInterestedEvent, ShowInterestedState> {
  late HomeDao homeDao;
  late FriendsDao friendsDao;
  ShowInterestedBloc() : super(ShowInterestedInitial()) {
    homeDao = HomeDao();
    friendsDao = FriendsDao();
    on<SaveInterestedWork>((event, emit) async {
      await mapInterestedPropertyEvent(event, emit);
    });

    on<ProfessionalContactUs>((event, emit) async {
      await mapProfessionalContactUsEvent(event, emit);
    });

    on<ProfessionalSavedUs>((event, emit) async {
      await mapProfessionalSavedUsEvent(event, emit);
    });

    on<AddFriendEvent>((event, emit) async {
      await mapAddFriendsEvent(event, emit);
    });

    on<AcceptRequestFriendsEvent>((event, emit) async {
      await mapAcceptRequestEvent(event, emit);
    });

    on<RejectRequestFriendsEvent>((event, emit) async {
      await mapRejectRequestEvent(event, emit);
    });

    on<UnfriendsEvent>((event, emit) async {
      await mapUnfriendEvent(event, emit);
    });

    on<UnSendFriendEvent>((event, emit) async {
      await mapUnSendFriendEvent(event, emit);
    });
  }

  Future<void> mapInterestedPropertyEvent(
      SaveInterestedWork event, Emitter<ShowInterestedState> emit) async {
    try {
      emit(const WorkInterestedLoading());
      var response = await homeDao.saveInterested(
          workID: event.workID, contact: event.contact);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess();
        emit(WorkInterestedSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError();
        emit(WorkInterestedFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError();
        emit(WorkInterestedFailed(message: message));
      }
    } catch (error) {
      emit(WorkInterestedFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapProfessionalContactUsEvent(
      ProfessionalContactUs event, Emitter<ShowInterestedState> emit) async {
    try {
      emit(const WorkInterestedLoading());
      var response =
          await homeDao.professionalContactUs(professionalId: event.PropId);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess();
        emit(ProfessionalContactSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError();
        emit(ProfessionalContactFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError();
        emit(ProfessionalContactFailed(message: message));
      }
    } catch (error) {
      emit(ProfessionalContactFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapProfessionalSavedUsEvent(
      ProfessionalSavedUs event, Emitter<ShowInterestedState> emit) async {
    try {
      emit(const WorkInterestedLoading());
      var response =
          await homeDao.professionalSavedUs(professionalId: event.PropId);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess();
        emit(ProfessionalSavedSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError();
        emit(ProfessionalSavedFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError();
        emit(ProfessionalSavedFailed(message: message));
      }
    } catch (error) {
      emit(ProfessionalSavedFailed(message: "Something went wrong"));
    }
  }
  
  ///----------------------------------------------------------------------------------/////



  Future<void> mapAddFriendsEvent(
      AddFriendEvent event, Emitter<ShowInterestedState> emit) async {
    try {
      emit(const WorkInterestedLoading());
      var response =
      await friendsDao.addFriends(userId: event.userId);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(AddFriendSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(AddFriendFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(AddFriendFailed(message: message));
      }
    } catch (error) {
      emit(AddFriendFailed(message: "Something went wrong"));
    }
  }



  Future<void> mapAcceptRequestEvent(
      AcceptRequestFriendsEvent event, Emitter<ShowInterestedState> emit) async {
    try {
      emit(const WorkInterestedLoading());
      var response =
      await friendsDao.acceptRequestFriend(id: event.id);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(AcceptRequestFriendsSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(AcceptRequestFriendsFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(AcceptRequestFriendsFailed(message: message));
      }
    } catch (error) {
      emit(AcceptRequestFriendsFailed(message: "Something went wrong"));
    }
  }



  Future<void> mapRejectRequestEvent(
      RejectRequestFriendsEvent event, Emitter<ShowInterestedState> emit) async {
    try {
      emit(const WorkInterestedLoading());
      var response =
      await friendsDao.rejectRequestFriends(id: event.id);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(RejectRequestFriendsSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(RejectRequestFriendsFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(RejectRequestFriendsFailed(message: message));
      }
    } catch (error) {
      emit(RejectRequestFriendsFailed(message: "Something went wrong"));
    }
  }




  Future<void> mapUnfriendEvent(
      UnfriendsEvent event, Emitter<ShowInterestedState> emit) async {
    try {
      emit(const WorkInterestedLoading());
      var response =
      await friendsDao.unfriends(friendId: event.friendId);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(UnfriendsSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(UnfriendsFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(UnfriendsFailed(message: message));
      }
    } catch (error) {
      emit(UnfriendsFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapUnSendFriendEvent(
      UnSendFriendEvent event, Emitter<ShowInterestedState> emit) async {
    try {
      emit(const WorkInterestedLoading());
      var response =
      await friendsDao.unSendFriendRequest(userId: event.userId);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(UnSendFriendSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(UnSendFriendFriendsFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(UnSendFriendFriendsFailed(message: message));
      }
    } catch (error) {
      emit(UnSendFriendFriendsFailed(message: "Something went wrong"));
    }
  }

}
