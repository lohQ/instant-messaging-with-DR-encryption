import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/ethree_init_bloc/ethree_init_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/firestore_chatroom_bloc/firestore_chatroom_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/models/displayUser.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/messaging_screen.dart';

class CreateChatroomPage extends StatelessWidget{
 
  @override
  Widget build(BuildContext context){
    return BlocConsumer(
      bloc: BlocProvider.of<FirestoreChatroomBloc>(context),
      listener: (context, FirestoreChatroomState state){
          if(state is FirestoreChatroomErrorOccurred){
            print(state.error);
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("FirestoreUserBlocError: "+state.error))
            );
          }else if(state is FirestoreChatroomCreated){
            Navigator.push(context, 
              MaterialPageRoute(builder: (_)=>MessagingScreen(chatroom: state.created))
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
            itemCount: state.availableUsers.length,
            itemBuilder: (context, i){
              return AvailableUserItem(user: state.availableUsers[i]);
            }
          );
      }
    );
  }
}

class AvailableUserItem extends StatelessWidget {
  final DisplayUser user;
  const AvailableUserItem({Key key, this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(10),
      title: Text(user.displayName),
      leading: Container(
        height: MediaQuery.of(context).size.width/4,
        width: MediaQuery.of(context).size.width/4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(user.photoUrl),
            fit: BoxFit.cover
          )
        ),
      ),
      onTap: () async {
        final eThreeInitState = BlocProvider.of<EthreeInitBloc>(context).state;
        if(eThreeInitState is EthreeInitCompleted){
          BlocProvider.of<FirestoreChatroomBloc>(context).add(FirestoreChatroomCreate(user, eThreeInitState.eThree));
        }else{
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("Unable to create chatroom with uninitialized eThree"),)
          );
        }
      },
    );
  }

}