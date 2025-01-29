import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../dao/home_dao.dart';

part 'report_post_event.dart';
part 'report_post_state.dart';

class ReportPostBloc extends Bloc<ReportPostEvent, ReportPostState> {
  late HomeDao homeDao;
  ReportPostBloc() : super(ReportPostInitial()) {
    homeDao = HomeDao();
    on<ReportWorkPostEvent>((event, emit) async {
      await mapReportPostEvent(event, emit);
    });
    on<ReportProfessionalEvent>((event, emit) async {
      await mapReportProfessionalEvent(event, emit);
    });
  }
  Future<void> mapReportPostEvent(
      ReportWorkPostEvent event, Emitter<ReportPostState> emit) async {
    try {
      emit(const ReportWorkPostLoading());
      var response =
          await homeDao.reportWorkPost(id: event.workId, reason: event.reason);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(ReportWorkPostSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(ReportWorkPostFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(ReportWorkPostFailed(message: message));
      }
    } catch (error) {
      emit(ReportWorkPostFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapReportProfessionalEvent(
      ReportProfessionalEvent event, Emitter<ReportPostState> emit) async {
    try {
      emit(const ReportWorkPostLoading());
      var response =
      await homeDao.reportProfessionalPost(id: event.userId, reason: event.reason);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(ReportWorkPostSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(ReportWorkPostFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(ReportWorkPostFailed(message: message));
      }
    } catch (error) {
      emit(ReportWorkPostFailed(message: "Something went wrong"));
    }
  }
}
