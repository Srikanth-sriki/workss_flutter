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
   ProfessionalListEvent(  {required this.page,
     required this.pageSize,
     required this.keyWord,
     required this.profession,
     required this.city,
     required this.gender});
  @override
  List<Object> get props => [page, pageSize, keyWord, gender, profession, city];
}
