part of 'ethree_init_bloc.dart';

abstract class EthreeInitState extends Equatable {
  const EthreeInitState();
}

class EthreeInitInitial extends EthreeInitState {
  @override
  List<Object> get props => [];
}

class EthreeInitInProgress extends EthreeInitState {
  @override
  List<Object> get props => [];
}

class EthreeInitCompleted extends EthreeInitState {
  final EThree eThree;
  EthreeInitCompleted(this.eThree);
  @override
  List<Object> get props => [eThree];
}

class EthreeInitFailed extends EthreeInitState {
  final String error;
  EthreeInitFailed(this.error);
  @override
  List<Object> get props => [error];
}