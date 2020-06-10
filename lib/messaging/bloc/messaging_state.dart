part of 'messaging_bloc.dart';

abstract class MessagingState extends Equatable {
  final bool hasEthree;
  final List<LocalMessage> messages;
  const MessagingState(this.hasEthree, this.messages);
}

class MessagingInitial extends MessagingState {
  MessagingInitial() : super(false, List<LocalMessage>());
  @override
  List<Object> get props => [];
}

class MessageEthreeInitialized extends MessagingState {
  MessageEthreeInitialized(List<LocalMessage> messages) : super(true, messages);
  @override
  List<Object> get props => [];
}

class MessageLoadedState extends MessagingState {
  MessageLoadedState(List<LocalMessage> messages, bool hasEthree) : super(hasEthree, messages);
  @override
  List<Object> get props => [messages];
}

class MessageReceivedState extends MessagingState {
  MessageReceivedState(List<LocalMessage> messages, bool hasEthree) : super(hasEthree, messages);
  @override
  List<Object> get props => [messages];
}

class MessageSentState extends MessagingState {
  MessageSentState(List<LocalMessage> messages, bool hasEthree) : super(hasEthree, messages);
  @override
  List<Object> get props => [messages];
}

class MessageDeliveredState extends MessagingState {
  MessageDeliveredState(List<LocalMessage> messages, bool hasEthree) : super(hasEthree, messages);
  @override
  List<Object> get props => [messages];
}

class MessagingErrorState extends MessagingState {
  final String error;
  MessagingErrorState(this.error, List<LocalMessage> messages, bool hasEthree) : super(hasEthree, messages);
  @override
  List<Object> get props => [error];
}

