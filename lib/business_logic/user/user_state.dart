part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  UserState();

  @override
  List<Object?> get props => [];
}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final CustomUser user;

  UserLoaded({required this.user}) : super();

  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final Object? error;

  UserError({required this.error}) : super();

  @override
  List<Object?> get props => [error];
}
