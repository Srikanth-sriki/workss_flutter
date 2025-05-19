import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:works_app/models/app_version_modal.dart';

import '../../components/config.dart';
import '../../components/local_constant.dart';
import '../../dao/login_dao.dart';
import '../../helper/custom_log.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  late LoginDao loginDao;
  LoginBloc() : super(LoginInitial()) {
    loginDao = LoginDao();
    on<LoginWithPhoneNumber>((event, emit) async {
      await mapLoginWithPhoneNumber(event, emit);
    });
    on<AppVersionCheck>((event, emit) async {
      await mapAppVersioncheck(event, emit);
    });
  }
  Future<void> mapLoginWithPhoneNumber(
      LoginWithPhoneNumber event, Emitter<LoginState> emit) async {
    try {
      emit(const LoginLoading());
      var response = await loginDao.login(
          countryCode: event.countryCode, phoneNumber: event.phoneNumber);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(
          "The status Code : ${response.statusCode} ,The status:${jsonDecoded['status']}");
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String otpToken = jsonDecoded["data"]["otp_token"];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(LocalConstant.phoneNumber, event.phoneNumber);
        Config.phoneNumber = event.phoneNumber;

        emit(LoginSuccess(
            phoneNumber: event.phoneNumber,
            countryCode: event.countryCode,
            otpToken: otpToken));
      } else if (jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(LoginFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(LoginFailed(message: message));
      }
    } catch (error) {
      customLog("The error of login : $error");
      emit(LoginFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapAppVersioncheck(
      AppVersionCheck event, Emitter<LoginState> emit) async {
    try {
      var response = await loginDao.fetchAppVersions();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        List<AppVersion> appVersion = [];
        for (var i in jsonDecoded["data"]) {
          appVersion.add(AppVersion.fromJson(i));
        }
        emit(AppVersionSuccess(appVersion: appVersion));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(AppVersionFailed(message: message));
      } else {
        emit(AppVersionFailed(message: '"Something Went wrong"'));
      }
    } catch (error) {
      customLog("The error of resend otp is : $error");
      emit(AppVersionFailed(message: "Something Went wrong"));
    }
  }
}
