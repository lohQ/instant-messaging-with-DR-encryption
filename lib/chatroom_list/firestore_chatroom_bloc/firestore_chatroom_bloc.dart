import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:e3kit/e3kit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/models/chatroom.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/models/displayUser.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/repositories/firestore_chatroom_repository.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/repositories/local_chatroom_repo.dart';
import 'package:instant_messaging_with_dr_encryption/login/repositories/user_repo.dart';
import 'package:meta/meta.dart';

part 'firestore_chatroom_event.dart';
part 'firestore_chatroom_state.dart';

/* 
 TODO: debug Unhandled Exception: Unhandled error 
 'package:bloc/src/transition.dart': 
    Failed assertion: line 27 pos 16: 'nextState != null': is not true. 
    occurred in bloc Instance of 'FirestoreChatroomBloc'.
*/

class FirestoreChatroomBloc extends Bloc<FirestoreChatroomEvent, FirestoreChatroomState> {

  StreamSubscription<QuerySnapshot> _chatroomSubscription;
  StreamSubscription<QuerySnapshot> _userSubscription;

  Stream<FirestoreChatroomState> _loadCachedChatrooms() async* {
    yield FirestoreChatroomInProgress(chatrooms: state.chatrooms, availableUsers: state.availableUsers);
    await LocalChatroomRepo.createTableIfNotExists();
    final cachedRooms = await LocalChatroomRepo.loadCachedChatrooms();
    yield FirestoreChatroomUpdated(chatrooms: cachedRooms, availableUsers: state.availableUsers);
  }
  void _setupChatroomSubscription(String curUserId) async {
    _chatroomSubscription = FirestoreChatroomRepo.getSelfRooms(curUserId)
    .listen((snapshot) async {
      for(final change in snapshot.documentChanges){
        add(FirestoreChatroomUpdate(change));
      }});
  }
  void _setupUserSubscription(String curUserId) async {
    _userSubscription = FirestoreChatroomRepo.getAllUsers().listen((snapshot){
      for(final change in snapshot.documentChanges){
        if(change.document.data["uid"] == curUserId){
          continue;
        }
        add(FirestoreAvailableChatroomUpdate(change));
      }});
  }

  Future<FirestoreChatroomState> _mapChatroomChangeToState(FirestoreChatroomUpdate event, DocumentChange change) async {
    final curRooms = List.from(state.chatrooms).cast<Chatroom>();
    final curAvailableUsers = List.from(state.availableUsers).cast<DisplayUser>();
    final oppId = change.document.documentID;
    final existingChatroom = curRooms.firstWhere((room)=>room.oppUid == oppId, orElse: ()=>null);

    if(change.type == DocumentChangeType.added){
      DisplayUser oppUser = curAvailableUsers.firstWhere((u)=>u.uid == oppId, orElse: ()=>null);
      if(oppUser == null){
        oppUser = DisplayUser.fromDocSnapshot(await FirestoreChatroomRepo.getOppUserSnapshot(oppId));
      }else{
        curAvailableUsers.remove(oppUser);
      }
      // create chatroom from DocumentReference
      final DocumentReference chatroomRef = change.document.data["ref"];
      final newChatroom = Chatroom.fromUser(oppUser, chatroomRef.documentID);
      if(existingChatroom == null){
        await _addChatroom(curRooms, newChatroom);
        print("chatroom added");
      }else{
        if(curRooms.contains(newChatroom)){
          return null;
        }else{
          _replaceChatroom(curRooms, oppUser, true, newChatroom.docId);
          print("chatroom replaced");
        }
      }

    }else if(change.type == DocumentChangeType.removed){
      if(existingChatroom != null){ 
        final newAvailableUser = DisplayUser.fromChatroom(existingChatroom);
        _replaceChatroom(curRooms, newAvailableUser, true, null);
        print("chatroom deactivated");
      }

    }else if(change.type == DocumentChangeType.modified){
      _replaceChatroom(curRooms, DisplayUser.fromChatroom(existingChatroom), true, change.document.data["ref"].documentID);
      print("chatroom replaced");

    }
    return FirestoreChatroomUpdated(chatrooms: curRooms, availableUsers: curAvailableUsers);
  }

  Future<FirestoreChatroomState> _mapUserChangeToState(FirestoreAvailableChatroomUpdate event, DocumentChange change) async {
    final curRooms = List.from(state.chatrooms).cast<Chatroom>();
    final curAvailableUsers = List.from(state.availableUsers).cast<DisplayUser>();
    final changedUser = DisplayUser.fromDocSnapshot(change.document);

    if(change.type == DocumentChangeType.added){  // no effect on chatrooms
      final existingRoom = curRooms.firstWhere((r)=>r.oppUid == changedUser.uid, orElse: ()=>null);
      if(existingRoom == null){
        curAvailableUsers.add(changedUser);
      }
    }else if(change.type == DocumentChangeType.modified){ // propagate change to chatroom
      _replaceDisplayUser(curAvailableUsers, changedUser);
      await _replaceChatroom(curRooms, changedUser, false);
    }else if(change.type == DocumentChangeType.removed){  // propagate change to chatroom
      curAvailableUsers.remove(changedUser);
      await _replaceChatroom(curRooms, changedUser, true, null);
    }
    return FirestoreChatroomUpdated(chatrooms: curRooms, availableUsers: curAvailableUsers);
  }

