import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:works_app/dao/home_dao.dart';
import 'package:works_app/models/professionals_list_model.dart';

import '../../helper/custom_log.dart';

part 'professional_event.dart';
part 'professional_state.dart';

class ProfessionalBloc extends Bloc<ProfessionalEvent, ProfessionalState> {
  late HomeDao homeDao;
  ProfessionalBloc() : super(ProfessionalInitial()) {
    homeDao = HomeDao();
    on<ProfessionalListEvent>((event, emit) async {
      await mapProfessionalListScreenEvent(event, emit);
    });
  }

  Future<void> mapProfessionalListScreenEvent(
      ProfessionalListEvent event, Emitter<ProfessionalState> emit) async {
    try {
      if (event.page == 1) {
        emit(const ProfessionalLoading());
      }

      var response = await homeDao.fetchProfessional(
          page: event.page,
          pageSize: event.pageSize,
          gender: event.gender,
          city: event.city,
          keyWord: event.keyWord,
          profession: event.profession);
      if (response.statusCode != 200) {
        throw Exception(
            "Failed to load data, status code: ${response.statusCode}");
      }

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(jsonDecoded);

      if (jsonDecoded['status'] == true) {
        int maxPageNumber = jsonDecoded["data"]["pagination"]["totalPages"];
        int maxPageSize = jsonDecoded["data"]["pagination"]["pageSize"];
        List<ProfessionalsPostedWork> professionalsPostedWork = [];

        for (var i in jsonDecoded["data"]["professionals"]) {
          professionalsPostedWork.add(ProfessionalsPostedWork.fromJson(i));
        }

        if (event.page > 1) {
          final currentState = state;
          if (currentState is FetchProfessionalListSuccess) {
            professionalsPostedWork =
                List.from(currentState.professionalsPostedWork)
                  ..addAll(professionalsPostedWork);
          }
        }

        emit(FetchProfessionalListSuccess(
            professionalsPostedWork: professionalsPostedWork,
            maxPageNumber: maxPageNumber,
            maxPageSize: maxPageSize));
      } else {
        emit(FetchProfessionalListFailed(
            message: jsonDecoded["message"] ?? 'Error fetching data'));
      }
    } catch (error) {
      emit(
          FetchProfessionalListFailed(message: "Something went wrong: $error"));
    }
  }
}
