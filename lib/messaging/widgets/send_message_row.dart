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
          return Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), 
                        hintText: "type something here"
                      )
                    )
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle, 
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF400040)),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: (){
                      BlocProvider.of<MessagingBloc>(context).add(SendMessageEvent(_textController.text));
                      _textController.text = "";
                    },
                  )
                )
              ],
            )
          );
          
          
        }
      },
    );
  }
}
