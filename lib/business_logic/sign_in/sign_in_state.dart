part of 'sign_in_cubit.dart';

abstract class SignInState extends Equatable {
  SignInState();
}

class SignInLoading extends SignInState {
  @override
  List<Object?> get props => [];
}

class SignInLoaded extends SignInState {
  @override
  List<Object?> get props => [];
}

class SignInError extends SignInState {
  final String error;

  SignInError({required this.error}) : super();

  @override
  List<Object?> get props => [error];
}
