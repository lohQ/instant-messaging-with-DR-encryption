import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Message extends Equatable{

  final int id;       //prevent out of order message
  final String value; //encrypted
  final String authorId;

  Message({
    @required this.id, 
    @required this.value,
    @required this.authorId});

  @override
  List<Object> get props => [id, value, authorId];

  factory Message.fromJson(Map<String,dynamic> json){
    return Message(
      id: json["id"],
      value: json["value"],
      authorId: json["authorId"]
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id": id, 
      "value": value,
      "authorId": authorId
    };
  }

  String toString(){
    return "id: $id, value: $value, authorId: $authorId";
  }

}

class LocalMessage extends Equatable {
  final int id;
  final String value;
  final bool isOutgoing;
  final DateTime timestamp;
  bool delivered; //only used when isOutgoing = true

  LocalMessage({
    @required this.id, 
    @required this.value,  
    @required this.isOutgoing,
    @required this.delivered,
    @required this.timestamp});

  LocalMessage.autoTimestamp({
    @required this.id, 
    @required this.value, 
    @required this.isOutgoing,
    @required this.delivered,
  }) :  timestamp = DateTime.now();

  factory LocalMessage.fromJson(Map<String,dynamic> json){
    return LocalMessage(
      id: json["id"],
      value: json["value"],
      isOutgoing: (json["outgoing"] == 1) ? true : false,
      delivered: (json["delivered"] == 1) ? true : false,
      timestamp: DateTime.parse(json["timestamp"])
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id": id, 
      "value": value,
      "outgoing": isOutgoing ? 1 : 0,
      "delivered": delivered ? 1 : 0,
      "timestamp": timestamp.toString()
    };
  }

  @override
  List<Object> get props => [id, value, isOutgoing, delivered, timestamp];
  
}