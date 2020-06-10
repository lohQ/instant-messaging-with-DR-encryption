import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/messaging_bloc.dart';

class SendMessageRow extends StatefulWidget {
  @override
  SendMessageRowState createState() => SendMessageRowState();
}

class SendMessageRowState extends State<SendMessageRow> {

  TextEditingController _textController = TextEditingController();

  @override
  void dispose(){
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final chatroomExists = BlocProvider.of<MessagingBloc>(context).chatroom.docId != null;
    if(!chatroomExists){
      return Container(
        height: MediaQuery.of(context).size.height/10,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text("Chatroom already deleted. unable to send message to deleted chatroom. ")
        )
      );
    }

    return BlocBuilder(
      bloc: BlocProvider.of<MessagingBloc>(context),
      builder: (_, MessagingState state){
        if(!state.hasEthree){
          return Container(
            height: MediaQuery.of(context).size.height/10,
            child: LinearProgressIndicator()
          );
        }else{
          return Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: "type something here")
                  ))
              ),
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlue),
                child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: (){
                    BlocProvider.of<MessagingBloc>(context).add(SendMessageEvent(_textController.text));
                    _textController.text = "";
                  },
                )
              )
            ],
          );
        }
      },
    );
  }
}
