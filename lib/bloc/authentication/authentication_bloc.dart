import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../components/config.dart';
import '../../components/local_constant.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
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
      try{
        emit(const AuthenticationLoading());
        print("auth loading 1");
        // sleep(const Duration(seconds: 1));
        // print("auth loading 2");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = prefs.getString(LocalConstant.accessToken) ?? "";
        String userId = prefs.getString(LocalConstant.userId) ?? "";
        String phoneNumber = prefs.getString(LocalConstant.phoneNumber) ?? "";
        String name = prefs.getString(LocalConstant.name) ?? "";
        bool profileCompleted = prefs.getBool(LocalConstant.profileCompleted) ?? false;


        Config.accessToken = token;
        Config.id = userId;
        Config.phoneNumber = phoneNumber;
        Config.name = name;
        Config.profileCompleted = profileCompleted;



        if(token.isNotEmpty){
          if(profileCompleted == false){
            emit(const AuthenticationProfileRequired());
          }else{
            emit(const AuthenticationHomeScreen());
          }
        }
        else{
          emit(const AuthenticationLoginRequired());
        }

      }
      catch(error){
        // emit(const AuthenticationLoginRequired());
        emit(const AuthenticationProfileRequired());
      }
    }

    Future<void> mapAuthenticationLogout(
        AuthenticationLogoutEvent event, Emitter<AuthenticationState> emit) async {
      ///Get values from local storage and remove them
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.remove(LocalConstant.accessToken);
      // prefs.remove(LocalConstant.userId);
      // prefs.remove(LocalConstant.profileCompleted);
      // prefs.remove(LocalConstant.phoneNumber);
      // prefs.remove(LocalConstant.name);
      // prefs.remove(LocalConstant.email);
      // prefs.remove(LocalConstant.countryCode);
      // prefs.remove(LocalConstant.currency);
      // prefs.remove(LocalConstant.sessionId);
      // prefs.remove(LocalConstant.appLogo);
      // customLog(Config.sessionId);
      //
      // Config.sessionId = "";

      print("--------------------logout--------------------");

      emit(const AuthenticationLoginRequired());

      // try {
      //   emit(const AuthenticationLoginRequired());
      //   Navigator.pushAndRemoveUntil(
      //     GlobalBlocClass.authenticationContext!,
      //     MaterialPageRoute(
      //       builder: (context) => BlocProvider(
      //         create: (context) => AuthenticationBloc()..add(const InitializeApp()),
      //         child: const Authentication(),
      //       ),
      //     ),
      //         (Route<dynamic> route) => false,
      //   );
      //
      //   const snackBar = SnackBar(content: Text("Logout Successfully"));
      //   ScaffoldMessenger.of(GlobalBlocClass.authenticationContext!).showSnackBar(snackBar);
      // } catch (e, stackTrace) {
      //   print("An error occurred: $e");
      //   print("Stack trace: $stackTrace");
      //   // Handle the error gracefully
      // }
      // if (GlobalBlocClass.authenticationContext != null){
      //
      //   Navigator.pushAndRemoveUntil(
      //     GlobalBlocClass.authenticationContext!,
      //     MaterialPageRoute(
      //       builder: (context) => BlocProvider(create: (context) => AuthenticationBloc()..add(const InitializeApp()),
      //           child: const Authentication()),
      //     ),
      //         (Route<dynamic> route) => false,
      //   );
      //   const snackBar =  SnackBar(content: Text("Logout Successfully"));
      //   ScaffoldMessenger.of(GlobalBlocClass.authenticationContext!).showSnackBar(snackBar);
      // }

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
        AuthenticationRegisterAccountEvent event, Emitter<AuthenticationState> emit) async {
      emit(const AuthenticationProfileRequired());
    }

    Future<void> mapAuthenticationHomeScreenRedirectEvent(
        AuthenticationHomeScreenRedirectEvent event, Emitter<AuthenticationState> emit) async {
      emit(const AuthenticationHomeScreen());

  }
}
