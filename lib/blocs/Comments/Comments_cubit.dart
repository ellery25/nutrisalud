import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Providers/CommentsProviders.dart';
part 'Comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  CommentsBloc() : super(CommentsInitial()){
    on<FetchComments>((event, emit) async {
      emit(CommentsLoading());
      try {
        List<Comentario> comments = await Comentario.getComentarios();
        emit(CommentsLoaded(comments));
      } catch (e) {
        emit(CommentsError(e.toString()));
      }
    });
  }
}