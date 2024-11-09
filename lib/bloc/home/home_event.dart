part of 'home_bloc.dart';

@immutable
sealed class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class FetchHomeScreenEvent extends HomeEvent {
  int page;
  int pageSize;
  String keyWord;
  String gender;
  String profession;
  String city;
  String currentLongitude;
  String currentLatitude;

  FetchHomeScreenEvent({
    required this.page,
    required this.pageSize,
    required this.keyWord,
    required this.profession,
    required this.city,
    required this.gender,
    required this.currentLongitude,
    required this.currentLatitude,
  });
  @override
  List<Object> get props => [page, pageSize, keyWord, gender, profession, city,currentLongitude,currentLatitude];
}

class FetchWorkSingleView extends HomeEvent {
  final String workId;

  const FetchWorkSingleView({required this.workId});

  @override
  List<Object> get props => [workId];
}
