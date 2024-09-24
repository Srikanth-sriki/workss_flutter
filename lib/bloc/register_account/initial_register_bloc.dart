import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:works_app/ui/onboarding/register_form.dart';
import '../../components/config.dart';
import '../../components/local_constant.dart';
import '../../dao/login_dao.dart';
import '../../helper/custom_log.dart';

part 'initial_register_event.dart';
part 'initial_register_state.dart';

class InitialRegisterBloc
    extends Bloc<InitialRegisterEvent, InitialRegisterState> {
  late LoginDao loginDao;
  InitialRegisterBloc() : super(InitialRegisterInitial()) {
    loginDao = LoginDao();

    on<UploadImageEvent>((event, emit) async {
      await mapUploadImageEvent(event, emit);
    });

    on<UploadMultipleImageEvent>((event, emit) async {
      await mapUploadMultipleImageEvent(event, emit);
    });

    on<RegisterAccountEvent>((event, emit) async {
      await mapRegisterAccountEvent(event, emit);
    });
  }

  Future<void> mapUploadImageEvent(
      UploadImageEvent event, Emitter<InitialRegisterState> emit) async {
    try {
      emit(const InitialRegisterLoading());
      var response =  await loginDao.uploadProfilePic(imagePath: event.imagePath);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String filePath = jsonDecoded["data"];
        emit(UploadImageSuccess(filePath: filePath));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["data"];
        customLog("The failure reason: $message");
        emit(UploadImageFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        emit(UploadImageFailed(message: message));
      }
    } catch (error) {
      customLog("The error of upload image is : $error");
      emit(UploadImageFailed(message: "Something Went Wrong"));
    }
  }


  Future<void> mapUploadMultipleImageEvent(
      UploadMultipleImageEvent event, Emitter<InitialRegisterState> emit) async {
    try {
      emit(const InitialRegisterLoading());
      var response =  await loginDao.uploadProfilePic(imagePath: event.imagePath);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String filePath = jsonDecoded["data"];
        emit(UploadMultipleImageSuccess(filePath: filePath));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["data"];
        customLog("The failure reason: $message");
        emit(UploadImageFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        emit(UploadImageFailed(message: message));
      }
    } catch (error) {
      customLog("The error of upload image is : $error");
      emit(UploadImageFailed(message: "Something Went Wrong"));
    }
  }

  Future<void> mapRegisterAccountEvent(
      RegisterAccountEvent event, Emitter<InitialRegisterState> emit) async {
    try {
      emit(const InitialRegisterLoading());
      var response = await loginDao.registerAccount(
          name: event.name,
          gender: event.gender,
          email: event.email,
          age: event.age,
          bio: event.bio,
          charge_type: event.charge_type,
          charges: event.charges,
          city: event.city,
          experienced_years: event.experienced_years,
          knownLanguages: event.known_languages,
          pincode: event.pincode,
          profession_type: event.profession_type,
          profile_pic: event.profile_pic,
          user_type: event.user_type,
          userLatitude: event.userLatitude,
          userLongitude: event.userLongitude,
          workImages: event.workImages);

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];

        bool profileCompleted = true;

        Config.profileCompleted = profileCompleted;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(LocalConstant.profileCompleted, profileCompleted);
        emit(InitialRegisterSuccess(message: message));
      } else if (jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];

        customLog("The failure reason: $message");
        emit(InitialRegisterFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        emit(InitialRegisterFailed(message: message));
      }
    } catch (error) {
      customLog("The error of register account is : $error");
      emit(InitialRegisterFailed(message: "Something Went Wrong"));
    }
  }
}
