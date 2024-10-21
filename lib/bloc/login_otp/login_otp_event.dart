part of 'login_otp_bloc.dart';

@immutable
abstract class LoginOtpEvent extends Equatable {
  const LoginOtpEvent();
  @override
  List<Object> get props => [];
}

class VerifyOtpEvent extends LoginOtpEvent {
  String otp;
  String otpToken;
  String fcmToken;
  VerifyOtpEvent({required this.otp, required this.otpToken,required this.fcmToken});
  @override
  List<Object> get props => [otp, otpToken,fcmToken];
}

class ResendOtpEvent extends LoginOtpEvent {
  String otpToken;
  ResendOtpEvent({required this.otpToken});
  @override
  List<Object> get props => [otpToken];
}
