import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/login_bloc.dart';
import 'bloc/login_state.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: BlocBuilder(
          bloc: BlocProvider.of<LoginBloc>(context),
          builder: (context, LoginState state){
              if (state.loading) {
                  return CircularProgressIndicator();
              } else if (state.error != null) {
                  return Text(state.error);
              } else {
                  return 
                  ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width/4*3,
                    height: MediaQuery.of(context).size.height/20,
                    child: 
                    RaisedButton(
                      onPressed: () => BlocProvider.of<LoginBloc>(context).onLoginGoogle(),
                      child: Text(
                        "Login with Google",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Color(0xFF400040),
                    ),
                  );
              }
          },
        )
      )
    ); 
  }
}