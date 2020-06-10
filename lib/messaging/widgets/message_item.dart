import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageItem extends StatelessWidget{
  final LocalMessage message;
  MessageItem(this.message);

  @override
  Widget build(BuildContext context){
    return Row(
      mainAxisAlignment: message.isOutgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(10),
          color: message.isOutgoing ? Colors.lime : Colors.amber,
          child: Row(
            children: <Widget>[
              // TODO: handle overflow of long message
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(message.value ?? "")
              ),
              message.isOutgoing
              ? Icon(message.delivered ? Icons.check : Icons.timer,)
              : Container()
            ],
          )
        ),
      ],
    );
  }
}