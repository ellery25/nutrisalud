part of 'Nutricionist_cubit.dart';

class NutricionistState extends Equatable{
  const NutricionistState();

  @override
  List<Object> get props => [];
}

class NutricionistLoading extends NutricionistState {}

class NutricionistLoaded extends NutricionistState {
  final List<Nutricionistas> nutricionists;

  const NutricionistLoaded([this.nutricionists = const []]);

  @override
  List<Object> get props => [nutricionists];
}

class NutricionistError extends NutricionistState {
  final String message;

  const NutricionistError(this.message);

  @override
  List<Object> get props => [message];
}

class NutricionistEvent {
  final List<Nutricionistas> nutricionists;

  const NutricionistEvent([this.nutricionists = const []]);
}

class FetchNutricionists extends NutricionistEvent {}

class NutricionistInitial extends NutricionistState {}