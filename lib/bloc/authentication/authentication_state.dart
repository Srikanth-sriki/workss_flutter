part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState extends Equatable{
  const AuthenticationState();
  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();

  @override
  List<Object> get props => [];
}

class AuthenticationLoginRequired extends AuthenticationState {
  const AuthenticationLoginRequired();

  @override
  List<Object> get props => [];
}

class AuthenticationProfileRequired extends AuthenticationState {
  const AuthenticationProfileRequired();

  @override
  List<Object> get props => [];
}

class AuthenticationHomeScreen extends AuthenticationState {
  const AuthenticationHomeScreen();

  @override
  List<Object> get props => [];
}