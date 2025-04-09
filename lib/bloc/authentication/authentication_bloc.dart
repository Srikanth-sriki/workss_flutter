import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString(LocalConstant.accessToken) ?? "";
      String userId = prefs.getString(LocalConstant.userId) ?? "";
      String phoneNumber = prefs.getString(LocalConstant.phoneNumber) ?? "";
      String userType = prefs.getString(LocalConstant.userType) ?? "";
      String name = prefs.getString(LocalConstant.name) ?? "";
      bool profileCompleted = prefs.getBool(LocalConstant.profileCompleted) ?? false;

      Config.accessToken = token;
      Config.id = userId;
      Config.phoneNumber = phoneNumber;
      Config.name = name;
      Config.profileCompleted = profileCompleted;
      Config.isRegistered = profileCompleted;
      Config.userType =userType;
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalConstant.accessToken);
    await prefs.remove(LocalConstant.userId);
    await prefs.remove(LocalConstant.profileCompleted);
    await prefs.remove(LocalConstant.phoneNumber);
    await prefs.remove(LocalConstant.name);

    print("--------------------logout--------------------");

    // Emit the AuthenticationLoginRequired state without closing the Bloc
    emit(const AuthenticationLoginRequired());
  }


  Future<void> mapAuthenticationLogin(
      AuthenticationLogin event, Emitter<AuthenticationState> emit) async {
    ///Get values from local storage and remove them
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove(LocalConstant.accessToken);
    // prefs.remove(LocalConstant.userId);
    // prefs.remove(LocalConstant.profileCompleted);
    // prefs.remove(LocalConstant.phoneNumber);
    // prefs.remove(LocalConstant.name);
    // prefs.remove(LocalConstant.email);
    // prefs.remove(LocalConstant.countryCode);
    // prefs.remove(LocalConstant.currency);
    // prefs.remove(LocalConstant.appLogo);
    // prefs.remove(LocalConstant.sessionId);

    // final authContext = GlobalBlocClass.authenticationContext;
    // if (authContext == null) {
    //   print("Authentication context is null.");
    //   return; // Return early to avoid using null context
    // }
    emit(const AuthenticationLoginRequired());
    // Navigator.pushAndRemoveUntil(
    //   GlobalBlocClass.authenticationContext!,
    //   MaterialPageRoute(
    //     builder: (context) => BlocProvider(create: (context) => AuthenticationBloc()..add(const InitializeApp()),
    //         child: const Authentication()),
    //   ),
    //       (Route<dynamic> route) => false,
    // );
    // const snackBar =  SnackBar(content: Text("Please Register"));
    // ScaffoldMessenger.of(GlobalBlocClass.authenticationContext!).showSnackBar(snackBar);
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
