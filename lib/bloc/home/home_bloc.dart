import 'dart:convert';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:works_app/dao/home_dao.dart';
import 'package:works_app/helper/custom_log.dart';
import 'package:works_app/models/home_fetch_model.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late HomeDao homeDao;

  HomeBloc() : super(HomeInitial()) {
    homeDao = HomeDao();
    on<FetchHomeScreenEvent>((event, emit) async {
      await mapHomeScreenEvent(event, emit);
    });
    // on<SaveInterestedWork>((event, emit) async {
    //   await mapInterestedPropertyEvent(event, emit);
    // });
  }

  Future<void> mapHomeScreenEvent(
      FetchHomeScreenEvent event, Emitter<HomeState> emit) async {
    try {
      if (event.page == 1) {
        emit(const HomeScreenLoading());
      }

      var response = await homeDao.fetchHome(
          page: event.page,
          pageSize: event.pageSize,
          gender: event.gender,
          city: event.city,
          keyWord: event.keyWord,
          profession: event.profession);

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      customLog(jsonDecoded);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        int maxPageNumber = jsonDecoded["data"]["pagination"]["totalPages"];
        int maxPageSize = jsonDecoded["data"]["pagination"]["pageSize"];
        List<HomeFetchModel> homeFetchModel = [];
        for (var i in jsonDecoded["data"]["works"]) {
          homeFetchModel.add(HomeFetchModel.fromJson(i));
        }

        if (event.page > 1) {
          final currentState = state;
          if (currentState is FetchHomeScreenSuccess) {
            homeFetchModel = List.from(currentState.homeFetchModel)
              ..addAll(homeFetchModel);
          }
        }

        emit(FetchHomeScreenSuccess(
            homeFetchModel: homeFetchModel,
            maxPageNumber: maxPageNumber,
            maxPageSize: maxPageSize));
      } else {
        emit(FetchHomeScreenFailed(message: jsonDecoded["message"] ?? 'Error'));
      }
    } catch (error) {
      emit(FetchHomeScreenFailed(message: "Something went wrong"));
    }
  }

}
