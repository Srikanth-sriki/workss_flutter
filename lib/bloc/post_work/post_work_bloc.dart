import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:works_app/helper/custom_log.dart';
import '../../dao/home_dao.dart';


part 'post_work_event.dart';
part 'post_work_state.dart';

class PostWorkBloc extends Bloc<PostWorkEvent, PostWorkState> {
  late HomeDao homeDao;

  PostWorkBloc() : super(PostWorkInitial()) {
    homeDao = HomeDao();

    on<CreatePostWorkEvent>((event, emit) async {
      await mapPostWorkAccountEvent(event, emit);
    });
    on<UploadMultipleImageEvent>((event, emit) async {
      await mapUploadMultipleImageEvent(event, emit);
    });
    on<EditPostWorkEvent>((event, emit) async {
      await mapEditPostWorkAccountEvent(event, emit);
    });

    on<PostWorkDeleteEvent>((event, emit) async {
      await mapDeletePostWorkEvent(event, emit);
    });

  }

  Future<void> mapPostWorkAccountEvent(
      CreatePostWorkEvent event, Emitter<PostWorkState> emit) async {
    try {
      emit(const PostWorkLoading());

      var response = await homeDao.postWork(
        description: event.description,
        experienceLevel: event.experienceLevel,
        gender: event.gender,
        isProfessionalCanCall: event.isProfessionalCanCall,
        knowLanguage: event.knowLanguage,
        latitude: event.latitude,
        location: event.location,
        longitude: event.longitude,
        requiredProfession: event.requiredProfession,
        workImages: event.workImages,
        workPlace: event.workPlace,
      );

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        String workId = jsonDecoded["data"] ["id"];
        customLog(workId);

        emit(PostWorkSuccess(message: message,workId: workId));
      } else {
        String message = jsonDecoded["message"];
        emit(PostWorkFailed(message: message));
      }
    } catch (error) {
      emit(PostWorkFailed(message: "Something Went Wrong"));
    }
  }

  Future<void> mapUploadMultipleImageEvent(
      UploadMultipleImageEvent event, Emitter<PostWorkState> emit) async {
    try {
      emit(const PostWorkLoading());

      var response = await homeDao.uploadWorksPic(imagePath: event.imagePath);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String filePath = jsonDecoded["data"];
        emit(UploadMultipleImageSuccess(filePath: filePath));
      } else {
        String message = jsonDecoded["data"];
        emit(UploadImageFailed(message: message));
      }
    } catch (error) {
      emit(UploadImageFailed(message: "Something Went Wrong"));
    }
  }
  Future<void> mapEditPostWorkAccountEvent(
      EditPostWorkEvent event, Emitter<PostWorkState> emit) async {
    try {
      emit(const PostWorkLoading());

      var response = await homeDao.editPostWork(
        workId: event.workId,
        description: event.description,
        experienceLevel: event.experienceLevel,
        gender: event.gender,
        isProfessionalCanCall: event.isProfessionalCanCall,
        knowLanguage: event.knowLanguage,
        latitude: event.latitude,
        location: event.location,
        longitude: event.longitude,
        requiredProfession: event.requiredProfession,
        workImages: event.workImages,
        workPlace: event.workPlace,
      );

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(EditPostWorkSuccess(message: message));
      } else {
        String message = jsonDecoded["message"];
        emit(EditPostWorkFailed(message: message));
      }
    } catch (error) {
      emit(EditPostWorkFailed(message: "Something Went Wrong"));
    }
  }

  Future<void> mapDeletePostWorkEvent(
      PostWorkDeleteEvent event, Emitter<PostWorkState> emit) async {
    try {
      // emit(const WorkInterestedLoading());
      var response = await homeDao.postWorkDelete(workID: event.workID);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess();
        emit(DeletePostWorkSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError();
        emit(DeletePostWorkFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError();
        emit(DeletePostWorkFailed(message: message));
      }
    } catch (error) {
      emit(DeletePostWorkFailed(message: "Something went wrong"));
    }
  }
}


