part of 'professional_bloc.dart';

@immutable
sealed class ProfessionalState extends Equatable{
  const ProfessionalState();
  @override
  List<Object> get props => [];
}

final class ProfessionalInitial extends ProfessionalState {}

class ProfessionalLoading extends ProfessionalState {
  const ProfessionalLoading();
  @override
  List<Object> get props => [];
}

class FetchProfessionalListFailed extends ProfessionalState {
  String message;
  FetchProfessionalListFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FetchProfessionalListSuccess extends ProfessionalState {
  List<ProfessionalsPostedWork> professionalsPostedWork = [];
  int maxPageNumber;
  int maxPageSize;

  FetchProfessionalListSuccess(
      {required this.professionalsPostedWork,
        required this.maxPageNumber,
        required this.maxPageSize});
  @override
  List<Object> get props => [professionalsPostedWork,maxPageNumber,maxPageSize];
}
