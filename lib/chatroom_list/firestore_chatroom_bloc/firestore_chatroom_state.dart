part of 'firestore_chatroom_bloc.dart';

abstract class FirestoreChatroomState extends Equatable {
  final List<Chatroom> chatrooms;
  final List<DisplayUser> availableUsers; 
  const FirestoreChatroomState(this.chatrooms, this.availableUsers);
}

class FirestoreChatroomInitial extends FirestoreChatroomState {
  FirestoreChatroomInitial() : super(List<Chatroom>(), List<DisplayUser>());
  @override
  List<Object> get props => [];
}

class FirestoreChatroomUpdated extends FirestoreChatroomState {
  FirestoreChatroomUpdated({
    @required List<Chatroom> chatrooms, @required List<DisplayUser> availableUsers})
    : super(chatrooms, availableUsers);
  @override
  List<Object> get props => [chatrooms, availableUsers];
}

class FirestoreAvailableChatroomUpdated extends FirestoreChatroomState {
  FirestoreAvailableChatroomUpdated({
    @required List<Chatroom> chatrooms, @required List<DisplayUser> availableUsers})
    : super(chatrooms, availableUsers);
  @override
  List<Object> get props => [chatrooms, availableUsers];
}

class FirestoreChatroomErrorOccurred extends FirestoreChatroomState {
  final String error;
  FirestoreChatroomErrorOccurred({
    @required this.error, 
    @required List<Chatroom> chatrooms, @required List<DisplayUser> availableUsers})
    : super(chatrooms, availableUsers);
  @override
  List<Object> get props => [error, chatrooms, availableUsers];
}

class FirestoreChatroomInProgress extends FirestoreChatroomState {
  FirestoreChatroomInProgress({
    @required List<Chatroom> chatrooms, @required List<DisplayUser> availableUsers})
    : super(chatrooms, availableUsers);
  @override
  List<Object> get props => [chatrooms, availableUsers];
}

class FirestoreChatroomCreated extends FirestoreChatroomState {
  final Chatroom created;
  FirestoreChatroomCreated({
    @required this.created, 
    @required List<Chatroom> chatrooms, @required List<DisplayUser> availableUsers})
    : super(chatrooms, availableUsers);
  @override
  List<Object> get props => [created, chatrooms, availableUsers];
}
