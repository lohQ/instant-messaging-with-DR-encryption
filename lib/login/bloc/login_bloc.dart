import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:instant_messaging_with_dr_encryption/login/models/login_response.dart';
import 'package:instant_messaging_with_dr_encryption/login/models/user.dart';
import 'package:instant_messaging_with_dr_encryption/login/repositories/login_repo.dart';
import 'package:instant_messaging_with_dr_encryption/login/repositories/user_repo.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  void onAutoLogin() async {
    add(LoginEventInProgress());
    final isSignedIn = await LoginRepo.getInstance().isSignedIn();
    if(isSignedIn){
      // and has user record locally
      await UserRepo.getInstance().init();  // manually initializing singleton...
      final user = UserRepo.getInstance().getCurrentUser();
      if(user != null){
        add(LoginSuccessEvent());
      }else{
        add(LogoutEvent());
      }
    }else{
      add(LogoutEvent());
    }
  }

  void onLoginGoogle() async {
    add(LoginEventInProgress());
    final response = await LoginRepo.getInstance().signInWithGoogle();
    if(response is LoginFailedResponse){
      add(LogoutEvent());
    }else{
      UserRepo.getInstance().setCurrentUser((response as User));
      add(LoginSuccessEvent());
    }
  }

  void onLogout() async {
    add(LoginEventInProgress());
    bool result = await LoginRepo.getInstance().signOut();
    final connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.none){
      await Firestore.instance.collection("users")
        .document(UserRepo.getInstance().getCurrentUser().uid)
        .updateData({"fcmToken": null});
    }else{
      // TODO: figure out how to stop receiving push notifications even offline
    }
    UserRepo.getInstance().clearCurrentUser();
    if (result) {
      add(LogoutEvent());
    }
  }

  @override
  LoginState get initialState => LoginState.initial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginEventInProgress) {
      yield LoginState.loading();
    } else if (event is LoginErrorEvent) {
      yield LoginState.error(event.error);
    } else if (event is LoginSuccessEvent) {
      yield LoginState.success();
    } else if (event is LogoutEvent) {
      yield LoginState.initial();
    }
  }

}
