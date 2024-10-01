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

  FetchHomeScreenEvent(
      {required this.page,
      required this.pageSize,
      required this.keyWord,
      required this.profession,
      required this.city,
      required this.gender});
  @override
  List<Object> get props => [page, pageSize, keyWord, gender, profession, city];
}

class SaveInterestedWork extends HomeEvent {
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
