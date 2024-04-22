import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Providers/NutricionistsProviders.dart';

part 'Nutricionist_state.dart';

class NutricionistBloc extends Bloc<NutricionistEvent, NutricionistState> {
  NutricionistBloc() : super(NutricionistInitial()) {
    on<FetchNutricionists>((event, emit) async {
      emit(NutricionistLoading());
      try {
        List<Nutricionistas> nutricionists =
            await Nutricionistas.getNutricionistas();
        emit(NutricionistLoaded(nutricionists));
      } catch (e) {
        emit(NutricionistError(e.toString()));
      }
    });
  }
}
