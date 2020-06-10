import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instant_messaging_with_dr_encryption/login/models/login_response.dart';

class User extends LoginResponse{
  final String uid;
  final String displayName;
  final String photoUrl;
  final String fcmToken;

  User(this.uid, this.displayName, this.photoUrl, this.fcmToken);

  User.fromFirebaseUser(FirebaseUser firebaseUser) : this(firebaseUser.uid, firebaseUser.displayName, firebaseUser.photoUrl, "");

  factory User.fromDocSnapshot(DocumentSnapshot snapshot) {
    return User(
      snapshot.data["uid"],
      snapshot.data["displayName"],
      snapshot.data["photoUrl"],
      snapshot.data["fcmToken"]
    );
  }

  Map<String, dynamic> get map {
    return {
      "uid": uid,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "fcmToken": fcmToken
    };
  }

  @override
  List<Object> get props => [uid, displayName, photoUrl, fcmToken];
}