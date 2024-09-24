part of 'login_bloc.dart';

@immutable
abstract class LoginState extends Equatable{
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState{
  const LoginLoading();

  @override
  List<Object> get props => [];
}

class LoginFailed extends LoginState{
  String message;

  LoginFailed({required this.message});

  @override
  List<Object> get props => [message];
}

class LoginSuccess extends LoginState{
  String phoneNumber;
  String countryCode;
  String otpToken;

  LoginSuccess({required this.phoneNumber, required this.countryCode,required this.otpToken});

  @override
  List<Object> get props => [phoneNumber,countryCode,otpToken];
}
