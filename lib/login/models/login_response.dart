import 'package:equatable/equatable.dart';

abstract class LoginResponse extends Equatable{}

class LoginFailedResponse extends LoginResponse {
  final String error;

  LoginFailedResponse(this.error);

  @override
  List<Object> get props => [];
}

const String NO_USER_FOUND = "No user found.";