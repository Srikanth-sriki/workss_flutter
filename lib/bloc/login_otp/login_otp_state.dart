part of 'login_otp_bloc.dart';

@immutable
abstract class LoginOtpState extends Equatable{
  const LoginOtpState();
  @override
  List<Object> get props => [];
}

class LoginOtpInitial extends LoginOtpState {}

class LoginOtpLoading extends LoginOtpState {
  const LoginOtpLoading();
  @override
  List<Object> get props => [];
}

class VerifyOtpFailed extends LoginOtpState{
  String message;

  VerifyOtpFailed({required this.message});

  @override
  List<Object> get props => [message];
}


class VerifyOtpSuccess extends LoginOtpState{
  String accessToken;

  VerifyOtpSuccess({required this.accessToken});

  @override
  List<Object> get props => [];
}

class ResendOtpSuccess extends LoginOtpState{
  String otpToken;

  ResendOtpSuccess({required this.otpToken});

  @override
  List<Object> get props => [otpToken];
}