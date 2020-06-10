part of 'messaging_bloc.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();
}

class OpenChatroomEvent extends MessagingEvent {
  @override
  List<Object> get props => [];
}

class SendMessageEvent extends MessagingEvent {
  final String text;
  SendMessageEvent(this.text);
  @override
  List<Object> get props => [text];
}

// class WaitForConnectionEvent extends MessagingEvent {
//   @override
//   List<Object> get props => [];
// }

class ReceiveMessageEvent extends MessagingEvent {
  final Message message;
  ReceiveMessageEvent(this.message) : assert(message != null);
  @override
  List<Object> get props => [message];
}

class SetEthreeEvent extends MessagingEvent {
  final EThree eThree;
  SetEthreeEvent(this.eThree);
  @override
  List<Object> get props => [];  
}

class MessageDeliveredEvent extends MessagingEvent {
  MessageDeliveredEvent();
  @override
  List<Object> get props => [];
}
