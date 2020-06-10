import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:instant_messaging_with_dr_encryption/login/bloc/login_bloc.dart';
import 'ethree_init_bloc/ethree_init_bloc.dart';
import 'models/chatroom.dart';
import 'widgets/chatroom_list_page.dart';
import 'widgets/create_chatroom_page.dart';
import 'widgets/eThree_state_display_widget.dart';


class ChatroomTabView extends StatefulWidget {
  @override
  ChatroomTabViewState createState() => ChatroomTabViewState();
}

class ChatroomTabViewState extends State<ChatroomTabView> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _tabIndex;
  final List<Chatroom> chatroomList = List<Chatroom>();

  @override
  void initState(){
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabIndex = 0;
    _tabController.addListener((){
      setState((){
        _tabIndex = _tabController.index;
      });
    });
  }
  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            EthreeStateDisplayWidget(),
            _logoutButton(context)
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.chat_bubble_outline)),
              Tab(icon: Icon(Icons.add_circle_outline))
            ],
          )
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            ChatroomListPage(),
            CreateChatroomPage(),
          ]),
        floatingActionButton: _tabIndex == 0
         ? FloatingActionButton(
            onPressed: (){
              _tabController.index = 1;
            },
            child: Icon(Icons.add)
          )
        : null
      );
  }

  Widget _logoutButton(BuildContext context){
    return IconButton(
      icon: Icon(Icons.lock),
      tooltip: "Logout",
      onPressed: () async {
        BlocProvider.of<EthreeInitBloc>(context).add(EthreeLogoutEvent());
        BlocProvider.of<LoginBloc>(context).onLogout();
      },
    );
  }

}