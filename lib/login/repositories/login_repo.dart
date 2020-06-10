import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instant_messaging_with_dr_encryption/login/models/login_response.dart';
import 'package:instant_messaging_with_dr_encryption/login/models/user.dart';
// import 'package:instant_messaging_with_dr_encryption/login/repositories/user_repo.dart';

class LoginRepo {
  static LoginRepo _instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore;
  final googleSignInRepo = GoogleSignIn(scopes: ["profile", "email"]);

  LoginRepo._internal(this._firestore);

  factory LoginRepo.getInstance() {
    if (_instance == null) {
      _instance = LoginRepo._internal(Firestore.instance);
    }
    return _instance;
  }

  Future<bool> isSignedIn() async {
    final curUser = await _auth.currentUser();
    if(curUser != null){
      return true;
    }
    return false;
  }

  Future<LoginResponse> _signIn(AuthCredential credentials) async {
    final authResult = await _auth.signInWithCredential(credentials);
    if (authResult != null && authResult.user != null) {
      final user = authResult.user;
      final token = await FirebaseMessaging().getToken();
      User serializedUser = User(user.uid, user.displayName, user.photoUrl, token);
      await _firestore
          .collection("users")
          .document(user.uid)
          .setData(serializedUser.map, merge: true);
      return serializedUser;
    } else {
      return LoginFailedResponse(NO_USER_FOUND);
    }
  }

  Future<bool> _signOut() async {
    await googleSignInRepo.disconnect();
    return _auth.signOut().catchError((error) {
      print("LoginRepo::logOut() encountered an error:\n${error.error}");
      return false;
    }).then((value) {
      return true;
    });
  }

  Future<LoginResponse> signInWithGoogle() async {
    try{
      final account = await googleSignInRepo.signIn();
      if (account != null) {
        final authentication = await account.authentication;
        final credentials = GoogleAuthProvider.getCredential(
            idToken: authentication.idToken,
            accessToken: authentication.accessToken);
        return _signIn(credentials);
      } else {
        print("account is null. ");
        return LoginFailedResponse("Login failed with no exception");
      }
    }catch (e){
      return LoginFailedResponse(e.message);
    }
  }

  Future<bool> signOut() async {
    return await _signOut();
  }
}
