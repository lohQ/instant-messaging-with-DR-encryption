import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/models/message.dart';

class FirestoreMessagingRepo {

  static Future<bool> chatroomExists(String documentId) async {
    final chatroomDoc = await Firestore.instance.collection("chatrooms")
      .document(documentId).get();
    if(chatroomDoc != null && chatroomDoc.exists){
      return true;
    }
    return false;
  }

  static Stream<DocumentSnapshot> getChatroomMessages(String documentId){
    return Firestore.instance.collection("chatrooms")
      .document(documentId).snapshots();
  }

  static Future<void> sendMessageToChatroom(Message message, String documentId) async {
    final docRef = Firestore.instance.collection("chatrooms")
      .document(documentId);
    await docRef.updateData({ 
      "messages" : FieldValue.arrayUnion([message.toJson()]) 
    });
  }

  static Future<void> deleteMessagesFromChatroom(String documentId, List<dynamic> toDelete) async {
    final docRef = Firestore.instance.collection("chatrooms")
      .document(documentId);
    await docRef.updateData({
      "messages" : FieldValue.arrayRemove(toDelete)
    });
  }

}