import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statera/data/services/services.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc()
      : super(
          Auth.instance.currentUser != null
              ? AuthState.authenticated(Auth.instance.currentUser)
              : const AuthState.unauthenticated(),
        ) {
    on<UserChanged>(_onUserChanged);
    on<LogoutRequested>(_onLogoutRequested);
    _userSubscription = Auth.instance.currentUserStream().listen(
          (user) => add(UserChanged(user)),
        );
  }

  late final StreamSubscription<User?> _userSubscription;

  void _onUserChanged(UserChanged event, Emitter<AuthState> emit) {
    emit(event.user != null
        ? AuthState.authenticated(event.user)
        : const AuthState.unauthenticated());
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    unawaited(Auth.instance.signOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
