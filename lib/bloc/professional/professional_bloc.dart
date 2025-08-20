import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:works_app/dao/home_dao.dart';
import 'package:works_app/models/category_list_modal.dart';
import 'package:works_app/models/professionals_list_model.dart';

import '../../core/intercepted_client.dart';
import '../../helper/custom_log.dart';
import '../../models/professional_view_model.dart';

part 'professional_event.dart';
part 'professional_state.dart';

class ProfessionalBloc extends Bloc<ProfessionalEvent, ProfessionalState> {
  late HomeDao homeDao;
  ProfessionalBloc() : super(ProfessionalInitial()) {
    homeDao = HomeDao();
    on<ProfessionalListEvent>((event, emit) async {
      await mapProfessionalListScreenEvent(event, emit);
    });
    on<FetchProfessionalView>((event, emit) async {
      await mapFetchProfessionalViewWorkEvent(event, emit);
    });
    on<FetchCategoryListEvent>((event, emit) async {
      await mapFetchCategoryList(event, emit);
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
          keyWord: event.keyWord,currentLatitude: event.currentLatitude,currentLongitude: event.currentLongitude,
          knownLanguages: event.knownLanguages,
          profession: event.profession);
      if (response.statusCode != 200) {
        throw Exception(
            "Failed to load data, status code: ${response.statusCode}");
      }

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(jsonDecoded);
      handleAuthFailure(response.statusCode, jsonDecoded);

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

  Future<void> mapFetchProfessionalViewWorkEvent(
      FetchProfessionalView event, Emitter<ProfessionalState> emit) async {
    try {
      emit(const ProfessionalViewLoading());
      var response = await homeDao.fetchProfessionalView(professionalId: event.professionalId);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(response);
      handleAuthFailure(response.statusCode, jsonDecoded);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        ProfessionalViewModel professionalViewModel;
        professionalViewModel = ProfessionalViewModel.fromJson(jsonDecoded["data"]);
        emit(ProfessionalViewSuccess(professionalViewModel));

      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(ProfessionalViewError(message));
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(const ProfessionalViewError("Something Went wrong"));
    }
  }

  Future<void> mapFetchCategoryList(
      FetchCategoryListEvent event, Emitter<ProfessionalState> emit) async {
    try {
      emit(const FetchCategoryListLoading());
      var response = await homeDao.getCategoryList();
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
        if (jsonDecoded['status'] == true) {
          FetchCategoryModalData categoryData =
          FetchCategoryModalData.fromJson(jsonDecoded);

          emit(FetchCategoryListSuccess(categories: categoryData.data));
        } else {
          emit(FetchCategoryListFailed(
              message: jsonDecoded["message"] ?? "Failed to fetch data"));
        }
      } else {
        emit(FetchCategoryListFailed(message: "Error: ${response.statusCode}"));
      }
    } catch (error) {
      emit(FetchCategoryListFailed(message: "Something went wrong: $error"));
    }
  }

}
