import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'displayUser.dart';

class Chatroom extends Equatable{
  final String oppUid;
  final String displayName;
  final String photoUrl;
  final String docId;
  bool joined;  // to determine whether to join or to get ratchet channel

  Chatroom({
    @required this.oppUid, 
    @required this.displayName, 
    @required this.photoUrl,
    @required this.docId, 
    this.joined = false});

  @override
  List<Object> get props => [oppUid,displayName,photoUrl,docId];

  // all chatrooms initially is created from firestore documents
  Chatroom.fromUser(DisplayUser user, String documentId)
    : oppUid = user.uid,
      displayName = user.displayName,
      photoUrl = user.photoUrl,
      docId = documentId,
      joined = false;

  /*
    modify when: 
    (1) opp user changed photoUrl or displayName
    (2) opp user unregistered when has active chatroom in self local storage (not happening yet -- firestore currently won't delete user)
    (2) firestore side added chatroom which exists in local storage (so update user detail and change docId)
    (3) firestore side deleted chatroom which exists in local storage (so change docId to null)
  */
  Chatroom modifyFromUser(DisplayUser user, bool changeDocId, {String newDocId}){
    return Chatroom(
      oppUid: oppUid,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      docId: changeDocId ? newDocId : docId,
      joined: joined
    );
  }

  // to cache locally
  factory Chatroom.fromMap(dynamic map){
    return Chatroom(
      oppUid: map["oppId"],
      displayName: map["displayName"],
      photoUrl: map["photoUrl"],
      docId: map["docId"] == "" ? null : map["docId"],
      joined: map["joined"] == 1 ? true : false
    );
  }
  Map<String,dynamic> toJson(){
    return {
      "oppId": oppUid,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "docId": docId == null ? "" : docId,
      "joined": joined ? 1 : 0
    };
  }

  @override
  String toString(){
    return "id: $oppUid,\ndisplayName: $displayName,\nphotoUrl: $photoUrl\njoined: $joined";
  }

}

