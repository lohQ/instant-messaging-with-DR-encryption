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
        Flexible(
          child: 
        Container(
          margin: message.isOutgoing
           ? EdgeInsets.only(left: 75, right: 5, top: 5, bottom: 5) 
           : EdgeInsets.only(left: 5, right: 75, top: 5, bottom: 5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Color(0xFF400040),
            // color: message.isOutgoing ? Color(0xFF600060) : Color(0xFF400040),
          ),
          child: Stack(
            // spacing: 5,
            children: <Widget>[
              // TODO: handle overflow of long message
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(message.value ?? "", style: TextStyle(color: Colors.white),),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: message.isOutgoing
                ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(
                    message.delivered ? Icons.check : Icons.timer, 
                    size: 15, 
                    color: Colors.white
                  ))
                : Container()
              )
            ],
          )
        ),
        )
      ],
    );
  }
}