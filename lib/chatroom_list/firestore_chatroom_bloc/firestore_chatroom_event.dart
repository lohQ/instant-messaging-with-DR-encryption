part of 'firestore_chatroom_bloc.dart';

abstract class FirestoreChatroomEvent extends Equatable {
  const FirestoreChatroomEvent();
}

class FirestoreChatroomSubscribe extends FirestoreChatroomEvent {
  final String userId;
  FirestoreChatroomSubscribe(this.userId);
  @override
  List<Object> get props => [];
}

// triggered by chatroom subscription
class FirestoreChatroomUpdate extends FirestoreChatroomEvent {
  final DocumentChange docChange;
  FirestoreChatroomUpdate(this.docChange);
  @override
  List<Object> get props => [docChange];  
}
// triggered by chatroom subscription
class FirestoreAvailableChatroomUpdate extends FirestoreChatroomEvent {
  final DocumentChange docChange;
  FirestoreAvailableChatroomUpdate(this.docChange);
  @override
  List<Object> get props => [docChange];  
}

class FirestoreChatroomDelete extends FirestoreChatroomEvent {
  final Chatroom chatroom;
  final EThree eThree;
  FirestoreChatroomDelete(this.chatroom, this.eThree);
  @override
  List<Object> get props => [chatroom];
}

class FirestoreChatroomCreate extends FirestoreChatroomEvent {
  final DisplayUser user;
  final EThree eThree;
  FirestoreChatroomCreate(this.user, this.eThree);
  @override
  List<Object> get props => [user];
}
