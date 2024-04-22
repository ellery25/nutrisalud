part of 'Comments_cubit.dart';

class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object> get props => [];
}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<Comentario> comments;

  const CommentsLoaded([this.comments = const []]);

  @override
  List<Object> get props => [comments];
}

class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object> get props => [message];
}

class CommentsEvent {
  final List<Comentario> comments;

  const CommentsEvent([this.comments = const []]);
}

class FetchComments extends CommentsEvent {}

class CommentsInitial extends CommentsState {}