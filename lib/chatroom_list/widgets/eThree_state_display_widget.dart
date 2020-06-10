import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../ethree_init_bloc/ethree_init_bloc.dart';

class EthreeStateDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Center(
        child: BlocBuilder(
          bloc: BlocProvider.of<EthreeInitBloc>(context),
          builder: (context, state){
            if(state is EthreeInitInProgress){
              return CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              );
            } else if(state is EthreeInitInitial){
              // return Text("EThree still not yet start initializing");
              return Icon(Icons.ac_unit);
            } else if(state is EthreeInitFailed){
              // return Text(state.error);
              print(state.error);
              return Icon(Icons.warning);
            } else {
              // return Text("EThree initialization completed!");
              return Icon(Icons.check_circle);
            }
          },
        )
      )
    );
  }
}