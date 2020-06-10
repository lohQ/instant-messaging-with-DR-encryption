import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instant_messaging_with_dr_encryption/push_notifications/push_notification_widget.dart';

import 'chatroom_list/chatroom_list_screen.dart';
import 'login/bloc/login_bloc.dart';
import 'login/bloc/login_state.dart';
import 'login/login_view.dart';


class TopmostScreen extends StatefulWidget {
  TopmostScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TopmostState();
}

class _TopmostState extends State<TopmostScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(),
      child: TopmostWidget()
    );
  }

}

class TopmostWidget extends StatefulWidget {
  const TopmostWidget({Key key}) : super(key: key);
  @override
  TopmostWidgetState createState() => TopmostWidgetState();
}

class TopmostWidgetState extends State<TopmostWidget>{

  @override
  void initState(){
    super.initState();
    BlocProvider.of<LoginBloc>(context).onAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<LoginBloc>(context),
        builder: (context, LoginState state) {
          if (state.loggedIn) {
            return PushNotificationWidget(child: ChatroomListScreen());
          } else {
            return LoginPage();
          }
        }
    );
  }

}

