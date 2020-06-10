import 'dart:async';
// import 'package:instant_messaging_with_dr_encryption/constants/shared_preference_keys.dart';
import 'package:instant_messaging_with_dr_encryption/login/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserRepo {
  static UserRepo _instance;
  User _currentUser;
  SharedPreferences prefs;

  UserRepo._internal();

  factory UserRepo.getInstance() {
    if (_instance == null) {
      _instance = UserRepo._internal();
    }
    return _instance;
  }

  Future<void> init() async {
    _instance.prefs = await SharedPreferences.getInstance();
  }

  User getCurrentUser() {
    if(_currentUser != null){
      return _currentUser;
    }
    String userId = prefs.getString("userId");
    String userDisplayName = prefs.getString("displayName");
    String userPhotoUrl = prefs.getString("photoUrl");
    String fcmToken = prefs.getString("fcmToken");
    if (userId != null && userDisplayName != null && userPhotoUrl != null) {
      return User(userId, userDisplayName, userPhotoUrl, fcmToken);
    }
    return null;
  }

  Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    String token = user.fcmToken ?? prefs.getString("fcmToken");
    await prefs.setString("userId", user.uid)
        .then((value) => prefs.setString("displayName", user.displayName))
        .then((value) => prefs.setString("photoUrl", user.photoUrl))
        .then((value) => prefs.setString("fcmToken", token));
  }

  Future<void> clearCurrentUser() async {
    _currentUser = null;
    await prefs.setString("userId", null)
        .then((value) => prefs.setString("displayName", null))
        .then((value) => prefs.setString("photoUrl", null))
        .then((value) => prefs.setString("fcmToken", null));
  }

  String getFCMToken() {
    if(_currentUser != null){
      return _currentUser.fcmToken;
    }
    return prefs.getString("fcmToken");
  }

  void setFCMToken(String token) async {
    await prefs.setString("fcmToken", token);
    _currentUser = User(_currentUser.uid, _currentUser.displayName, _currentUser.photoUrl, token);
  }

}
