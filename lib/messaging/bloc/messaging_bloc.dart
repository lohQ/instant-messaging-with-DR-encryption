import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:e3kit/e3kit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/models/chatroom.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/repositories/local_chatroom_repo.dart';
import 'package:instant_messaging_with_dr_encryption/login/repositories/user_repo.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/models/message.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/repositories/firestore_message_repo.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/repositories/local_message_repo.dart';

part 'messaging_event.dart';
part 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {

  final Chatroom chatroom;
  final String selfId;
  EThree eThree;
  int sentMessageNum;

  MessagingBloc(this.chatroom) : selfId = UserRepo.getInstance().getCurrentUser().uid; 
  StreamSubscription<DocumentSnapshot> _messageSubscription;

  Future<void> _setupMessageSubscription() async {
    // if chatroom deleted then mark message as not sent?
    _messageSubscription = FirestoreMessagingRepo.getChatroomMessages(chatroom.docId)
      .listen((snapshot) async {
          if(snapshot == null || snapshot.data == null){   // chatroom deleted?
            _messageSubscription.cancel();
            return;
          }
          final List messages = snapshot.data["messages"].toList();
          if(messages.length == 0){
            add(MessageDeliveredEvent());
            return;
          }
          // TODO: arrange message by id, prevent out of order messages
          for(int i = 0; i < messages.length; i++){
            if(messages[i]["authorId"] == selfId){
              messages.removeAt(i); // don't delete these
              i--;
            }else{
              final m = Message.fromJson(messages[i]);
              await _receiveMessage(m);
            }
          }
          await FirestoreMessagingRepo.deleteMessagesFromChatroom(chatroom.docId, messages);
      });
  }

  Future<void> _receiveMessage(Message m) async {
    String decryptedValue;
    try{
        decryptedValue = await eThree.ratchetDecrypt(chatroom.oppUid, m.value);
        add(ReceiveMessageEvent((Message(id: m.id, value: decryptedValue, authorId: m.authorId))));
    } on PlatformException catch (e){
        decryptedValue = "Error decrypting: ${e.message}";
        add(ReceiveMessageEvent((Message(id: m.id, value: decryptedValue, authorId: m.authorId))));
    }
  }

  Future<LocalMessage> _sendMessage(String text) async {
    final id = sentMessageNum++;
    final localMessage = LocalMessage.autoTimestamp(id: id, value: text, isOutgoing: true, delivered: false);
    try{
      final encryptedValue = await eThree.ratchetEncrypt(chatroom.oppUid, text);
      final messageToSend = Message(id: id, value: encryptedValue, authorId: selfId);
      await FirestoreMessagingRepo.sendMessageToChatroom(messageToSend, chatroom.docId);
    } on PlatformException catch (e){
      print(e);
      return null;
    }
    return localMessage;
  }

  Future<MessagingState> _markAllMessagesAsDelivered() async {
    final curMessages = List.from(state.messages).cast<LocalMessage>();
    for(final m in curMessages){
      m.delivered = true;
    }
    LocalMessageRepo.markAllAsDelivered(chatroom.oppUid);
    return MessageDeliveredState(curMessages, state.hasEthree);
  }

  @override
  MessagingState get initialState => MessagingInitial();

  @override
  Stream<MessagingState> mapEventToState(
    MessagingEvent event,
  ) async* {

    if(event is OpenChatroomEvent) {
      // retrieve local messages
      sentMessageNum = 0;
      await LocalMessageRepo.createTableIfNotExists(chatroom.oppUid);
      final localMessages = await LocalMessageRepo.loadMessages(chatroom.oppUid);
      for(final m in localMessages){
        if(m.isOutgoing){
          sentMessageNum++;
        }
      }
      yield MessageLoadedState(localMessages.reversed.toList(), state.hasEthree);

    }else if(event is SetEthreeEvent){
      // chatroom already deleted on cloud. no message to receive nor message to send
      if(this.chatroom.docId == null){
        return;
      }
      this.eThree = event.eThree;
      try{
        if(chatroom.joined){
          print("attempting to get channel...");
          await eThree.getRatchetChannel(chatroom.oppUid);
          print("successfully got ratchet channel");
        }else{
          print("attempting to join channel...");
          await eThree.joinRatchetChannel(chatroom.oppUid);
          print("successfully joined ratchet channel");
          chatroom.joined = true;
          LocalChatroomRepo.updateChatroom(chatroom);
        }
        // prepare to receive message from cloud
        await _setupMessageSubscription();
        yield MessageEthreeInitialized(state.messages);

      } on PlatformException catch (e){
        yield MessagingErrorState("error getting or joining channel: ${e.message}", state.messages, state.hasEthree);
      }

    }else if(event is ReceiveMessageEvent){
      final m = event.message;
      final localMessage = LocalMessage.autoTimestamp(id: m.id, value: m.value, isOutgoing: false, delivered: true);
      await LocalMessageRepo.saveMessage(chatroom.oppUid, localMessage);
      yield MessageReceivedState(([localMessage] + state.messages), state.hasEthree);

    }else if(event is SendMessageEvent){
      final connected = (await Connectivity().checkConnectivity()) != ConnectivityResult.none;
      if(!connected){
        yield MessagingErrorState("No connection, message not sent", state.messages, state.hasEthree);
        return;
      }
      final m = await _sendMessage(event.text);
      if(m == null){
        yield MessagingErrorState("error encrypting message", state.messages, state.hasEthree);
      }else{
        await LocalMessageRepo.saveMessage(chatroom.oppUid, m);
        yield MessageSentState(([m] + state.messages), state.hasEthree);
      }

    }else if (event is MessageDeliveredEvent){
      yield await _markAllMessagesAsDelivered();
    }

  }

  @override
  Future<void> close(){
    _messageSubscription?.cancel();
    return super.close();
  }

}
