import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/ethree_init_bloc/ethree_init_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/topmost_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_)=>EthreeInitBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // primarySwatch: Colors.blue,
          primaryColor: Color(0xFF400040),
          accentColor: Color(0xFF408080)
        ),
        home: TopmostScreen()
        // home: MyHomePage(title: "TEST CLOUD MESSAGING"),
      )
    );
  }
}

