import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Providers/ProTipsProviders.dart';
part 'ProTips_state.dart';

class ProTipsBloc extends Bloc<ProTipsEvent, ProTipsState> {
  ProTipsBloc() : super(ProTipsInitial()) {
    on<FetchProTips>((event, emit) async {
      emit(ProtipsLoading());
      try {
        List<ProTip> proTips =
            await ProTip.getProTips();
        emit(ProtipsLoaded(proTips));
      } catch (e) {
        emit(ProtipsError(e.toString()));
      }
    });
  }
}
