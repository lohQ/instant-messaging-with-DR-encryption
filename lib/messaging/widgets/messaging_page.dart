import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/ethree_init_bloc/ethree_init_bloc.dart';

import '../bloc/messaging_bloc.dart';
import 'message_list.dart';
import 'send_message_row.dart';

class MessagingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eThreeState = BlocProvider.of<EthreeInitBloc>(context).state;
    if(eThreeState is EthreeInitCompleted){
      BlocProvider.of<MessagingBloc>(context).add(SetEthreeEvent(eThreeState.eThree));
      return _child(context);
    }else {
      return BlocListener(
        bloc: BlocProvider.of<EthreeInitBloc>(context),
        listener: (context, EthreeInitState state){
          if(state is EthreeInitCompleted){
            BlocProvider.of<MessagingBloc>(context).add(SetEthreeEvent(state.eThree));
          }
        },
        child: _child(context)
      );
    }
    
  }

  Widget _child(BuildContext context){
    return Column(
      children: <Widget>[
        Expanded(child: MessageList()),
        Divider(height: 1, thickness: 2),
        SendMessageRow(),
      ],
    );
  }

}

