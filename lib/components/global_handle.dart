import 'package:flutter/material.dart';
import '../bloc/authentication/authentication_bloc.dart';


class GlobalBlocClass {
  static AuthenticationBloc? authenticationBloc;
  static BuildContext? authenticationContext;

}