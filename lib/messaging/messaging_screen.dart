import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/models/chatroom.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/bloc/messaging_bloc.dart';

import 'widgets/messaging_page.dart';


class MessagingScreen extends StatefulWidget {
  final Chatroom chatroom;
  const MessagingScreen({Key key, @required this.chatroom}) : super(key: key);
  @override
  MessagingScreenState createState() => MessagingScreenState();
}

class MessagingScreenState extends State<MessagingScreen>{

  MessagingBloc _messagingBloc;

  @override
  void initState(){
    super.initState();
    _messagingBloc = MessagingBloc(widget.chatroom);
    _messagingBloc.add(OpenChatroomEvent());
  }

  @override
  void dispose(){
    _messagingBloc.close();
    print("messaging bloc closed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatroom.displayName)
      ), 
      body: BlocProvider(
        create: (_) => _messagingBloc,
        child: MessagingPage()
      )
    );
  }

}

