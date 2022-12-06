part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LogoutRequested extends AuthEvent {}

class AccountDeletionRequested extends AuthEvent {}

class UserChanged extends AuthEvent {
  const UserChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user];
}
