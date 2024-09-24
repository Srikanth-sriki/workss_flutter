part of 'login_bloc.dart';

@immutable
abstract class LoginEvent  extends Equatable{
  const LoginEvent();
  @override
  List<Object> get props => [];
}

class LoginWithPhoneNumber extends LoginEvent{
  String countryCode;
  String phoneNumber;

  LoginWithPhoneNumber({required this.countryCode,required this.phoneNumber});

  @override
  List<Object> get props => [countryCode,phoneNumber];
}