import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:works_app/models/faq_model.dart';
import 'package:works_app/models/fetch_posted_view.dart';
import 'package:works_app/models/fetch_posted_work.dart';
import 'package:works_app/models/setting_fetch_model.dart';

import '../../components/config.dart';
import '../../components/local_constant.dart';
import '../../dao/profile_dao.dart';
import '../../helper/custom_log.dart';
import '../../models/fetch_profile_model.dart';
import '../../models/professionals_list_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  late ProfileDao profileDao;
  ProfileBloc() : super(ProfileInitial()) {
    profileDao = ProfileDao();
    on<FetchProfileEvent>((event, emit) async {
      await mapFetchProfileEvent(event, emit);
    });
    on<FetchPostedEvent>((event, emit) async {
      await mapPostedWorksEvent(event, emit);
    });
    on<FetchInterestedWorkEvent>((event, emit) async {
      await mapInterestedWorksEvent(event, emit);
    });
    on<FetchSavedWorkEvent>((event, emit) async {
      await mapSavedWorksEvent(event, emit);
    });
    on<EditProfileAccount>((event, emit) async {
      await mapEditRegisterAccountEvent(event, emit);
    });
    on<FetchPostViewEvent>((event, emit) async {
      await mapFetchPostedViewWorkEvent(event, emit);
    });
    on<DeleteAccount>((event, emit) async {
      await mapAccountDeleteEvent(event, emit);
    });
    on<NotificationSettingEvent>((event, emit) async {
      await mapNotificationSettingEvent(event, emit);
    });

    on<FetchFaqEvent>((event, emit) async {
      await mapFetchFaqEvent(event, emit);
    });

    on<ContactUsEvent>((event, emit) async {
      await mapContactUsEvent(event, emit);
    });

    on<FetchSettingEvent>((event, emit) async {
      await mapFetchSettingEvent(event, emit);
    });

    on<FetchSavedProfessionalEvent>((event, emit) async {
      await mapFetchSavedProfessionalsEvent(event, emit);
    });

  }

  Future<void> mapFetchProfileEvent(
      FetchProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      var response = await profileDao.fetchProfile();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(response);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        Config.phoneNumber = jsonDecoded["data"]["mobile"] ?? "";
        Config.name = jsonDecoded["data"]["name"] ?? "";
        ProfileFetch profileFetch;
        profileFetch = ProfileFetch.fromJson(jsonDecoded["data"]);
        emit(FetchProfileSuccess(profileFetch: profileFetch));
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(FetchProfileFailed(message: message));
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(FetchProfileFailed(message: "Something Went wrong"));
    }
  }

  // Future<void> mapEditProfileEvent(
  //     EditProfileEvent event, Emitter<ProfileState> emit) async {
  //   try{
  //     emit(const ProfileLoading());
  //     var response = await profileDao.editProfile(
  //         name: event.name,
  //         countryCode: event.countryCode,
  //         phoneNumber: event.phoneNumber,
  //         profilePhoto: event.profilePhoto,
  //         email: event.email);
  //
  //     Map<String,dynamic> jsonDecoded = jsonDecode(response.body);
  //
  //     if(response.statusCode == 200 && jsonDecoded['status'] == true){
  //       bool profileCompleted = true;
  //
  //       ///Update Config and Local storage
  //       Config.profileCompleted = profileCompleted;
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setBool(LocalConstant.profileCompleted, profileCompleted);
  //
  //       emit(const EditProfileSuccess());
  //     }else if(response.statusCode == 200 && jsonDecoded['status'] == false){
  //       String message = jsonDecoded["message"];
  //       customLog("The reason: $message");
  //       emit(EditProfileFailed(message: message));
  //     }else{
  //       String message = jsonDecoded["message"];
  //       emit(EditProfileFailed(message: message));
  //     }
  //   }catch(error){
  //     customLog("The Profile edit error : $error");
  //     emit(EditProfileFailed(message: "Something Went Wrong"));
  //   }
  //}

  Future<void> mapPostedWorksEvent(
      FetchPostedEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      var response = await profileDao.fetchPostedWork();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        List<FetchPostedModel> fetchPostedModel = [];
        for (var i in jsonDecoded["data"]) {
          fetchPostedModel.add(FetchPostedModel.fromJson(i));
        }
        emit(FetchPostedWorkSuccess(fetchPostedModel: fetchPostedModel));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(FetchPostedWorkFailed(message: message));
      } else {
        emit(FetchPostedWorkFailed(message: '"Something Went wrong"'));
      }
    } catch (error) {
      customLog("The error of resend otp is : $error");
      emit(FetchPostedWorkFailed(message: "Something Went wrong"));
    }
  }

  Future<void> mapInterestedWorksEvent(
      FetchInterestedWorkEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      var response = await profileDao.fetchInterestedWork();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        List<FetchPostedModel> fetchPostedModel = [];
        for (var i in jsonDecoded["data"]) {
          fetchPostedModel.add(FetchPostedModel.fromJson(i));
        }
        emit(FetchInterestedWorkSuccess(fetchPostedModel: fetchPostedModel));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(FetchInterestedWorkFailed(message: message));
      } else {
        emit(FetchInterestedWorkFailed(message: '"Something Went wrong"'));
      }
    } catch (error) {
      customLog("The error of resend otp is : $error");
      emit(FetchInterestedWorkFailed(message: "Something Went wrong"));
    }
  }

  Future<void> mapSavedWorksEvent(
      FetchSavedWorkEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      var response = await profileDao.fetchSavedWork();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        List<FetchPostedModel> fetchPostedModel = [];
        for (var i in jsonDecoded["data"]) {
          fetchPostedModel.add(FetchPostedModel.fromJson(i));
        }
        emit(FetchSavedWorkSuccess(fetchPostedModel: fetchPostedModel));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(FetchSavedWorkFailed(message: message));
      } else {
        emit(FetchSavedWorkFailed(message: '"Something Went wrong"'));
      }
    } catch (error) {
      customLog("The error of resend otp is : $error");
      emit(FetchSavedWorkFailed(message: "Something Went wrong"));
    }
  }

  Future<void> mapEditRegisterAccountEvent(
      EditProfileAccount event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      var response = await profileDao.profileAccountEdit(
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
        emit(EditProfileSuccess(message: message));
      } else if (jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];

        customLog("The failure reason: $message");
        emit(EditProfileFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        emit(EditProfileFailed(message: message));
      }
    } catch (error) {
      customLog("The error of register account is : $error");
      emit(EditProfileFailed(message: "Something Went Wrong"));
    }
  }

  Future<void> mapFetchPostedViewWorkEvent(
      FetchPostViewEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const PostedWorkViewLoading());
      var response = await profileDao.fetchPostedView(workId: event.workId);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(response);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        ViewFetchPostedWork viewFetchPostedWork;
        viewFetchPostedWork = ViewFetchPostedWork.fromJson(jsonDecoded["data"]);
        emit(FetchPostedViewWorkSuccess(
            viewFetchPostedWork: viewFetchPostedWork));
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(FetchPostedViewWorkFailed(message: message));
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(FetchPostedViewWorkFailed(message: "Something Went wrong"));
    }
  }

  Future<void> mapAccountDeleteEvent(
      DeleteAccount event, Emitter<ProfileState> emit) async {
    try {
      emit(const PostedWorkViewLoading());
      var response = await profileDao.accountDelete(reason: event.reason);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess();
        emit(DeleteAccountSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError();
        emit(DeleteAccountFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError();
        emit(DeleteAccountFailed(message: message));
      }
    } catch (error) {
      emit(DeleteAccountFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapNotificationSettingEvent(
      NotificationSettingEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const NotificationSettingLoading());
      var response = await profileDao.notificationSetting(
          workPostedInCity: event.workPostedInCity,
          workViewedIntrestShowed: event.workViewedIntrestShowed,
          friendRequest: event.friendRequest,
          newClipsFromFriends: event.newClipsFromFriends,
          newFriendSuggestions: event.newFriendSuggestions,
          msgRecevied: event.msgRecevied,
          cmtOrLikeOnYourPost: event.cmtOrLikeOnYourPost,
          groupAlert: event.groupAlert);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(response);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(NotificationSettingSuccess(message: message));
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(NotificationSettingFailed(message: message));
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(NotificationSettingFailed(message: "Something Went wrong"));
    }
  }

  Future<void> mapFetchSettingEvent(
      FetchSettingEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      var response = await profileDao.fetchSetting();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(response);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        SettingFetchModelList settingFetchModelList;
        settingFetchModelList = SettingFetchModelList.fromJson(jsonDecoded["data"]);
        emit(NotificationFetchSettingSuccess(settingFetchModelList: settingFetchModelList));
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(NotificationFetchSettingFailed(message: message));
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(NotificationFetchSettingFailed(message: "Something Went wrong"));
    }
  }

  Future<void> mapFetchFaqEvent(
      FetchFaqEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const PostedWorkViewLoading());
      var response = await profileDao.fetchFaq();
      customLog(response);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonDecoded['status'] == true) {
          // Parse the list of FAQs from the "data" field
          List<FaqModelList> faqList =
              faqModelListFromJson(jsonDecoded['data']);
          emit(FetchFaqSuccess(faqList: faqList));
        } else {
          String message = jsonDecoded["message"];
          emit(FetchFaqFailed(message: message));
        }
      } else {
        String message = jsonDecoded["message"];
        emit(FetchFaqFailed(message: message));
      }
    } catch (error) {
      customLog("The error is: $error");
      emit(FetchFaqFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapContactUsEvent(
      ContactUsEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const PostedWorkViewLoading());
      var response = await profileDao.contactUs(
          name: event.name,
          email: event.email,
          mobile: event.mobile,
          message: event.message);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(response);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(ContactUsSuccess(message: message));
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(ContactUsFailed(message: message));
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(ContactUsFailed(message: "Something Went wrong"));
    }
  }

  Future<void> mapFetchSavedProfessionalsEvent(
      FetchSavedProfessionalEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      var response = await profileDao.fetchSavedProfessional();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        List<ProfessionalsPostedWork> professionalsPostedWork = [];
        for (var i in jsonDecoded["data"]) {
          professionalsPostedWork.add(ProfessionalsPostedWork.fromJson(i));
        }
        emit(FetchSavedProfessionalSuccess(professionalsPostedWork: professionalsPostedWork));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(FetchSavedProfessionalFailed(message: message));
      } else {
        emit(FetchSavedProfessionalFailed(message: '"Something Went wrong"'));
      }
    } catch (error) {
      customLog("The error of resend otp is : $error");
      emit(FetchSavedProfessionalFailed(message: "Something Went wrong"));
    }
  }
}
