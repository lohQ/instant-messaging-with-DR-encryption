import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/repositories/local_chatroom_repo.dart';
import 'package:instant_messaging_with_dr_encryption/login/repositories/user_repo.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/repositories/local_message_repo.dart';
import 'package:sqflite/sqflite.dart';

import 'chatroom_tab_view.dart';
import 'ethree_init_bloc/ethree_init_bloc.dart';
import 'firestore_chatroom_bloc/firestore_chatroom_bloc.dart';

class ChatroomListScreen extends StatefulWidget{
  @override
  ChatroomListScreenState createState() => ChatroomListScreenState();
}

class ChatroomListScreenState extends State<ChatroomListScreen>{

  final _firestoreChatroomBloc = FirestoreChatroomBloc();

  @override
  void initState(){
    super.initState();
    BlocProvider.of<EthreeInitBloc>(this.context).add(EthreeStartInitEvent());
    final user = UserRepo.getInstance().getCurrentUser();
    getDatabasesPath().then((path){
      openDatabase(
        path+"${user.uid}.db",
        onOpen: (db){
          print('database opened');
          LocalChatroomRepo.init(db);
          LocalMessageRepo.init(db);
          _firestoreChatroomBloc.add(FirestoreChatroomSubscribe(user.uid));
          // auto navigate to notified page if launched by notification
        }
      );
    });
  }

  @override
  void dispose(){
    _firestoreChatroomBloc.close();
    LocalMessageRepo.database.close();  // only need to close once
    print('database closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_)=>_firestoreChatroomBloc,
      child: ChatroomTabView()
    );
  }

}

