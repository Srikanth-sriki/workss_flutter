import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/config.dart';
import '../../components/global_handle.dart';
import '../../components/local_constant.dart';
import '../../dao/login_dao.dart';
import '../../helper/custom_log.dart';
import '../authentication/authentication_bloc.dart';

part 'login_otp_event.dart';
part 'login_otp_state.dart';

class LoginOtpBloc extends Bloc<LoginOtpEvent, LoginOtpState> {
  late LoginDao loginDao;
  LoginOtpBloc() : super(LoginOtpInitial()) {
    loginDao = LoginDao();
    on<VerifyOtpEvent>((event, emit) async {
      await mapVerifyOtpEvent(event, emit);
    });

    on<ResendOtpEvent>((event, emit) async {
      await mapResendOtpEvent(event, emit);
    });
  }
  Future<void> mapVerifyOtpEvent(
      VerifyOtpEvent event, Emitter<LoginOtpState> emit) async {
    try {
      emit(const LoginOtpLoading());
      var response = await loginDao.verifyOtp(otp: event.otp, otpToken: event.otpToken,fcmToken: event.fcmToken);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog("The response is : $jsonDecoded");
      customLog("The status Code : ${response.statusCode}");

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String accessToken = jsonDecoded["data"]["access_token"];
        String userId = jsonDecoded["data"]["userData"]["id"];
        bool profileCompleted = jsonDecoded["data"]["userData"]["is_registered"];
        String userType = jsonDecoded["data"]["userData"]["user_type"];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(LocalConstant.accessToken, accessToken);
        await prefs.setString(LocalConstant.userId, userId);
        await prefs.setBool(LocalConstant.profileCompleted, profileCompleted);
        await prefs.setString(LocalConstant.userType, userType);

        ///Update Config
        Config.accessToken = accessToken;
        Config.id = userId;
        Config.profileCompleted = profileCompleted;
        Config.userType = userType;

        print(Config.profileCompleted);
        emit(VerifyOtpSuccess(accessToken: accessToken,profileCompleted: profileCompleted));
        // if (profileCompleted == false) {
        //   GlobalBlocClass.authenticationBloc?.add(const AuthenticationRegisterAccountEvent());
        // } else {
        //   GlobalBlocClass.authenticationBloc?.add(const AuthenticationHomeScreenRedirectEvent());
        // }
      } else if (jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(VerifyOtpFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        emit(VerifyOtpFailed(message: message));
      }
    } catch (error) {
      customLog("The error of otp is : $error");
      emit(VerifyOtpFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapResendOtpEvent(
      ResendOtpEvent event, Emitter<LoginOtpState> emit) async {
    try {
      var response = await loginDao.resendOtp(otpToken: event.otpToken);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog("The response is : $jsonDecoded");
      customLog("The status Code : ${response.statusCode}");

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String otpToken = jsonDecoded["data"]["otp_token"];
        customLog("The new otp token: $otpToken");
        emit(ResendOtpSuccess(otpToken: otpToken));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(VerifyOtpFailed(message: "Something went wrong"));
      } else {
        emit(VerifyOtpFailed(message: "Something went wrong"));
      }
    } catch (error) {
      customLog("The error of resend otp is : $error");
      emit(VerifyOtpFailed(message: "Something went wrong"));
    }
  }
}
