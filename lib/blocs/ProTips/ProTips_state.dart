part of 'ProTips_cubit.dart';

class ProTipsState extends Equatable {

  const ProTipsState();

  @override
  List<Object> get props => [];
}

class ProtipsLoading extends ProTipsState {}

class ProtipsLoaded extends ProTipsState {
  final List<ProTip> protips;

  const ProtipsLoaded([this.protips = const []]);

  @override
  List<Object> get props => [protips];
}

class ProtipsError extends ProTipsState {
  final String message;

  const ProtipsError(this.message);

  @override
  List<Object> get props => [message];
}

class ProTipsEvent {
  
  final List<ProTip> protips;

  const ProTipsEvent([this.protips = const []]);
}

class FetchProTips extends ProTipsEvent {
}

class ProTipsInitial extends ProTipsState {}
