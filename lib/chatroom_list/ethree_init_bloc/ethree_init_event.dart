part of 'ethree_init_bloc.dart';

abstract class EthreeInitEvent extends Equatable {
  const EthreeInitEvent();
}

class EthreeStartInitEvent extends EthreeInitEvent {
  @override
  List<Object> get props => [];
}

class EthreeInitWithConnectivityEvent extends EthreeInitEvent {
  @override
  List<Object> get props => [];
}

class EthreeLogoutEvent extends EthreeInitEvent {
  @override
  List<Object> get props => [];
}
