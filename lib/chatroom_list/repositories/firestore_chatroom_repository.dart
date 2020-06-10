import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/models/displayUser.dart';
import 'package:instant_messaging_with_dr_encryption/login/models/user.dart';

class FirestoreChatroomRepo {

    static Stream<QuerySnapshot> getSelfRooms(String curUserId){
      return Firestore.instance.collection("users")
        .document(curUserId).collection("chatrooms").snapshots();
    }

    static Future<DocumentSnapshot> getOppUserSnapshot(String oppUserId) async {
      return await Firestore.instance.collection("users")
        .document(oppUserId).get();
    }

    static Future<DocumentReference> createRoomBetween(User curUser, DisplayUser oppUser) async {
      final chatroomRef = await Firestore.instance.collection("chatrooms")
        .add({
          "messages": [], 
          "participants": [curUser.uid, oppUser.uid]});
      await Firestore.instance.collection("users")
        .document(oppUser.uid).collection("chatrooms")
        .document(curUser.uid).setData({
          "ref": chatroomRef
        });
      await Firestore.instance.collection("users")
        .document(curUser.uid).collection("chatrooms")
        .document(oppUser.uid).setData({
          "ref": chatroomRef
        });
      return chatroomRef;
    }

    static Future<void> deleteRoomBetween(String curUid, String oppUid) async {
      final selfChatroomRef = Firestore.instance.collection("users")
        .document(curUid).collection("chatrooms")
        .document(oppUid);
      final selfChatroom = await selfChatroomRef.get();
      if(selfChatroom == null || !selfChatroom.exists){ // already deleted
        return;
      }
      final oppChatroomRef = Firestore.instance.collection("users")
        .document(oppUid).collection("chatrooms")
        .document(curUid);
      final DocumentReference chatroomRef = (await selfChatroomRef.get()).data["ref"];
      await chatroomRef.delete();
      await selfChatroomRef.delete();
      await oppChatroomRef.delete();
    }

    static Stream<QuerySnapshot> getAllUsers(){
      return Firestore.instance.collection("users").snapshots();
    }

}