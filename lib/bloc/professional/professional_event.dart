part of 'professional_bloc.dart';

@immutable
sealed class ProfessionalEvent extends Equatable {
  const ProfessionalEvent();
  @override
  List<Object> get props => [];
}

class ProfessionalListEvent extends ProfessionalEvent {
  int page;
  int pageSize;
  String keyWord;
  String gender;
  String profession;
  String city;
  String currentLongitude;
  String currentLatitude;
  List<String> knownLanguages;
   ProfessionalListEvent(  {required this.page,
     required this.pageSize,
     required this.keyWord,
     required this.profession,
     required this.city,
     required this.gender,
     required this.currentLongitude,
     required this.currentLatitude,
     required this.knownLanguages
   });
  @override
  List<Object> get props => [page, pageSize, keyWord, gender, profession, city,currentLongitude,currentLatitude,knownLanguages];
}


class FetchProfessionalView extends ProfessionalEvent {
  final String professionalId;

  const FetchProfessionalView(this.professionalId);

  @override
  List<Object> get props => [professionalId];
}


class FetchCategoryListEvent extends ProfessionalEvent {
  const FetchCategoryListEvent();
  @override
  List<Object> get props => [];
}