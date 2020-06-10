import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/models/chatroom.dart';
import 'package:instant_messaging_with_dr_encryption/chatroom_list/repositories/local_chatroom_repo.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/messaging_screen.dart';
import 'package:instant_messaging_with_dr_encryption/messaging/repositories/local_message_repo.dart';

class PushNotificationWidget extends StatefulWidget {
  final Widget child;
  const PushNotificationWidget({Key key, @required this.child}) : super(key: key);
  @override
  PushNotificationWidgetState createState() => PushNotificationWidgetState();
}

class PushNotificationWidgetState extends State<PushNotificationWidget>{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _setupLocalNotifications();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
        // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
        displayNotification(message); return;
        // _showItemDialog(message);
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message'); 
        if(LocalMessageRepo.database.isOpen){
          final payloadChatroom = Chatroom.fromMap(message["data"]);
          navigateToChatroom(payloadChatroom);
        }else{
          print("database not open, failed to navigate to target chatroom");
        }
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message'); 
        // TODO: store message and retrieve it later to auto-navigate
        return;
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   print(token);
    // });
  }

  void _setupLocalNotifications(){
    final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidRecieveLocalNotification);
    final initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification);
  }

  void navigateToChatroom(Chatroom payloadChatroom) async {
    final targetChatroom = await LocalChatroomRepo.loadCachedChatroomFromPayloadChatroom(payloadChatroom);
    Navigator.push(context, 
      MaterialPageRoute(builder: (_)=>MessagingScreen(chatroom: targetChatroom,))
    );
  }

  Future displayNotification(Map<String, dynamic> message) async{
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channelid', 'flutterfcm', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    final encodedChatroom = json.encode(Chatroom.fromMap(message["data"]));
    await flutterLocalNotificationsPlugin.show(
      0,
      message['notification']['title'],
      message['notification']['body'],
      platformChannelSpecifics,
      payload: encodedChatroom,);
  }
  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    if(LocalChatroomRepo.database.isOpen){
      final payloadChatroom = Chatroom.fromMap(json.decode(payload));
      navigateToChatroom(payloadChatroom);
      // can't get from state so have to get from database...
    }else{
      print("database not opened, can't open messagingScreen");
      await Fluttertoast.showToast(
          msg: "Notification Clicked",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future onDidRecieveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  await Fluttertoast.showToast(
                      msg: "Notification Clicked",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.black54,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context){
    return widget.child;
  }

}