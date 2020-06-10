
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/messaging_bloc.dart';
import 'message_item.dart';
// import '../models/message.dart';

class MessageList extends StatefulWidget{
  @override
  MessageListState createState() => MessageListState();
}

class MessageListState extends State<MessageList>{

  // final messages = List<LocalMessage>();

  @override
  Widget build(BuildContext context){
    return BlocConsumer(
      bloc: BlocProvider.of<MessagingBloc>(context),
      listener: (_, MessagingState state){
        if(state is MessagingErrorState){
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(state.error))
          );
        }
      },
      builder: (_, MessagingState state){
        return ListView.builder(
          shrinkWrap: true,
          reverse: true,
          itemCount: state.messages.length,
          itemBuilder: (context, i){
            return MessageItem(state.messages[i]);
          }
        );
      },
    );
  }
}
