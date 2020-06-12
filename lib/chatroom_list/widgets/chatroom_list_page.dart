import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/ethree_init_bloc/ethree_init_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/messaging_screen.dart';
import '../firestore_chatroom_bloc/firestore_chatroom_bloc.dart';
import '../models/chatroom.dart';

class ChatroomListPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<FirestoreChatroomBloc>(context),
      listener: (context, FirestoreChatroomState state){
        if(state is FirestoreChatroomErrorOccurred){
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(state.error))
          );
        }
      },
      builder: (context, FirestoreChatroomState state){
        if(state is FirestoreChatroomInProgress){
          return Center(
            child: CircularProgressIndicator()
          );
        }
        return ListView.builder(
          itemCount: state.chatrooms.length,
          itemBuilder: (context, i){
            return ChatroomItem(state.chatrooms[i]);
          }
        );
      }
    );
  }
}

class ChatroomItem extends StatelessWidget{
  final Chatroom room;
  ChatroomItem(this.room);
  @override
  Widget build(BuildContext context){
    return ListTile(
      contentPadding: EdgeInsets.all(10),
      title: Text(room.displayName),
      leading: CircleAvatar(
          backgroundImage: NetworkImage(room.photoUrl),
          radius:MediaQuery.of(context).size.width/12
      ),
      onTap: (){
        Navigator.push(context, 
          MaterialPageRoute(builder: (_)=>MessagingScreen(chatroom: room))
        );
      },
      onLongPress: (){
        bool confirmDelete = false;
        showDialog( 
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Delete Chatroom"),
              content: Text("Confirm delete chatroom with ${room.displayName}?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"), 
                  onPressed: (){
                    Navigator.pop(context);}),
                FlatButton(
                  child: Text("Confirm delete"), 
                  onPressed: (){
                    confirmDelete = true;
                    Navigator.pop(context);}),
              ]);
          }).whenComplete((){
            if(confirmDelete){
              final eThreeInitState = BlocProvider.of<EthreeInitBloc>(context).state;
              if(eThreeInitState is EthreeInitCompleted){
                BlocProvider.of<FirestoreChatroomBloc>(context).add(FirestoreChatroomDelete(room, eThreeInitState.eThree));
              }else{
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("Unable to delete chatroom with uninitialized eThree"),)
                );
              }
            }
          });
      },
    );
  }
}
