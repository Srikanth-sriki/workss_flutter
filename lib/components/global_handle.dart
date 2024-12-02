import 'package:flutter/material.dart';
import '../bloc/authentication/authentication_bloc.dart';
import '../bloc/home/home_bloc.dart';


class GlobalBlocClass {
  static AuthenticationBloc? authenticationBloc;
  static BuildContext? authenticationContext;

  static HomeBloc? homeBloc;
  static BuildContext? homeContext;

}