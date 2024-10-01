part of 'home_bloc.dart';

@immutable
sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

class HomeScreenLoading extends HomeState {
  const HomeScreenLoading();
  @override
  List<Object> get props => [];
}

class FetchHomeScreenFailed extends HomeState {
  String message;

  FetchHomeScreenFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchHomeScreenSuccess extends HomeState {
  List<HomeFetchModel> homeFetchModel = [];
  int maxPageNumber;
  int maxPageSize;

  FetchHomeScreenSuccess(
      {required this.homeFetchModel,
      required this.maxPageNumber,
      required this.maxPageSize});
  @override
  List<Object> get props => [homeFetchModel];
}

class WorkInterestedFailed extends HomeState {
  String message;
  WorkInterestedFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class WorkInterestedSuccess extends HomeState {
  String message;
  WorkInterestedSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class WorkInterestedLoading extends HomeState {
  const WorkInterestedLoading();
  @override
  List<Object> get props => [];
}