  Future<void> _addChatroom(List<Chatroom> curRooms, Chatroom newChatroom) async {
    curRooms.add(newChatroom);
    await LocalChatroomRepo.cacheChatroom(newChatroom);
  }

  void _replaceDisplayUser(List<DisplayUser> list, DisplayUser element){
    final changedIndex = list.indexWhere((r)=>r.uid == element.uid);
    if(changedIndex != -1){
      list.removeAt(changedIndex);
      list.insert(changedIndex, element);
    }
  }

  Future<void> _replaceChatroom(List<Chatroom> list, DisplayUser user, bool changeDocId, [String newDocId]) async {
    final changedIndex = list.indexWhere((r)=>r.oppUid == user.uid);
    if(changedIndex != -1){
      final newChatroom = list[changedIndex].modifyFromUser(user, changeDocId, newDocId: newDocId);
      list.insert(changedIndex, newChatroom);
      list.removeAt(changedIndex+1);
      await LocalChatroomRepo.updateChatroom(newChatroom);
    }
  }

  Future<FirestoreChatroomState> _deleteChatroom(Chatroom chatroom, EThree eThree) async {
    final curRooms = List.from(state.chatrooms).cast<Chatroom>();
    final curAvailableUsers = List.from(state.availableUsers).cast<DisplayUser>();
    // delete local record
    curRooms.remove(chatroom);
    await LocalChatroomRepo.deleteChatroom(chatroom.oppUid);
    curAvailableUsers.add(DisplayUser.fromChatroom(chatroom));
    // delete remote record
    String curUserId = UserRepo.getInstance().getCurrentUser().uid;
    await FirestoreChatroomRepo.deleteRoomBetween(curUserId, chatroom.oppUid);
    return FirestoreChatroomUpdated(chatrooms: curRooms, availableUsers: curAvailableUsers);
  }

  Future<String> _createRatchetChannel(String identity, EThree eThree) async {
    try{
      await eThree.createRatchetChannel(identity);
      return null;
    } on PlatformException catch (e){
      return e.message;
    }
  }

  Stream<FirestoreChatroomState> _createChatroom(FirestoreChatroomCreate event) async* {
    yield FirestoreChatroomInProgress(chatrooms: state.chatrooms, availableUsers: state.availableUsers);
    final ratchetError = await _createRatchetChannel(event.user.uid, event.eThree);
    if(ratchetError != null){
      if(!ratchetError.contains("Channel with provided user and name already exists")){
        print(ratchetError);
        yield FirestoreChatroomErrorOccurred(error: ratchetError, chatrooms: state.chatrooms, availableUsers: state.availableUsers);
        return;
      }
    }
    final chatroomRef = await FirestoreChatroomRepo.createRoomBetween(
      UserRepo.getInstance().getCurrentUser(), event.user);
    final createdChatroom = Chatroom.fromUser(event.user, chatroomRef.documentID);
    createdChatroom.joined = true;
    // update locally
    final curRooms = List.from(state.chatrooms).cast<Chatroom>();
    final curAvailableUsers = List.from(state.availableUsers).cast<DisplayUser>();
    curAvailableUsers.remove(event.user);
    _addChatroom(curRooms, createdChatroom);
    yield FirestoreChatroomCreated(created: createdChatroom, chatrooms: curRooms, availableUsers: curAvailableUsers);

  }

  @override
  FirestoreChatroomState get initialState => FirestoreChatroomInitial();

  @override
  Stream<FirestoreChatroomState> mapEventToState(
    FirestoreChatroomEvent event,
  ) async* {

    if(event is FirestoreChatroomSubscribe) {
      _setupUserSubscription(event.userId);
      _setupChatroomSubscription(event.userId);
      yield* _loadCachedChatrooms();

    } else if (event is FirestoreChatroomUpdate){
      final nextState = await _mapChatroomChangeToState(event, event.docChange);
      if(nextState != null){
        yield nextState;
      }

    } else if (event is FirestoreAvailableChatroomUpdate){
      yield await _mapUserChangeToState(event, event.docChange);

    } else if (event is FirestoreChatroomDelete){
      yield await _deleteChatroom(event.chatroom, event.eThree);

    } else if (event is FirestoreChatroomCreate){
      if(await Connectivity().checkConnectivity() == ConnectivityResult.none){
        yield FirestoreChatroomErrorOccurred(error: "No connection", chatrooms: state.chatrooms, availableUsers: state.availableUsers);
        return;
      }
      yield* _createChatroom(event);

    }

  }

  @override
  Future<void> close(){
    _chatroomSubscription?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }
}
