import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:works_app/models/pincode_list_modal.dart';
import 'package:works_app/ui/onboarding/register_form.dart';
import '../../components/config.dart';
import '../../components/local_constant.dart';
import '../../dao/login_dao.dart';
import '../../dao/profile_dao.dart';
import '../../helper/custom_log.dart';
import '../../models/dropDown_modal.dart';

part 'initial_register_event.dart';
part 'initial_register_state.dart';

class InitialRegisterBloc
    extends Bloc<InitialRegisterEvent, InitialRegisterState> {
  late LoginDao loginDao;
  late ProfileDao profileDao;
  InitialRegisterBloc() : super(InitialRegisterInitial()) {
    loginDao = LoginDao();
    profileDao = ProfileDao();

    on<UploadImageEvent>((event, emit) async {
      await mapUploadImageEvent(event, emit);
    });

    on<UploadMultipleImageEvent>((event, emit) async {
      await mapUploadMultipleImageEvent(event, emit);
    });

    on<RegisterAccountEvent>((event, emit) async {
      await mapRegisterAccountEvent(event, emit);
    });

    on<FetchCityEvent>((event, emit) async {
      await mapFetchCityWorksPlace(event, emit);
    });
    on<FetchChargeFeesEvent>((event, emit) async {
      await mapFetchFeesChargePlace(event, emit);
    });
    on<FetchWorkKnownLanguageProfileEvent>((event, emit) async {
      await mapFetchKnownLanguagePlace(event, emit);
    });
    on<FetchPinListEvent>((event, emit) async {
      await mapFetchPinCodeListPlace(event, emit);
    });
    on<FetchLocalitiesListEvent>((event, emit) async {
      await mapFetchLocalityListPlace(event, emit);
    });
  }

  Future<void> mapUploadImageEvent(
      UploadImageEvent event, Emitter<InitialRegisterState> emit) async {
    try {
      emit(const InitialRegisterLoading());
      var response =
          await loginDao.uploadProfilePic(imagePath: event.imagePath);
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

  Future<void> mapUploadMultipleImageEvent(UploadMultipleImageEvent event,
      Emitter<InitialRegisterState> emit) async {
    try {
      emit(const InitialRegisterLoading());
      var response =
          await loginDao.uploadProfilePic(imagePath: event.imagePath);
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
        String userType = jsonDecoded["data"]["user_type"];
        bool profileCompleted = true;

        Config.profileCompleted = profileCompleted;
        Config.userType = userType;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(LocalConstant.profileCompleted, profileCompleted);
        await prefs.setString(LocalConstant.userType, userType);
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

  Future<void> mapFetchCityWorksPlace(
      FetchCityEvent event, Emitter<InitialRegisterState> emit) async {
    try {
      emit(const FetchCityLoading());
      var response = await loginDao.fetchCityLanguage();
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
        if (jsonDecoded['status'] == true) {
          FetchCityDropDown fetchDropDown =
              FetchCityDropDown.fromJson(jsonDecoded);
          emit(FetchCitySuccess(
            dropDownItems: fetchDropDown.data,
            message: fetchDropDown.message,
          ));
        } else {
          emit(FetchCityFailed(
              message: jsonDecoded["message"] ?? "Failed to fetch data"));
        }
      } else {
        emit(FetchCityFailed(message: "Error: ${response.statusCode}"));
      }
    } catch (error) {
      emit(FetchCityFailed(message: "Something went wrong: $error"));
    }
  }

  Future<void> mapFetchFeesChargePlace(
      FetchChargeFeesEvent event, Emitter<InitialRegisterState> emit) async {
    try {
      emit(const FetchChargeFeesLoading());
      var response = await loginDao.fetchFessCharges();
      customLog(response);
      customLog('11111111111111111111111111111111111');
      customLog(response.statusCode);
      customLog(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
        if (jsonDecoded['status'] == true) {
          FetchFeesChargeDropDown fetchFeesChargeDropDown =
              FetchFeesChargeDropDown.fromJson(jsonDecoded);
          emit(FetchChargeFeesSuccess(
            fetchChargeFeesItems: fetchFeesChargeDropDown.data,
            message: fetchFeesChargeDropDown.message,
          ));
        } else {
          emit(FetchChargeFeesFailed(
              message: jsonDecoded["message"] ?? "Failed to fetch data"));
        }
      } else {
        emit(FetchChargeFeesFailed(message: "Error: ${response.statusCode}"));
      }
    } catch (error) {
      emit(FetchChargeFeesFailed(message: "Something went wrong: $error"));
    }
  }

  Future<void> mapFetchKnownLanguagePlace(FetchWorkKnownLanguageProfileEvent event,
      Emitter<InitialRegisterState> emit) async {
    try {
      emit(const FetchDropDownLoading());
      var response = await profileDao.fetchKnownLanguage();
      customLog(response);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
        if (jsonDecoded['status'] == true) {
          FetchKnownLanguageDropDown fetchKnownLanguageDropDown =
              FetchKnownLanguageDropDown.fromJson(jsonDecoded);
          emit(FetchKnownLanguageSuccess(
            dropDownItems: fetchKnownLanguageDropDown.data,
            message: fetchKnownLanguageDropDown.message,
          ));
        } else {
          emit(FetchDropDownFailed(
              message: jsonDecoded["message"] ?? "Failed to fetch data"));
        }
      } else {
        emit(FetchDropDownFailed(message: "Error: ${response.statusCode}"));
      }
    } catch (error) {
      emit(FetchDropDownFailed(message: "Something went wrong: $error"));
    }
  }


  Future<void> mapFetchPinCodeListPlace(FetchPinListEvent event,
      Emitter<InitialRegisterState> emit) async {
    try {
      emit(const FetchPinListLoading());
      var response = await profileDao.fetchPinCodeList(cityID: event.cityId);
      customLog(response);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
        if (jsonDecoded['status'] == true) {
          List<PincodeListModal> dropDownItems = (jsonDecoded['data'] as List)
              .map((notification) => PincodeListModal.fromJson(notification))
              .toList();
          emit(FetchPinListSuccess(
            dropDownItems: dropDownItems,message: jsonDecoded["message"]
          ));
        } else {
          emit(FetchDropDownFailed(
              message: jsonDecoded["message"] ?? "Failed to fetch data"));
        }
      } else {
        emit(FetchDropDownFailed(message: "Error: ${response.statusCode}"));
      }
    } catch (error) {
      emit(FetchDropDownFailed(message: "Something went wrong: $error"));
    }
  }

  Future<void> mapFetchLocalityListPlace(FetchLocalitiesListEvent event,
      Emitter<InitialRegisterState> emit) async {
    try {
      emit(const FetchLocalitiesListLoading());
      var response = await profileDao.fetchLocalitieCodeList(cityID: event.cityId);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

        if (jsonDecoded['status'] == true) {
          List<PincodeListModal> dropDownItems = (jsonDecoded['data'] as List)
              .map((notification) => PincodeListModal.fromJson(notification))
              .toList();
          emit(FetchLocalitiesListSuccess(
              dropDownItems: dropDownItems,message: jsonDecoded["message"]
          ));
        } else {
          emit(FetchLocalitiesListFailed(
              message: jsonDecoded["message"] ?? "Failed to fetch data"));
        }
      } else {
        emit(FetchLocalitiesListFailed(message: "Error: ${response.statusCode}"));
      }
    } catch (error) {
      emit(FetchLocalitiesListFailed(message: "Something went wrong: $error"));
    }
  }
}
