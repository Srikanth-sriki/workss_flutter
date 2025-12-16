import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'dart:io';

import '../../core/storage_service.dart';
import 'package:works_app/ui/profile/logout_success.dart';

import '../../components/config.dart';
import '../../components/global_handle.dart';
import '../../components/local_constant.dart';
import '../../helper/socket_service.dart';
import '../../main.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<InitializeApp>((event, emit) async {
      await mapInitializeAppEvent(event, emit);
    });

    on<AuthenticationLogoutEvent>((event, emit) async {
      await mapAuthenticationLogout(event, emit);
    });
    on<AuthenticationLogin>((event, emit) async {
      await mapAuthenticationLogin(event, emit);
    });
    on<AuthenticationRegisterAccountEvent>((event, emit) async {
      await mapAuthenticationRegisterAccountEvent(event, emit);
    });
    on<AuthenticationHomeScreenRedirectEvent>((event, emit) async {
      await mapAuthenticationHomeScreenRedirectEvent(event, emit);
    });
  }

  Future<void> mapInitializeAppEvent(
      InitializeApp event, Emitter<AuthenticationState> emit) async {
    try {
      emit(const AuthenticationLoading());

      String token = StorageService.getString(LocalConstant.accessToken) ?? "";
      String userId = StorageService.getString(LocalConstant.userId) ?? "";
      String phoneNumber = StorageService.getString(LocalConstant.phoneNumber) ?? "";
      String userType = StorageService.getString(LocalConstant.userType) ?? "";
      String name = StorageService.getString(LocalConstant.name) ?? "";
      bool profileCompleted = StorageService.getBool(LocalConstant.profileCompleted) ?? false;
      String localLang = StorageService.getString(LocalConstant.localLanguageSelected) ?? "en";

      Config.accessToken = token;
      Config.id = userId;
      Config.phoneNumber = phoneNumber;
      Config.name = name;
      Config.profileCompleted = profileCompleted;
      Config.isRegistered = profileCompleted;
      Config.userType =userType;
      Config.languageSelected = localLang;
      print(token);
      print(profileCompleted);


      SocketService().reconnect();

      if (token.isNotEmpty) {
        if (profileCompleted == false) {
          emit(const AuthenticationProfileRequired());
        } else {
          emit(const AuthenticationHomeScreen());
        }
      } else {
        emit(const AuthenticationLoginRequired());
      }
    } catch (error) {
      emit(const AuthenticationLoginRequired());
    }
  }

  Future<void> mapAuthenticationLogout(
      AuthenticationLogoutEvent event, Emitter<AuthenticationState> emit) async {
    // Get values from local storage and remove them
    await StorageService.remove(LocalConstant.accessToken);
    await StorageService.remove(LocalConstant.userId);
    await StorageService.remove(LocalConstant.profileCompleted);
    await StorageService.remove(LocalConstant.phoneNumber);
    await StorageService.remove(LocalConstant.name);

    print("--------------------logout--------------------");

    // Emit the AuthenticationLoginRequired state without closing the Bloc
    emit(const AuthenticationLoginRequired());
  }


  Future<void> mapAuthenticationLogin(
      AuthenticationLogin event, Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationLoginRequired());

  }

  Future<void> mapAuthenticationRegisterAccountEvent(
      AuthenticationRegisterAccountEvent event,
      Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationProfileRequired());
  }

  Future<void> mapAuthenticationHomeScreenRedirectEvent(
      AuthenticationHomeScreenRedirectEvent event,
      Emitter<AuthenticationState> emit) async {
    emit(const AuthenticationHomeScreen());
  }
}
