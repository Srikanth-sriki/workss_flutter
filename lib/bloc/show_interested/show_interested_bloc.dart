import 'dart:convert';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../dao/home_dao.dart';

part 'show_interested_event.dart';
part 'show_interested_state.dart';

class ShowInterestedBloc
    extends Bloc<ShowInterestedEvent, ShowInterestedState> {
  late HomeDao homeDao;
  ShowInterestedBloc() : super(ShowInterestedInitial()) {
    homeDao = HomeDao();
    on<SaveInterestedWork>((event, emit) async {
      await mapInterestedPropertyEvent(event, emit);
    });

    on<ProfessionalContactUs>((event, emit) async {
      await mapProfessionalContactUsEvent(event, emit);
    });

    on<ProfessionalSavedUs>((event, emit) async {
      await mapProfessionalSavedUsEvent(event, emit);
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
}
