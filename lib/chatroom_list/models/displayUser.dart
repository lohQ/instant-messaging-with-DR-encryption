import 'package:cloud_firestore/cloud_firestore.dart';

import 'chatroom.dart';

class DisplayUser{
  final String uid;
  final String photoUrl;
  final String displayName;

  DisplayUser({this.uid, this.photoUrl, this.displayName});

  DisplayUser.fromChatroom(Chatroom chatroom)
    : uid = chatroom.oppUid,
      photoUrl = chatroom.photoUrl, 
      displayName = chatroom.displayName;

  factory DisplayUser.fromDocSnapshot(DocumentSnapshot snapshot){
    return DisplayUser(
      uid: snapshot.data["uid"],
      photoUrl: snapshot.data["photoUrl"],
      displayName: snapshot.data["displayName"]
    );
  }

  String toString(){
    return "uid: $uid, photoUrl: $photoUrl, displayName: $displayName";
  }

}